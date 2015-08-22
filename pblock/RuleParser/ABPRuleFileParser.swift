//
//  ABPRuleFileParser.swift
//  pblock
//
//  Created by Will Fleming on 8/22/15.
//  Copyright © 2015 Will Fleming. All rights reserved.
//

import Foundation
import CoreData

/**
Parse an entire set of ABP rules using ABPRuleParser
*/
class ABPRuleFileParser {
  private var lines: Array<String>
  private var coreDataCtx: NSManagedObjectContext
  private var rules: Array<Rule>? = nil

  init(fileSource: String, coreDataCtx: NSManagedObjectContext) {
    self.lines = fileSource.componentsSeparatedByCharactersInSet(
      NSCharacterSet.newlineCharacterSet()
    )
    self.coreDataCtx = coreDataCtx
  }

  convenience init(fileURL: NSURL, coreDataCtx: NSManagedObjectContext) {
    let fileContents = try! String(contentsOfURL: fileURL, encoding: NSUTF8StringEncoding)
    self.init(fileSource: fileContents, coreDataCtx: coreDataCtx)
  }

  func parsedRules() -> Array<Rule> {
    if let r = rules {
      return r
    }

    let isRule = { (line: String) -> Bool in !(line.hasPrefix("#") || line.hasPrefix("!")) }

    let ruleFromLine = { (line: String) -> Rule? in
      do {
        return try ABPRuleParser(line, coreDataCtx: self.coreDataCtx).parsedRule()
      } catch let error {
        dlog("rule parser threw exception occurred: $\(error)\n")
      }
      return nil
    }

    let isNotNil = { (rule: Rule?) -> Bool in nil != rule }

    let unwrapRule = { (rule: Rule?) -> Rule in rule! }

    rules = lines.filter(isRule).map(ruleFromLine).filter(isNotNil).map(unwrapRule)
    return rules!
  }
}
