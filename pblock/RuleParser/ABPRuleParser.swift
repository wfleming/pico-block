//
//  RuleParser.swift
//  pblock
//
//  Created by Will Fleming on 7/10/15.
//  Copyright © 2015 Will Fleming. All rights reserved.
//

import Foundation
import CoreData

/**
Parse AdBlock+/uBlock, etc. format rules into our schema (which is modeled on the Safari
Content Blocker Extension JSON schema)

Syntax references:
https://adblockplus.org/en/filter-cheatsheet
https://github.com/gorhill/uBlock/wiki/Filter-syntax-extensions
*/
class ABPRuleParser : NSObject {
  // class members
  private(set) var ruleText: String
  private(set) var coreDataCtx: NSManagedObjectContext

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

  init(_ ruleText: String, coreDataCtx: NSManagedObjectContext) {
    self.ruleText = ruleText.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    self.coreDataCtx = coreDataCtx
  }

  // primary public interface: call to get back all rules parsed from the text
  func parsedRule() throws -> Rule? {
    if ruleText.hasPrefix("#") || ruleText.hasPrefix("!") {
      throw ABPRuleParserError("This is a comment line: you shouldn't try to parse these")
    }

    doParse()

    return buildParsedRule()
  }

  private func unescapedRuleText() -> String {
    return ruleText.stringByReplacingOccurrencesOfString("\\", withString: "")
  }

  // parse the rule text into structured attributes
  private func doParse() {
    if (didParse) {
      return
    }
    didParse = true

    // subject is basically the part of the rule text that still needs parsing:
    // it will be mutated throughout, but ruleText should never get touched.
    var subject = unescapedRuleText()

    // is this an exception/allow filter?
    if subject.hasPrefix("@@") {
      action = RuleActionType.IgnorePreviousRules;
      subject = subject.substringFromIndex(advance(subject.startIndex, 2))
    }

    // options
    if let pos = subject.rangeOfString("$") {
      parseOptions(subject.substringFromIndex(pos.endIndex))
      subject = subject.substringToIndex(pos.startIndex)
    }

    // element hiding filter?
    if let pos = subject.rangeOfString("#") {
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
        selector = subject.substringFromIndex(advance(pos.startIndex, 2))
        return
      } else if c == "@" {
        // this is an uncommonly used shortcut syntax. maybe support in the future if it
        // can be supported by content blocking
        unsupported = true
        return
      }
    }

    // regex?
    if ( subject.hasPrefix("/") && subject.hasSuffix("/") && subject.characters.count > 2 ) {
      isRegex = true
      filter = subject.substringWithRange(Range(start:subject.startIndex.successor(), end:subject.endIndex.predecessor()))
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
    return pattern.matchesInString(subject, options: NSMatchingOptions(rawValue: 0), range: NSRangeFromString(ruleText)).count > 0
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
      if val.hasPrefix("domains=") {
        let domains = val.substringFromIndex(advance(val.startIndex, 8))
        addDomains(domains, separator: "|")
        opts.removeAtIndex(idx)
        break;
      }
    }

    if(opts.count > 0) {
      dlog("Some options in rule \"\(ruleText)\" are unsupported: \(opts)")
    }
  }

  // for domains patterns on element hide rules, and advanced $domain= options
  private func addDomains(domainsStr: String, separator: String) {
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

  private func globToRegex(glob: String) -> String {
    return glob
      .stringByReplacingOccurrencesOfString(".", withString: "\\.")
      .stringByReplacingOccurrencesOfString("*", withString: ".*")
      // see https://adblockplus.org/en/filters#separators
      .stringByReplacingOccurrencesOfString("^", withString: "[^a-zA-z0-9_\\.\\-%]")
  }

  private func transformHostAnchoring(hostname: String) -> String {
    // cleanup: `||example.com`, `||*.example.com^`, `||.example.com/*`
    var hostname = hostname.stringByReplacingOccurrencesOfString("||*", withString: "||")
      .stringByReplacingOccurrencesOfString("||.", withString: "||")
      .stringByReplacingOccurrencesOfString("*||", withString: "||")
      .stringByReplacingOccurrencesOfString(".||", withString: "||")
    if hostname.hasPrefix("||") {
      hostname = "*.\(hostname.substringFromIndex(advance(hostname.startIndex, 2)))"
    }
    if hostname.hasSuffix("||") {
      hostname = "\(hostname.substringToIndex(advance(hostname.endIndex, -2))).*"
    }
    return hostname
  }

  private func ruleDomainSetFromDomainStrings(domains: Array<String>) -> NSOrderedSet {
    return NSOrderedSet(array: domains.map({ (d:String) -> RuleDomain in
      let rd = RuleDomain(inContext: coreDataCtx)
      rd.domain = d
      return rd
    }))
  }

  private func buildParsedRule() -> Rule? {
    if unsupported {
      return nil
    }

    let r = Rule(inContext: coreDataCtx)

    r.sourceText = ruleText
    r.actionType =  action
    if isRegex {
      r.triggerUrlFilter = filter
    } else {
      r.triggerUrlFilter = globToRegex(filter!)
    }
    if RuleActionType.CssDisplayNone == action {
      r.actionSelector = selector
    }
    r.triggerResourceTypes = resourceTypes
    r.triggerLoadTypes = loadTypes

    if ifDomains.count > 0 {
      r.triggerIfDomain = ruleDomainSetFromDomainStrings(ifDomains)
    }
    if unlessDomains.count > 0 {
      r.triggerUnlessDomain = ruleDomainSetFromDomainStrings(unlessDomains)
    }
    return r
  }
}