//
//  ABPRuleFileParser.swift
//  pblock
//
//  Created by Will Fleming on 8/22/15.
//  Copyright © 2015 PBlock. All rights reserved.
//

import Foundation

/**
Parse an entire set of ABP rules using ABPRuleParser
*/
class ABPRuleFileParser: RuleFileParserProtocol {
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

    let strip = { (line: String) -> String in
      line.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    }
    let isComment = { (line: String) -> Bool in
      (line.hasPrefix("#") && !line.hasPrefix("##")) || line.hasPrefix("!")
    }
    let isRule = { (line: String) -> Bool in !isComment(line) && "" != line }

    let ruleFromLine = { (line: String) -> ParsedRule? in
      do {
        return try ABPRuleParser(line).parsedRule()
      } catch let error {
        dlog("rule parser threw exception occurred: $\(error)\n")
      }
      return nil
    }

    let isNotNil = { (rule: ParsedRule?) -> Bool in nil != rule }

    let unwrapRule = { (rule: ParsedRule?) -> ParsedRule in rule! }

    rules = lines.map(strip).filter(isRule).map(ruleFromLine).filter(isNotNil).map(unwrapRule)
    return rules!
  }
}
