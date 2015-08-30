//
//  RuleParser.swift
//  pblock
//
//  Created by Will Fleming on 7/10/15.
//  Copyright © 2015 PBlock. All rights reserved.
//

import Foundation
import CoreData

let abpRuleParserErrorDomain = "com.willfleming.pblock.rule-parser"
let abpRuleParserErrorInvalidRuleCode = 1

class ABPRuleParserError: NSError {
  convenience init(_ message: String) {
    self.init(
      domain: abpRuleParserErrorDomain,
      code: abpRuleParserErrorInvalidRuleCode,
      userInfo: [NSLocalizedDescriptionKey: message]
    )
  }
}

/**
Parse AdBlock+/uBlock, etc. format rules into our schema (which is modeled on the Safari
Content Blocker Extension JSON schema)

Syntax references:
https://adblockplus.org/en/filter-cheatsheet
https://github.com/gorhill/uBlock/wiki/Filter-syntax-extensions
*/
class ABPRuleParser: NSObject {
  // class members
  private(set) var ruleText: String

  // these vars are for tracking state during parsing
  private var action = RuleActionType.Block
  private var selector: String?
  private var filter: String?  // the filter text
  private var ifDomains = Array<String>()
  private var unlessDomains = Array<String>()
  private var isRegex = false
  private var resourceTypes = RuleResourceTypeOptions.None
  private var loadTypes = RuleLoadTypeOptions.None
  private var unsupported = false
  private var didParse = false

  init(_ ruleText: String) {
    self.ruleText = ruleText.stringByTrimmingCharactersInSet(
      NSCharacterSet.whitespaceAndNewlineCharacterSet()
    )
  }

  // primary public interface: call to get back all rules parsed from the text
  func parsedRule() throws -> ParsedRule? {
    if (ruleText.hasPrefix("#") && !ruleText.hasPrefix("##")) || ruleText.hasPrefix("!") {
      throw ABPRuleParserError("This is a comment line: you shouldn't try to parse these")
    }
    if 0 == ruleText.characters.count {
      throw ABPRuleParserError("Empty lines aren't rules")
    }

    doParse()

    return buildParsedRule()
  }

  private func unescapedRuleText() -> String {
    return ruleText.stringByReplacingOccurrencesOfString("\\", withString: "")
  }

  // parse the rule text into structured attributes
  private func doParse() {
    if didParse {
      return
    }
    didParse = true

    // subject is basically the part of the rule text that still needs parsing:
    // it will be mutated throughout, but ruleText should never get touched.
    var subject = unescapedRuleText()

    // is this an exception/allow filter?
    if subject.hasPrefix("@@") {
      action = RuleActionType.IgnorePreviousRules;
      subject = subject.substringFromIndex(subject.startIndex.advancedBy(2))
    }

    // options
    if let pos = subject.rangeOfString("$") {
      parseOptions(subject.substringFromIndex(pos.endIndex))
      subject = subject.substringToIndex(pos.startIndex)
    }

    // element hiding filter?
    if let pos = subject.rangeOfString("#") {
      if pos.endIndex != subject.endIndex {
        let c = subject.substringWithRange(Range(start: pos.startIndex.successor(), end:pos.endIndex.successor()))
        if c == "#" {
          if RuleActionType.IgnorePreviousRules == action {
            // these types of rules did not work in my testing
            unsupported = true
            return
          }

          action = RuleActionType.CssDisplayNone
          // This is kind of odd, but I think it's to spec: ABP docs indicate that the predecessing
          // part of the rule here is domains, not URL filters.
          // https://adblockplus.org/en/filters#elemhide_domains
          addDomains(subject.substringToIndex(pos.startIndex), separator: ",")
          filter = ".*"
          isRegex = true
          selector = subject.substringFromIndex(pos.startIndex.advancedBy(2))
          return
        } else if c == "@" {
          // this is an uncommonly used shortcut syntax. maybe support in the future if it
          // can be supported by content blocking
          unsupported = true
          return
        }
      }
    }

    // regex?
    if subject.hasPrefix("/") && subject.hasSuffix("/") && subject.characters.count > 2 {
      isRegex = true
      filter = subject.substringWithRange(
        Range(start:subject.startIndex.successor(), end:subject.endIndex.predecessor())
      )
      return
    }

    // hostname-anchored
    subject = transformHostAnchoring(subject)

    if "" == subject {
      subject = "*"
    }

    filter = subject.lowercaseString
  }

