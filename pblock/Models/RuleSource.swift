//
//  RuleSource.swift
//  pblock
//
//  Created by Will Fleming on 7/10/15.
//  Copyright © 2015 PBlock. All rights reserved.
//

import Foundation
import CoreData
import Alamofire

@objc(RuleSource)
class RuleSource: NSManagedObject {
  func parserClass() -> RuleFileParserProtocol.Type? {
    dlog("the parser for \(name) is \(parserType)")
    if nil == parserType {
      return nil
    }
    switch parserType! {
    case "ABPRuleFileParser":
      return ABPRuleFileParser.self
    case "HostFileParser":
      return HostFileParser.self
    default:
      return nil
    }
  }
}
