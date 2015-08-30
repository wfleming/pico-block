//
//  RuleOptions.swift
//  pblock
//
//  Created by Will Fleming on 7/13/15.
//  Copyright © 2015 PBlock. All rights reserved.
//

import Foundation

/**
Used for Rule.actionType values: this can be a simple enum since a Rule can only have one value
*/
enum RuleActionType: Int16 {
  case Invalid = 0
  case Block
  case BlockCookies
  case CssDisplayNone
  case CssDisplayNoneStyleSheet
  case IgnorePreviousRules

  func jsonValue() -> String? {
    switch self {
    case .Invalid:
      return nil
    case .Block:
      return "block"
    case .BlockCookies:
      return "block-cookies"
    case .CssDisplayNone:
      return "css-display-none"
    case .CssDisplayNoneStyleSheet:
      // NOTE: currently unimplemented, but it appears in WebKit source, so it may show up later
      return "css-display-none-style-sheet"
    case .IgnorePreviousRules:
      return "ignore-previous-rules"
    }
  }

  static func fromJSON(val: String?) ->  RuleActionType {
    if let v = val {
      switch v {
      case "block":
        return .Block
      case "block-cookies":
        return .BlockCookies
      case "css-display-none":
        return .CssDisplayNone
      case "css-display-none-style-sheet":
        return .CssDisplayNoneStyleSheet
      case "ignore-previous-rules":
        return .IgnorePreviousRules
      default:
        return .Invalid
      }
    } else {
      return .Invalid
    }
  }
}

/**
Used for Rule.triggerResourceTypeInt values: this is an array in JSON, so this is stored as a
bitfield options set.
*/
struct RuleResourceTypeOptions: OptionSetType {
  let rawValue: Int16
  init(rawValue: Int16) { self.rawValue = rawValue }

  static let None       = RuleResourceTypeOptions(rawValue: 0)
  static let Script     = RuleResourceTypeOptions(rawValue: 1 << 0)
  static let Image      = RuleResourceTypeOptions(rawValue: 1 << 1)
  static let StyleSheet = RuleResourceTypeOptions(rawValue: 1 << 2)

  func jsonValue() -> [String]? {
    if RuleResourceTypeOptions.None.rawValue == rawValue {
      return nil
    }
    var values = [String]()
    if contains(.Script) {
      values.append("script")
    }
    if contains(.Image) {
      values.append("image")
    }
    if contains(.StyleSheet) {
      values.append("style-sheet")
    }
    return values
  }

  static func fromJSON(val: Array<String>?) -> RuleResourceTypeOptions {
    var rv = RuleResourceTypeOptions.None
    if let v = val {
      if v.contains("script") {
        rv = rv.union(.Script)
      }
      if v.contains("image") {
        rv = rv.union(.Image)
      }
      if v.contains("style-sheet") {
        rv = rv.union(.StyleSheet)
      }
    }
    return rv
  }
}

/**
Used for Rule.triggerLoadTypeInt values: this is an array in JSON, so this is stored as a
bitfield options set.
*/
struct RuleLoadTypeOptions: OptionSetType {
  let rawValue: Int16
  init(rawValue: Int16) { self.rawValue = rawValue }

  static let None       = RuleLoadTypeOptions(rawValue: 0)
  static let FirstParty = RuleLoadTypeOptions(rawValue: 1 << 0)
  static let ThirdParty = RuleLoadTypeOptions(rawValue: 1 << 1)

  func jsonValue() -> [String]? {
    if RuleLoadTypeOptions.None.rawValue == rawValue {
      return nil
    }
    var values = [String]()
    if contains(.FirstParty) {
      values.append("first-party")
    }
    if contains(.ThirdParty) {
      values.append("third-party")
    }
    return values
  }

  static func fromJSON(val: Array<String>?) -> RuleLoadTypeOptions {
    var rv = RuleLoadTypeOptions.None
    if let v = val {
      if v.contains("first-party") {
        rv = rv.union(.FirstParty)
      }
      if v.contains("third-party") {
        rv = rv.union(.ThirdParty)
      }
    }
    return rv
  }
}