  private func doesMatch(pattern: NSRegularExpression, _ subject: String) -> Bool {
    return pattern.matchesInString(subject,
      options: NSMatchingOptions(rawValue: 0),
      range: NSRangeFromString(ruleText)
    ).count > 0
  }

  private func parseOptions(optString: String) {
    var opts = optString.componentsSeparatedByString(",")
    func eat(opt: String) -> Bool {
      if opts.contains(opt) {
        opts.removeAtIndex(opts.indexOf(opt)!)
        return true
      }
      return false
    }
    if(opts.contains("popup")) {
      //popup block rules tend to be weird, and they're not a big problem these days
      unsupported = true
      return
    }

    //TODO: support the "important" option
    //TODO: support ~ syntax for resource types
    let resourceTypeMap = [
      "script": RuleResourceTypeOptions.Script,
      "image": RuleResourceTypeOptions.Image,
      "stylesheet": RuleResourceTypeOptions.StyleSheet
    ]
    for (resourceType, optValue) in resourceTypeMap {
      if eat(resourceType) {
        resourceTypes.unionInPlace(optValue)
      }
    }
    let loadTypeMap = [
      "third-party": RuleLoadTypeOptions.ThirdParty,
      "~third-party": RuleLoadTypeOptions.FirstParty
    ]
    for (loadType, optValue) in loadTypeMap {
      if eat(loadType) {
        loadTypes.unionInPlace(optValue)
      }
    }

    for (idx, val) in opts.enumerate() {
      if val.hasPrefix("domain=") {
        let domains = val.substringFromIndex(val.startIndex.advancedBy(7))
        addDomains(domains, separator: "|")
        opts.removeAtIndex(idx)
        break;
      }
    }

    if opts.count > 0 {
      dlog("Some options in rule \"\(ruleText)\" are unsupported: \(opts)")
    }
  }

  // for domains patterns on element hide rules, and advanced $domain= options
  private func addDomains(domainsStr: String, separator: String) {
    if domainsStr == "" {
      return
    }
    // we do not currently handle unicode/punycode: can probably ignore for a while
    // we do not currently handle wildcards in domains here: last time i tested, they/regexes
    // weren't supported by content blocking if-domains/unless-domains
    let domains = domainsStr.componentsSeparatedByString(separator)
    for domain in domains {
      if domain.hasPrefix("~") {
        unlessDomains.append(
          transformHostAnchoring(domain.substringFromIndex(domain.startIndex.successor()))
        )
      } else {
        ifDomains.append(transformHostAnchoring(domain))
      }
    }
  }

  private func transformHostAnchoring(hostname: String) -> String {
    // cleanup: `||example.com`, `||*.example.com^`, `||.example.com/*`
    var hostname = hostname.stringByReplacingOccurrencesOfString("||*", withString: "||")
      .stringByReplacingOccurrencesOfString("||.", withString: "||")
      .stringByReplacingOccurrencesOfString("*||", withString: "||")
      .stringByReplacingOccurrencesOfString(".||", withString: "||")
    if hostname.hasPrefix("||") {
      hostname = "*.\(hostname.substringFromIndex(hostname.startIndex.advancedBy(2)))"
    }
    if hostname.hasSuffix("||") {
      hostname = "\(hostname.substringToIndex(hostname.endIndex.advancedBy(-2))).*"
    }
    // the "|" "exact" matchers can fairly safely just be dropped
    if hostname.hasPrefix("|") {
      hostname = hostname.substringFromIndex(hostname.startIndex.successor())
    }
    if hostname.hasSuffix("|") {
      hostname = hostname.substringToIndex(hostname.endIndex.predecessor())
    }
    return hostname
  }

  private func buildParsedRule() -> ParsedRule? {
    if unsupported {
      return nil
    }

    return ParsedRule(
      sourceText: ruleText,
      actionSelector: selector,
      actionType:  action,
      triggerUrlFilter: (isRegex ? filter : globToRegex(filter!)),
      triggerResourceTypes: resourceTypes,
      triggerLoadTypes: loadTypes,
      triggerIfDomain: (ifDomains.count > 0  ? ifDomains : nil),
      triggerUnlessDomain: (unlessDomains.count > 0  ? unlessDomains : nil)
    )
  }
}
