import Quick
import Nimble
import CoreData
@testable import pblock

class ContentRuleJSONFileParserSpec: QuickSpec {
  override func spec() {
    describe("initialization") {
      it("inits with a string & context") {
        let parser = ContentRuleJSONFileParser(fileSource: "sample text")
        expect(parser).notTo(beNil())
      }

      it("inits with a file URL & context") {
        let tmpPath = NSURL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
          .URLByAppendingPathComponent("testRules")
        defer {
          do {
            try NSFileManager.defaultManager().removeItemAtURL(tmpPath)
          } catch let error {
            dlog("deleting tmp file threw error: \(error)")
          }
        }
        try! "sample text".writeToURL(tmpPath, atomically: true, encoding: NSUTF8StringEncoding)

        let parser = ContentRuleJSONFileParser(fileURL: tmpPath)
        expect(parser).notTo(beNil())
      }
    }

    describe("parsing") {
      it("parses some simple rules") {
        let str = "[" +
          "{\"action\":{\"type\":\"block\"},\"trigger\":{\"url-filter\":\".*\"," +
            "\"load-type\":[\"third-party\"]}}," +
          "{\"action\":{\"type\":\"css-display-none\",\"selector\":\".ad\"}," +
            "\"trigger\":{\"url-filter\":\".*\"}}" +
          "]"
        let parser = ContentRuleJSONFileParser(fileSource: str)
        expect(parser.parsedRules().count) == 2
        if parser.parsedRules().count == 2 {
          expect(parser.parsedRules()[0].actionType) == RuleActionType.Block
          expect(parser.parsedRules()[0].actionSelector).to(beNil())
          expect(parser.parsedRules()[0].triggerUrlFilter) == ".*"
          expect(parser.parsedRules()[0].triggerLoadTypes) == RuleLoadTypeOptions.ThirdParty
          expect(parser.parsedRules()[0].triggerIfDomain).to(beNil())
          expect(parser.parsedRules()[1].actionType) == RuleActionType.CssDisplayNone
          expect(parser.parsedRules()[1].actionSelector) == ".ad"
          expect(parser.parsedRules()[1].triggerUrlFilter) == ".*"
          expect(parser.parsedRules()[1].triggerIfDomain).to(beNil())
        }
      }

      it("parses nothing") {
        let str = ""
        let parser = ContentRuleJSONFileParser(fileSource: str)
        expect(parser.parsedRules().count) == 0
      }

      it("parses empty array") {
        let str = "[]"
        let parser = ContentRuleJSONFileParser(fileSource: str)
        expect(parser.parsedRules().count) == 0
      }

      it("handles incorrect format") {
        let str = "{}"
        let parser = ContentRuleJSONFileParser(fileSource: str)
        expect(parser.parsedRules().count) == 0
      }
    }
  }
}
