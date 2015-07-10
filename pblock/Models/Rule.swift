//
//  Rule.swift
//  pblock
//
//  Created by Will Fleming on 7/10/15.
//  Copyright © 2015 Will Fleming. All rights reserved.
//

import Foundation
import CoreData

enum RuleActionType : Int16 {
  case Invalid = 1
  case Block
  case CssDisplayNone
  case IgnorePreviousRules

  func jsonValue() -> String? {
    switch self {
    case .Invalid:
      return nil
    case .Block:
      return "block"
    case .CssDisplayNone:
      return "css-display-none"
    case .IgnorePreviousRules:
      return "ignore-previous-rules"
    }
  }
}

@objc(Rule)
class Rule: NSManagedObject {

  var actionType : RuleActionType {
    get {
      if nil == actionTypeInt {
        return RuleActionType.Invalid
      } else {
        let rawVal = actionTypeInt!.shortValue
        if let enumVal = RuleActionType(rawValue: rawVal) {
          return enumVal
        } else {
          return RuleActionType.Invalid
        }
      }
    }
    set(newValue) {
      actionTypeInt = NSNumber(short: newValue.rawValue)
    }
  }

}
