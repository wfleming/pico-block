import Quick
import Nimble
import CoreData
@testable import pblock

class ABPRuleParserSpec : QuickSpec {
  override func spec() {
    let managedObjectContext = self.createInMemoryCoreDataCtx()

    describe("initialization") {
      it("should set the ruleText content") {
        let parser = ABPRuleParser("sample text", coreDataCtx: managedObjectContext)
        expect(parser.ruleText).to(equal("sample text"))
      }
    }

    describe("parsing") {
      it("should raise exception for comment") {
        //NOTE: Nimble's raise expectations seem to have problems with swift 2
        var didRaise = false
        let parser1 = ABPRuleParser("# comment", coreDataCtx: managedObjectContext)

        do {
          try parser1.parsedRule()
        } catch {
          didRaise = true
        }
        expect(didRaise).to(beTrue())

        didRaise = false
        let parser2 = ABPRuleParser("! comment", coreDataCtx: managedObjectContext)
        do {
          try parser2.parsedRule()
        } catch {
          didRaise = true
        }
        expect(didRaise).to(beTrue())
      }

      it("should parse simple hostname") {
        let rule = try! ABPRuleParser("example.com", coreDataCtx: managedObjectContext).parsedRule()
        dlog("the rule filter: \(rule?.triggerUrlFilter)")
        expect(rule?.actionType).to(equal(RuleActionType.Block))
        expect(rule?.triggerUrlFilter).to(equal("example\\.com"))
      }

      it("should parse simple hostname with anchor") {
        let rule1 = try! ABPRuleParser("||example.com", coreDataCtx: managedObjectContext).parsedRule()
        expect(rule1?.triggerUrlFilter).to(equal(".*\\.example\\.com"))

        let rule2 = try! ABPRuleParser("||.example.com", coreDataCtx: managedObjectContext).parsedRule()
        expect(rule2?.triggerUrlFilter).to(equal(".*\\.example\\.com"))

        let rule3 = try! ABPRuleParser("||*example.com", coreDataCtx: managedObjectContext).parsedRule()
        expect(rule3?.triggerUrlFilter).to(equal(".*\\.example\\.com"))

        let rule4 = try! ABPRuleParser("example.com||", coreDataCtx: managedObjectContext).parsedRule()
        expect(rule4?.triggerUrlFilter).to(equal("example\\.com\\..*"))

        let rule5 = try! ABPRuleParser("example.com.||", coreDataCtx: managedObjectContext).parsedRule()
        expect(rule5?.triggerUrlFilter).to(equal("example\\.com\\..*"))

        let rule6 = try! ABPRuleParser("example.com*||", coreDataCtx: managedObjectContext).parsedRule()
        expect(rule6?.triggerUrlFilter).to(equal("example\\.com\\..*"))
      }

      it("should parse simple hostname exception") {
        let rule = try! ABPRuleParser("@@example.com", coreDataCtx: managedObjectContext).parsedRule()
        expect(rule?.actionType).to(equal(RuleActionType.IgnorePreviousRules))
        expect(rule?.triggerUrlFilter).to(equal("example\\.com"))
      }

      it("should parse css hide rule") {
        let rule = try! ABPRuleParser("example.com##div.foo", coreDataCtx: managedObjectContext).parsedRule()
        expect(rule?.actionType).to(equal(RuleActionType.CssDisplayNone))
        expect(rule?.triggerUrlFilter).to(equal(".*"))
        expect(rule?.actionSelector).to(equal("div.foo"))
      }

      it("should not parse css hide exception") {
        let rule = try! ABPRuleParser("@@example.com##div.foo", coreDataCtx: managedObjectContext).parsedRule()
        expect(rule).to(beNil())
      }

      it("should not parse combined element-exception syntax") {
        let rule = try! ABPRuleParser("example.com#@div.foo", coreDataCtx: managedObjectContext).parsedRule()
        expect(rule).to(beNil())
      }

      it("should parse advanced options") {
        let rule = try! ABPRuleParser("bad.js$third-party,domains=foo.bar|~bah.com,script", coreDataCtx: managedObjectContext).parsedRule()
        expect(rule?.actionType).to(equal(RuleActionType.Block))
        expect(rule?.triggerUrlFilter).to(equal("bad\\.js"))
        expect(rule?.triggerLoadTypes).to(equal(RuleLoadTypeOptions.ThirdParty))
        expect(rule?.triggerResourceTypes).to(equal(RuleResourceTypeOptions.Script))
        let ifDomains = rule?.triggerIfDomain?.map({ (rd: AnyObject) -> String in
          return rd.domain!
        })
        expect(ifDomains).to(equal(["foo.bar"]))
        let unlessDomains = rule?.triggerUnlessDomain?.map({ (rd: AnyObject) -> String in
          return rd.domain!
        })
        expect(unlessDomains).to(equal(["bah.com"]))
      }

      it("should parse advanced options with css hide") {
        let rule = try! ABPRuleParser("example.com,~foo.bar##div$~third-party", coreDataCtx: managedObjectContext).parsedRule()
        expect(rule?.actionType).to(equal(RuleActionType.CssDisplayNone))
        expect(rule?.actionSelector).to(equal("div"))
        expect(rule?.triggerUrlFilter).to(equal(".*"))
        expect(rule?.triggerLoadTypes).to(equal(RuleLoadTypeOptions.FirstParty))
        let ifDomains = rule?.triggerIfDomain?.map({ (rd: AnyObject) -> String in
          return rd.domain!
        })
        expect(ifDomains).to(equal(["example.com"]))
        let unlessDomains = rule?.triggerUnlessDomain?.map({ (rd: AnyObject) -> String in
          return rd.domain!
        })
        expect(unlessDomains).to(equal(["foo.bar"]))
      }

      it("should parse regex rule") {
        let rule = try! ABPRuleParser("/example\\.[a-z]+/", coreDataCtx: managedObjectContext).parsedRule()
        expect(rule?.actionType).to(equal(RuleActionType.Block))
        //NOTE: I'm honestly not sure how other tools behave with escaped chars inside a regex.
        //Right now we unescape them (it's easier), but would be more correct to handle them.
        //Also, at least allow double-escaping so \\\\ = \.
        expect(rule?.triggerUrlFilter).to(equal("example.[a-z]+"))
      }

      it("should parse exception regex rule") {
        let rule = try! ABPRuleParser("@@/example\\.[a-z]+/", coreDataCtx: managedObjectContext).parsedRule()
        expect(rule?.actionType).to(equal(RuleActionType.IgnorePreviousRules))
        expect(rule?.triggerUrlFilter).to(equal("example.[a-z]+"))
      }

      it("should parse regex rule with options") {
        let rule = try! ABPRuleParser("/example\\.[a-z]+/$script", coreDataCtx: managedObjectContext).parsedRule()
        expect(rule?.actionType).to(equal(RuleActionType.Block))
        expect(rule?.triggerUrlFilter).to(equal("example.[a-z]+"))
        expect(rule?.triggerResourceTypes).to(equal(RuleResourceTypeOptions.Script))
      }
    }
  }
}