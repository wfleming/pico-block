import Quick
import Nimble
import CoreData
@testable import pblock

class RuleSpec: QuickSpec {
  override func spec() {
    describe("RuleActionType enum") {
      it("should give correct json string") {
        expect(RuleActionType.Invalid.jsonValue()).to(beNil())
        expect(RuleActionType.Block.jsonValue()).to(equal("block"))
        expect(RuleActionType.CssDisplayNone.jsonValue()).to(equal("css-display-none"))
        expect(RuleActionType.IgnorePreviousRules.jsonValue()).to(equal("ignore-previous-rules"))
      }
    }

    describe("a Rule") {
      let managedObjectContext = self.createInMemoryCoreDataCtx()
      var rule : Rule?

      describe("actionType int <-> enum mapping") {
        beforeEach {
          rule = Rule(inContext: managedObjectContext)
        }

        it("should get invalid enum for invalid int val") {
          rule?.actionTypeInt = NSNumber(short: -1)
          expect(rule?.actionType).to(equal(RuleActionType.Invalid))
        }

        it("should get invalid enum for correct int val") {
          rule?.actionTypeInt = NSNumber(short: RuleActionType.Invalid.rawValue)
          expect(rule?.actionType).to(equal(RuleActionType.Invalid))
        }

        it("should get correct enum value for int val") {
          rule?.actionTypeInt = NSNumber(short: RuleActionType.Block.rawValue)
          expect(rule?.actionType).to(equal(RuleActionType.Block))
        }

        it("should set actionTypeInt from setting actionType") {
          rule?.actionType = RuleActionType.CssDisplayNone
          expect(rule?.actionTypeInt).to(equal(NSNumber(short: RuleActionType.CssDisplayNone.rawValue)))
        }
      }
    }
  }
}
