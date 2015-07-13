import Quick
import Nimble
import CoreData
@testable import pblock

class RuleSpec: QuickSpec {
  override func spec() {
    describe("a Rule") {
      let managedObjectContext = self.createInMemoryCoreDataCtx()
      var rule : Rule!

      beforeEach {
        rule = Rule(inContext: managedObjectContext)
      }

      describe(".actionType") {
        it("should get invalid enum for invalid int val") {
          rule.actionTypeRaw = NSNumber(short: -1)
          expect(rule.actionType).to(equal(RuleActionType.Invalid))
        }

        it("should get invalid enum for correct int val") {
          rule.actionTypeRaw = NSNumber(short: RuleActionType.Invalid.rawValue)
          expect(rule.actionType).to(equal(RuleActionType.Invalid))
        }

        it("should get correct enum value for int val") {
          rule.actionTypeRaw = NSNumber(short: RuleActionType.Block.rawValue)
          expect(rule.actionType).to(equal(RuleActionType.Block))
        }

        it("should set actionTypeInt from setting actionType") {
          rule.actionType = RuleActionType.CssDisplayNone
          expect(rule.actionTypeRaw).to(equal(NSNumber(short: RuleActionType.CssDisplayNone.rawValue)))
        }
      } // describe .actionType

      describe(".triggerLoadTypes") {
        it("set & get expected values with multiple values") {
          rule.triggerLoadTypes = RuleLoadTypeOptions.FirstParty.union(RuleLoadTypeOptions.ThirdParty)
          expect(rule.triggerLoadTypeRaw?.shortValue).to(beGreaterThan(0))

          expect(rule.triggerLoadTypes.contains(RuleLoadTypeOptions.FirstParty)).to(beTrue())
          expect(rule.triggerLoadTypes.contains(RuleLoadTypeOptions.ThirdParty)).to(beTrue())
        }

        it("set & get expected values with one values") {
          rule.triggerLoadTypes = RuleLoadTypeOptions.FirstParty
          expect(rule.triggerLoadTypeRaw?.shortValue).to(beGreaterThan(0))

          expect(rule.triggerLoadTypes.contains(RuleLoadTypeOptions.FirstParty)).to(beTrue())
          expect(rule.triggerLoadTypes.contains(RuleLoadTypeOptions.ThirdParty)).to(beFalse())
        }
      } // describe .triggerLoadTypes

      describe(".triggerResourceTypes") {
        it("set & get expected values with multiple values") {
          rule.triggerResourceTypes = RuleResourceTypeOptions.Script.union(RuleResourceTypeOptions.Image)
          expect(rule.triggerResourceTypeRaw?.shortValue).to(beGreaterThan(0))

          expect(rule.triggerResourceTypes.contains(RuleResourceTypeOptions.Script)).to(beTrue())
          expect(rule.triggerResourceTypes.contains(RuleResourceTypeOptions.Image)).to(beTrue())
        }

        it("set & get expected values with one values") {
          rule.triggerResourceTypes = RuleResourceTypeOptions.Script
          expect(rule.triggerResourceTypeRaw?.shortValue).to(beGreaterThan(0))

          expect(rule.triggerResourceTypes.contains(RuleResourceTypeOptions.Script)).to(beTrue())
          expect(rule.triggerResourceTypes.contains(RuleResourceTypeOptions.Image)).to(beFalse())
        }
      } // describe .triggerResourceTypes
    }
  }
}
