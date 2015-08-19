//
//  RuleParserError.swift
//  pblock
//
//  Created by Will Fleming on 7/13/15.
//  Copyright © 2015 Will Fleming. All rights reserved.
//

import Foundation

let abpRuleParserErrorDomain = "com.willfleming.pblock.rule-parser"
let abpRuleParserErrorInvalidRuleCode = 1

class ABPRuleParserError : NSError {
   convenience init(_ message: String) {
    self.init(
      domain: abpRuleParserErrorDomain,
      code: abpRuleParserErrorInvalidRuleCode,
      userInfo: [NSLocalizedDescriptionKey: message]
    )
  }
}