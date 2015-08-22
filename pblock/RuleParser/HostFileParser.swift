//
//  HostFileParser.swift
//  pblock
//
//  Created by Will Fleming on 8/22/15.
//  Copyright © 2015 Will Fleming. All rights reserved.
//

import Foundation

class HostFileParser: RuleFileParserProtocol {
  private var lines: Array<String>
  private var rules: Array<ParsedRule>? = nil

  required init(fileSource: String) {
    self.lines = fileSource.componentsSeparatedByCharactersInSet(
      NSCharacterSet.newlineCharacterSet()
    )
  }

  convenience required init(fileURL: NSURL) {
    let fileContents = try! String(contentsOfURL: fileURL, encoding: NSUTF8StringEncoding)
    self.init(fileSource: fileContents)
  }

  func parsedRules() -> Array<ParsedRule> {
    if let r = rules {
      return r
    }

    let isRule = { (line: String) -> Bool in !line.hasPrefix("#") }
    let hostNameInLine = { (line: String) -> String? in
      line.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).last
    }
    let nonEmptyHostName = { (host: String?) -> Bool in
      if let h = host {
        return !h.isEmpty
      } else {
        return false
      }
    }
    let unwrapStr = { (str: String?) -> String in str! }
    let ruleFromLine = { (host: String) -> ParsedRule in
      ParsedRule(
        sourceText: host,

        actionSelector: nil,
        actionType: RuleActionType.Block,

        triggerUrlFilter: globToRegex(host),
        triggerResourceTypes: RuleResourceTypeOptions.None,
        triggerLoadTypes: RuleLoadTypeOptions.None,

        triggerIfDomain: nil,
        triggerUnlessDomain: nil
      )
    }

    rules = lines.filter(isRule).map(hostNameInLine).filter(nonEmptyHostName).map(unwrapStr)
      .map(ruleFromLine)
    return rules!
  }
}