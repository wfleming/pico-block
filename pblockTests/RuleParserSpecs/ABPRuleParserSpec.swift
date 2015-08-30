import Quick
import Nimble
import CoreData
@testable import pblock

class ABPRuleParserSpec : QuickSpec {
  override func spec() {
    describe("initialization") {
      it("sets the ruleText content") {
        let parser = ABPRuleParser("sample text")
        expect(parser.ruleText).to(equal("sample text"))
      }
    }

    describe("parsing") {
      it("raises exception for comment") {
        //NOTE: Nimble's raise expectations seem to have problems with swift 2
        var didRaise = false
        let parser1 = ABPRuleParser("# comment")

        do {
          try parser1.parsedRule()
        } catch {
          didRaise = true
        }
        expect(didRaise).to(beTrue())

        didRaise = false
        let parser2 = ABPRuleParser("! comment")
        do {
          try parser2.parsedRule()
        } catch {
          didRaise = true
        }
        expect(didRaise).to(beTrue())
      }

      it("parses a simple hostname") {
        let rule = try! ABPRuleParser("example.com").parsedRule()
        dlog("the rule filter: \(rule?.triggerUrlFilter)")
        expect(rule?.actionType).to(equal(RuleActionType.Block))
        expect(rule?.triggerUrlFilter).to(equal("example\\.com"))
      }

      it("parses a simple hostname with anchor") {
        let rule1 = try! ABPRuleParser("||example.com").parsedRule()
        expect(rule1?.triggerUrlFilter).to(equal(".*\\.example\\.com"))

        let rule2 = try! ABPRuleParser("||.example.com").parsedRule()
        expect(rule2?.triggerUrlFilter).to(equal(".*\\.example\\.com"))

        let rule3 = try! ABPRuleParser("||*example.com").parsedRule()
        expect(rule3?.triggerUrlFilter).to(equal(".*\\.example\\.com"))

        let rule4 = try! ABPRuleParser("example.com||").parsedRule()
        expect(rule4?.triggerUrlFilter).to(equal("example\\.com\\..*"))

        let rule5 = try! ABPRuleParser("example.com.||").parsedRule()
        expect(rule5?.triggerUrlFilter).to(equal("example\\.com\\..*"))

        let rule6 = try! ABPRuleParser("example.com*||").parsedRule()
        expect(rule6?.triggerUrlFilter).to(equal("example\\.com\\..*"))
      }

      it("parses a simple hostname exception") {
        let rule = try! ABPRuleParser("@@example.com").parsedRule()
        expect(rule?.actionType).to(equal(RuleActionType.IgnorePreviousRules))
        expect(rule?.triggerUrlFilter).to(equal("example\\.com"))
      }

      it("parses a css hide rule") {
        let rule = try! ABPRuleParser("example.com##div.foo").parsedRule()
        expect(rule?.actionType).to(equal(RuleActionType.CssDisplayNone))
        expect(rule?.triggerUrlFilter).to(equal(".*"))
        expect(rule?.actionSelector).to(equal("div.foo"))
      }

      it("doesn't parse css hide exception") {
        let rule = try! ABPRuleParser("@@example.com##div.foo").parsedRule()
        expect(rule).to(beNil())
      }

      it("doesn't parse combined element-exception syntax") {
        let rule = try! ABPRuleParser("example.com#@div.foo").parsedRule()
        expect(rule).to(beNil())
      }

      it("parses advanced options") {
        let rule = try! ABPRuleParser("bad.js$third-party,domain=foo.bar|~bah.com,script").parsedRule()
        expect(rule?.actionType).to(equal(RuleActionType.Block))
        expect(rule?.triggerUrlFilter).to(equal("bad\\.js"))
        expect(rule?.triggerLoadTypes).to(equal(RuleLoadTypeOptions.ThirdParty))
        expect(rule?.triggerResourceTypes).to(equal(RuleResourceTypeOptions.Script))
        expect(rule?.triggerIfDomain).to(equal(["foo.bar"]))
        expect(rule?.triggerUnlessDomain).to(equal(["bah.com"]))
      }

      it("parses advanced options with css hide") {
        let rule = try! ABPRuleParser("example.com,~foo.bar##div$~third-party").parsedRule()
        expect(rule?.actionType).to(equal(RuleActionType.CssDisplayNone))
        expect(rule?.actionSelector).to(equal("div"))
        expect(rule?.triggerUrlFilter).to(equal(".*"))
        expect(rule?.triggerLoadTypes).to(equal(RuleLoadTypeOptions.FirstParty))
        expect(rule?.triggerIfDomain).to(equal(["example.com"]))
        expect(rule?.triggerUnlessDomain).to(equal(["foo.bar"]))
      }

      it("parses a regex rule") {
        let rule = try! ABPRuleParser("/example\\.[a-z]+/").parsedRule()
        expect(rule?.actionType).to(equal(RuleActionType.Block))
        //NOTE: I'm honestly not sure how other tools behave with escaped chars inside a regex.
        //Right now we unescape them (it's easier), but would be more correct to handle them.
        //Also, at least allow double-escaping so \\\\ = \.
        expect(rule?.triggerUrlFilter).to(equal("example.[a-z]+"))
      }

      it("parses exception regex rule") {
        let rule = try! ABPRuleParser("@@/example\\.[a-z]+/").parsedRule()
        expect(rule?.actionType).to(equal(RuleActionType.IgnorePreviousRules))
        expect(rule?.triggerUrlFilter).to(equal("example.[a-z]+"))
      }

      it("parses regex rule with options") {
        let rule = try! ABPRuleParser("/example\\.[a-z]+/$script").parsedRule()
        expect(rule?.actionType).to(equal(RuleActionType.Block))
        expect(rule?.triggerUrlFilter).to(equal("example.[a-z]+"))
        expect(rule?.triggerResourceTypes).to(equal(RuleResourceTypeOptions.Script))
      }

      // whole bunch of cases here
      let tests = [
        "www.zerohedge.com##.similar-box": ParsedRule(
          sourceText: "www.zerohedge.com##.similar-box", actionSelector: ".similar-box",
          actionType: RuleActionType.CssDisplayNone, triggerUrlFilter: ".*",
          triggerResourceTypes: RuleResourceTypeOptions.None, triggerLoadTypes: RuleLoadTypeOptions.None,
          triggerIfDomain: ["www.zerohedge.com"], triggerUnlessDomain: nil),
        "|http://$popup,domain=filenuke.com|sharesix.com": nil as ParsedRule?,
        "##.foo": ParsedRule(
          sourceText: "##.foo", actionSelector: ".foo",
          actionType: RuleActionType.CssDisplayNone, triggerUrlFilter: ".*",
          triggerResourceTypes: RuleResourceTypeOptions.None, triggerLoadTypes: RuleLoadTypeOptions.None,
          triggerIfDomain: nil, triggerUnlessDomain: nil),
        "|http://r.i.ua^$third-party": ParsedRule(
          sourceText: "|http://r.i.ua^$third-party", actionSelector: nil,
          actionType: RuleActionType.Block, triggerUrlFilter: "http://r\\.i\\.ua[^a-zA-z0-9_\\.\\-%]",
          triggerResourceTypes: RuleResourceTypeOptions.None, triggerLoadTypes: RuleLoadTypeOptions.ThirdParty,
          triggerIfDomain: nil, triggerUnlessDomain: nil),
        "||addthis.com^$third-party,important": ParsedRule(
            sourceText: "||addthis.com^$third-party,important", actionSelector: nil,
            actionType: RuleActionType.Block, triggerUrlFilter: ".*\\.addthis\\.com[^a-zA-z0-9_\\.\\-%]",
            triggerResourceTypes: RuleResourceTypeOptions.None, triggerLoadTypes: RuleLoadTypeOptions.ThirdParty,
            triggerIfDomain: nil, triggerUnlessDomain: nil)
      ]
      func eqRule(ruleText: String, _ expected: ParsedRule) -> MatcherFunc<ParsedRule> {
        return MatcherFunc<ParsedRule> { actualExpression, failureMsg in
          let actual = try! actualExpression.evaluate() as ParsedRule!
          failureMsg.postfixMessage = "source text \"\(ruleText)\""
          failureMsg.actualValue = ": actual | expected, " +
            "action: \(actual.actionType) | \(expected.actionType), " +
            "selector: \(actual.actionSelector) | \(expected.actionSelector), " +
            "url-filter: \(actual.triggerUrlFilter) | \(expected.triggerUrlFilter), " +
            "resource-types: \(actual.triggerResourceTypes) | \(expected.triggerResourceTypes), " +
            "load-types: \(actual.triggerLoadTypes) | \(expected.triggerLoadTypes), " +
            "if-domain: \(actual.triggerIfDomain) | \(expected.triggerIfDomain), " +
            "unless-domain: \(actual.triggerUnlessDomain) | \(expected.triggerUnlessDomain)"
          return actual == expected
        }
      }
      tests.forEach({ (text:String, expected: ParsedRule?) -> () in
        it("correctly parses \"\(text)\"") {
          let rule = try! ABPRuleParser(text).parsedRule()
          if nil == expected {
            expect(rule).to(beNil())
          } else {
            expect(rule).to(eqRule(text, expected!))
          }
        }
      })
    }
  }
}