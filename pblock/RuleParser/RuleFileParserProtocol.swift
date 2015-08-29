//
//  RuleFileParserProtocol.swift
//  pblock
//
//  Created by Will Fleming on 8/22/15.
//  Copyright © 2015 PBlock. All rights reserved.
//

import Foundation

protocol RuleFileParserProtocol {

  init(fileSource: String)
  init(fileURL: NSURL)

  func parsedRules() -> Array<ParsedRule>
}
