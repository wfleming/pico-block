import Quick
import Nimble
import CoreData
@testable import pblock

class RuleSpec: QuickSpec {
  override func spec() {
    let managedObjectContext = self.createInMemoryCoreDataCtx()

    describe("initializing a rule") {
      describe(".init(inContext:parsedRule:)") {
        it("initializes the Rule with attributes") {
          let pr = ParsedRule(
            sourceText: "sr", actionType: .CssDisplayNone, actionSelector: "sel",
            triggerUrlFilter: "url", triggerResourceTypes: .Script,
            triggerLoadTypes: .ThirdParty, triggerIfDomain: ["if"],
            triggerUnlessDomain: ["unless"]
          )
          let r = Rule(inContext: managedObjectContext, parsedRule: pr)
          expect(r.sourceText) == pr.sourceText
          expect(r.actionSelector) == pr.actionSelector
          expect(r.actionType) == pr.actionType
          expect(r.triggerUrlFilter) == pr.triggerUrlFilter
          expect(r.triggerResourceTypes) == pr.triggerResourceTypes
          expect(r.triggerLoadTypes) == pr.triggerLoadTypes
          expect(r.triggerIfDomain?.array.map { $0.domain }) == pr.triggerIfDomain
          expect(r.triggerUnlessDomain?.array.map { $0.domain }) == pr.triggerUnlessDomain
        }

        it("handles nils") {
          let pr = ParsedRule(
            sourceText: "sr", actionType: .Block, actionSelector: nil,
            triggerUrlFilter: "url", triggerResourceTypes: .None,
            triggerLoadTypes: .None, triggerIfDomain: nil,
            triggerUnlessDomain: nil
          )
          let r = Rule(inContext: managedObjectContext, parsedRule: pr)
          expect(r.sourceText) == pr.sourceText
          expect(r.actionSelector).to(beNil())
          expect(r.actionType) == pr.actionType
          expect(r.triggerUrlFilter) == pr.triggerUrlFilter
          expect(r.triggerResourceTypes) == pr.triggerResourceTypes
          expect(r.triggerLoadTypes) == pr.triggerLoadTypes
          expect(r.triggerIfDomain?.count) == 0
          expect(r.triggerUnlessDomain?.count) == 0
        }
      }
    }

    describe("a Rule") {
      var rule : Rule!

      beforeEach {
        rule = Rule(inContext: managedObjectContext)
      }

      describe(".actionType") {
        it("should get invalid enum for invalid int val") {
          rule.actionTypeRaw = NSNumber(short: -1)
          expect(rule.actionType) == RuleActionType.Invalid
        }

        it("should get invalid enum for correct int val") {
          rule.actionTypeRaw = NSNumber(short: RuleActionType.Invalid.rawValue)
          expect(rule.actionType) == RuleActionType.Invalid
        }

        it("should get correct enum value for int val") {
          rule.actionTypeRaw = NSNumber(short: RuleActionType.Block.rawValue)
          expect(rule.actionType) == RuleActionType.Block
        }

        it("should set actionTypeInt from setting actionType") {
          rule.actionType = RuleActionType.CssDisplayNone
          expect(rule.actionTypeRaw) == NSNumber(short: RuleActionType.CssDisplayNone.rawValue)
        }
      } // describe .actionType

      describe(".triggerLoadTypes") {
        it("set & get expected values with multiple values") {
          rule.triggerLoadTypes = RuleLoadTypeOptions.FirstParty.union(.ThirdParty)
          expect(rule.triggerLoadTypeRaw?.shortValue).to(beGreaterThan(0))

          expect(rule.triggerLoadTypes.contains(.FirstParty)).to(beTrue())
          expect(rule.triggerLoadTypes.contains(.ThirdParty)).to(beTrue())
        }

        it("set & get expected values with one values") {
          rule.triggerLoadTypes = .FirstParty
          expect(rule.triggerLoadTypeRaw?.shortValue).to(beGreaterThan(0))

          expect(rule.triggerLoadTypes.contains(.FirstParty)).to(beTrue())
          expect(rule.triggerLoadTypes.contains(.ThirdParty)).to(beFalse())
        }
      } // describe .triggerLoadTypes

      describe(".triggerResourceTypes") {
        it("set & get expected values with multiple values") {
          rule.triggerResourceTypes = RuleResourceTypeOptions.Script.union(.Image)
          expect(rule.triggerResourceTypeRaw?.shortValue).to(beGreaterThan(0))

          expect(rule.triggerResourceTypes.contains(.Script)).to(beTrue())
          expect(rule.triggerResourceTypes.contains(.Image)).to(beTrue())
        }

        it("set & get expected values with one values") {
          rule.triggerResourceTypes = .Script
          expect(rule.triggerResourceTypeRaw?.shortValue).to(beGreaterThan(0))

          expect(rule.triggerResourceTypes.contains(.Script)).to(beTrue())
          expect(rule.triggerResourceTypes.contains(.Image)).to(beFalse())
        }
      } // describe .triggerResourceTypes

      describe(".asJSON") {
        let rule = Rule(inContext: managedObjectContext)

        beforeEach {
          rule.sourceText = "sr"
          rule.actionType = RuleActionType.Block
          rule.actionSelector = "sel"
          rule.triggerUrlFilter = "foo\\.bar"
          rule.triggerLoadTypes = RuleLoadTypeOptions.ThirdParty
          rule.triggerResourceTypes = RuleResourceTypeOptions.Script
          let d1 = RuleDomain(inContext: managedObjectContext)
          d1.domain = "if"
          rule.triggerIfDomain = NSOrderedSet(array: [d1])
          let d2 = RuleDomain(inContext: managedObjectContext)
          d2.domain = "unless"
          rule.triggerUnlessDomain = NSOrderedSet(array: [d2])
        }

        it("generates JSON for all values") {
          let json = NSString(
            data: try! NSJSONSerialization.dataWithJSONObject(rule.asJSON(),
                options: NSJSONWritingOptions.init(rawValue: 0)
            ),
            encoding: NSUTF8StringEncoding
          )

          expect(json).to(contain("\"type\":\"block\""))
          expect(json).to(contain("\"url-filter\":\"foo\\\\.bar\""))
          expect(json).to(contain("\"load-type\":[\"third-party\"]"))
          expect(json).to(contain("\"resource-type\":[\"script\"]"))
          expect(json).to(contain("\"if-domain\":[\"if\"]"))
          expect(json).to(contain("\"unless-domain\":[\"unless\"]"))
        }

        it("handles nils") {
          rule.triggerIfDomain = nil
          rule.triggerUnlessDomain = nil
          let json = NSString(
            data: try! NSJSONSerialization.dataWithJSONObject(rule.asJSON(),
              options: NSJSONWritingOptions.init(rawValue: 0)
            ),
            encoding: NSUTF8StringEncoding
          )

          expect(json).to(contain("\"type\":\"block\""))
          expect(json).to(contain("\"url-filter\":\"foo\\\\.bar\""))
          expect(json).to(contain("\"load-type\":[\"third-party\"]"))
          expect(json).to(contain("\"resource-type\":[\"script\"]"))
          expect(json).notTo(contain("\"if-domain\""))
          expect(json).notTo(contain("\"unless-domain\""))
        }
      } // describe .asJSON
    }
  }
}
