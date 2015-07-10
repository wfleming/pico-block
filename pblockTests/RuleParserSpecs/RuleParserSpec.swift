//
//  RuleParserSpec.swift
//  pblock
//
//  Created by Will Fleming on 7/10/15.
//  Copyright © 2015 Will Fleming. All rights reserved.
//

import Quick
import Nimble
@testable import pblock

class RuleParserSpec : QuickSpec {
  override func spec() {
    describe("initialization") {
      it("should set the ruleText content") {
        let parser = RuleParser("sample text")
        expect(parser.ruleText).to(equal("sample text"))
      }
    }
  }
}