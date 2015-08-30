//
//  ContentRuleJSONFileParser.swift
//  pblock
//
//  Created by Will Fleming on 8/30/15.
//  Copyright © 2015 PBlock. All rights reserved.
//

import Foundation

// a rule file parser for the WebKit content blocker extension format
class ContentRuleJSONFileParser: RuleFileParserProtocol {
  private var ruleJSONObjects: Array<Dictionary<String, AnyObject>> = []
  private var rules: Array<ParsedRule>? = nil

  required init(fileSource: String) {
    do {
      let json = try NSJSONSerialization.JSONObjectWithData(
        fileSource.dataUsingEncoding(NSUTF8StringEncoding)!,
        options: NSJSONReadingOptions.init(rawValue: 0))
      if let castJSON = json as? Array<Dictionary<String, AnyObject>> {
        self.ruleJSONObjects = castJSON
      } else {
        dlog("JSON parsed, but didn't match an expected format")
      }
    } catch {
      dlog("couldn't parse JSON: \(error)")
    }
  }

  convenience required init(fileURL: NSURL) {
    let fileContents = try! String(contentsOfURL: fileURL, encoding: NSUTF8StringEncoding)
    self.init(fileSource: fileContents)
  }

  func parsedRules() -> Array<ParsedRule> {
    if let r = rules {
      return r
    }

    let isNonNil = { (r: ParsedRule?) -> Bool in return nil != r }
    let unwrapRule = { (rule: ParsedRule?) -> ParsedRule in rule! }

    rules = ruleJSONObjects.map(ruleFromJSON).filter(isNonNil).map(unwrapRule)
    return rules!
  }

  // can return nil if JSON doesn't describe a rule
  private func ruleFromJSON(json: Dictionary<String, AnyObject>) -> ParsedRule? {
    let sourceText = try! String(
      data:NSJSONSerialization.dataWithJSONObject(json,
        options: NSJSONWritingOptions.init(rawValue: 0)),
      encoding: NSUTF8StringEncoding)

    let action = json["action"] as? Dictionary<String, String>
    let trigger = json["trigger"] as? Dictionary<String, AnyObject>

    let r = ParsedRule(
      sourceText: sourceText,

      actionType: RuleActionType.fromJSON(action!["type"]),
      actionSelector: action?["selector"],

      triggerUrlFilter: trigger?["url-filter"] as? String,
      triggerResourceTypes: RuleResourceTypeOptions.fromJSON(
        trigger?["resource-type"] as? Array<String>
      ),
      triggerLoadTypes: RuleLoadTypeOptions.fromJSON(
        trigger?["load-type"] as? Array<String>
      ),

      triggerIfDomain: trigger?["if-domain"] as? Array<String>,
      triggerUnlessDomain: trigger?["unless-domain"] as? Array<String>
    )
    return r
  }
}
