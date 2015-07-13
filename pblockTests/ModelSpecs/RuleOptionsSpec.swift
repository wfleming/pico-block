import Quick
import Nimble
@testable import pblock

class RuleOptionsSpec: QuickSpec {
  override func spec() {
    describe("RuleActionType enum") {
      it("should give correct json string") {
        expect(RuleActionType.Invalid.jsonValue()).to(beNil())
        expect(RuleActionType.Block.jsonValue()).to(equal("block"))
        expect(RuleActionType.CssDisplayNone.jsonValue()).to(equal("css-display-none"))
        expect(RuleActionType.CssDisplayNoneStyleSheet.jsonValue()).to(equal("css-display-none-style-sheet"))
        expect(RuleActionType.IgnorePreviousRules.jsonValue()).to(equal("ignore-previous-rules"))
      }
    }

    describe("RuleResourceTypeOptions") {
      it("should return appropiate rawValue for combined options") {
        let opt = RuleResourceTypeOptions.Script.union(RuleResourceTypeOptions.Image)
        let rawVal = opt.rawValue
        expect(rawVal & RuleResourceTypeOptions.Script.rawValue).to(equal(RuleResourceTypeOptions.Script.rawValue))
        expect(rawVal & RuleResourceTypeOptions.StyleSheet.rawValue).to(equal(0))
      }

      it("should return correct JSON when no values") {
        let opt = RuleResourceTypeOptions.None
        expect(opt.jsonValue()).to(beNil())
      }

      it("should return correct JSON when it has values") {
        let opt = RuleResourceTypeOptions.Script.union(RuleResourceTypeOptions.Image)
        expect(opt.jsonValue()).to(equal(["script", "image"]))
      }
    }

    describe("RuleLoadTypeOptions") {
      it("should return appropiate rawValue for combined options") {
        let opt = RuleLoadTypeOptions.FirstParty
        let rawVal = opt.rawValue
        expect(rawVal & RuleLoadTypeOptions.FirstParty.rawValue).to(equal(RuleLoadTypeOptions.FirstParty.rawValue))
        expect(rawVal & RuleLoadTypeOptions.ThirdParty.rawValue).to(equal(0))
      }

      it("should return correct JSON when no values") {
        let opt = RuleLoadTypeOptions.None
        expect(opt.jsonValue()).to(beNil())
      }

      it("should return correct JSON when it has values") {
        let opt = RuleLoadTypeOptions.FirstParty.union(RuleLoadTypeOptions.ThirdParty)
        expect(opt.jsonValue()).to(equal(["first-party", "third-party"]))
      }
    }
  }
}
