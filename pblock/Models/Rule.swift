//
//  Rule.swift
//  pblock
//
//  Created by Will Fleming on 7/10/15.
//  Copyright © 2015 PBlock. All rights reserved.
//

import Foundation
import CoreData

@objc(Rule)
class Rule: NSManagedObject {

  // intitialize from a ParsedRule in the default object context
  convenience init(inContext: NSManagedObjectContext, parsedRule: ParsedRule) {
    self.init(inContext: inContext)
    sourceText = parsedRule.sourceText
    actionType = parsedRule.actionType
    actionSelector = parsedRule.actionSelector
    triggerUrlFilter = parsedRule.triggerUrlFilter
    triggerResourceTypes = parsedRule.triggerResourceTypes
    triggerLoadTypes = parsedRule.triggerLoadTypes

    if let ifDomains = parsedRule.triggerIfDomain {
      triggerIfDomain = NSOrderedSet(array: ifDomains.map({ (domainStr) -> RuleDomain in
        let d = RuleDomain(inContext: inContext)
        d.domain = domainStr
        return d
      }))
    }

    if let unlessDomains = parsedRule.triggerUnlessDomain {
      triggerUnlessDomain = NSOrderedSet(array: unlessDomains.map({ (domainStr) -> RuleDomain in
        let d = RuleDomain(inContext: inContext)
        d.domain = domainStr
        return d
      }))
    }
  }

  var actionType: RuleActionType {
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
  var triggerLoadTypes: RuleLoadTypeOptions {
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
  var triggerResourceTypes: RuleResourceTypeOptions {
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

  // return the WebKit Content Blocker JSON for this rule
  func asJSON() -> Dictionary<String, AnyObject> {
    var actionJSON = Dictionary<String, AnyObject>(),
        triggerJSON = Dictionary<String, AnyObject>()

    actionJSON["type"] = actionType.jsonValue()
    if let cssSelector = actionSelector {
      actionJSON["selector"] = cssSelector
    }

    if let urlFilter = triggerUrlFilter {
      triggerJSON["url-filter"] = urlFilter
    }
    if let resourceTypes = triggerResourceTypes.jsonValue() {
      triggerJSON["resource-type"] = resourceTypes
    }
    if let loadTypes = triggerLoadTypes.jsonValue() {
      triggerJSON["load-type"] = loadTypes
    }
    if let ifDomains = triggerIfDomain?.array where ifDomains.count > 0 {
      triggerJSON["if-domain"] = ifDomains.map { $0.domain }
    }
    if let unlessDomains = triggerUnlessDomain?.array where unlessDomains.count > 0 {
      triggerJSON["unless-domain"] = unlessDomains.map { $0.domain }
    }


    return [
      "action": actionJSON,
      "trigger": triggerJSON,
    ]
  }
}
