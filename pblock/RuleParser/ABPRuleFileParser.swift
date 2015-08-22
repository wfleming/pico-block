//
//  ABPRuleFileParser.swift
//  pblock
//
//  Created by Will Fleming on 8/22/15.
//  Copyright © 2015 Will Fleming. All rights reserved.
//

import Foundation

/**
Parse an entire set of ABP rules using ABPRuleParser
*/
class ABPRuleFileParser {
  private var lines: Array<String>

  init(fileSource: String) {
    self.lines = fileSource.componentsSeparatedByString("\n")
  }

  convenience init(fileURL: NSURL) {
    let fileContents = try! String(contentsOfURL: fileURL, encoding: NSUTF8StringEncoding)
    self.init(fileSource: fileContents)
  }

  func parsedRules() -> Array<Rule> {
    //TODO
    return [];
  }
}
