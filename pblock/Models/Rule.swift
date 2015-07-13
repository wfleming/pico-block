//
//  Rule.swift
//  pblock
//
//  Created by Will Fleming on 7/10/15.
//  Copyright © 2015 Will Fleming. All rights reserved.
//

import Foundation
import CoreData


@objc(Rule)
class Rule: NSManagedObject {

  var actionType : RuleActionType {
    get {
      if nil == actionTypeRaw {
        return RuleActionType.Invalid
      } else {
        let rawVal = actionTypeRaw!.shortValue
        if let enumVal = RuleActionType(rawValue: rawVal) {
          return enumVal
        } else {
          return RuleActionType.Invalid
        }
      }
    }
    set(newValue) {
      actionTypeRaw = NSNumber(short: newValue.rawValue)
    }
  }

  /**
  NB: this is a bit tricky in that you can mutuate the options values, but then the set logic
  won't get triggered, so the coredata serialized value won't be updated. So, for now, never mutate
  the value of loadTypes on an instance, always set it to a new value. i.e. don't use unionInPlace.
  */
  var triggerLoadTypes : RuleLoadTypeOptions {
    get {
      if nil == triggerLoadTypeRaw {
        return RuleLoadTypeOptions.None
      } else {
        return RuleLoadTypeOptions(rawValue: triggerLoadTypeRaw!.shortValue)
      }
    }
    set(newValue) {
      if newValue == RuleLoadTypeOptions.None {
        triggerLoadTypeRaw = nil
      } else {
        triggerLoadTypeRaw = NSNumber(short: newValue.rawValue)
      }
    }
  }

  // NB: same caution as loadTypes above
  var triggerResourceTypes : RuleResourceTypeOptions {
    get {
      if nil == triggerResourceTypeRaw {
        return RuleResourceTypeOptions.None
      } else {
        return RuleResourceTypeOptions(rawValue: triggerResourceTypeRaw!.shortValue)
      }
    }
    set(newValue) {
      if newValue == RuleResourceTypeOptions.None {
        triggerResourceTypeRaw = nil
      } else {
        triggerResourceTypeRaw = NSNumber(short: newValue.rawValue)
      }
    }
  }
}
