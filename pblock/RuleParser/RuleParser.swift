//
//  RuleParser.swift
//  pblock
//
//  Created by Will Fleming on 7/10/15.
//  Copyright © 2015 Will Fleming. All rights reserved.
//

import Foundation

class RuleParser : NSObject {
  private(set) var ruleText: String

  init(_ ruleText: String) {
    self.ruleText = ruleText
  }
}