//
//  ParsedRule.swift
//  pblock
//
//  Created by Will Fleming on 8/22/15.
//  Copyright © 2015 PBlock. All rights reserved.
//

import Foundation

struct ParsedRule: Equatable {
  var sourceText: String?,

      actionType: RuleActionType,
      actionSelector: String?,

      triggerUrlFilter: String?,
      triggerResourceTypes: RuleResourceTypeOptions,
      triggerLoadTypes: RuleLoadTypeOptions,

      triggerIfDomain: Array<String>?,
      triggerUnlessDomain: Array<String>?
}

// I cannot believe you're making me do this, Swift
func optEq<T: Equatable>(lhs:Optional<T>, _ rhs: Optional<T>) -> Bool {
  let lNil = (lhs == nil), rNil = (rhs == nil)
  if lNil != rNil {
    return false
  } else if lNil {
    return true
  } else {
    return lhs! == rhs!
  }
}

// not sure why the optEq above didn't work for arrays...
func optArrayEq<T: Equatable>(lhs:Optional<Array<T>>, _ rhs: Optional<Array<T>>) -> Bool {
  let lNil = (lhs == nil), rNil = (rhs == nil)
  if lNil != rNil {
    return false
  } else if lNil {
    return true
  } else {
    return lhs! == rhs!
  }
}

func ==(lhs: ParsedRule, rhs: ParsedRule) -> Bool {
  return optEq(lhs.sourceText, rhs.sourceText) &&
         optEq(lhs.actionSelector, rhs.actionSelector) &&
         lhs.actionType == rhs.actionType &&
         optEq(lhs.triggerUrlFilter, rhs.triggerUrlFilter) &&
         lhs.triggerResourceTypes == rhs.triggerResourceTypes &&
         lhs.triggerLoadTypes == rhs.triggerLoadTypes &&
         optArrayEq(lhs.triggerIfDomain, rhs.triggerIfDomain) &&
         optArrayEq(lhs.triggerUnlessDomain, rhs.triggerUnlessDomain)
}