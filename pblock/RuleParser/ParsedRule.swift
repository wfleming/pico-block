//
//  ParsedRule.swift
//  pblock
//
//  Created by Will Fleming on 8/22/15.
//  Copyright © 2015 PBlock. All rights reserved.
//

import Foundation

struct ParsedRule {
  var sourceText: String?,

      actionSelector: String?,
      actionType: RuleActionType,

      triggerUrlFilter: String?,
      triggerResourceTypes: RuleResourceTypeOptions,
      triggerLoadTypes: RuleLoadTypeOptions,

      triggerIfDomain: Array<String>?,
      triggerUnlessDomain: Array<String>?
}