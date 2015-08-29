//
//  HostFileParserSpec.swift
//  pblock
//
//  Created by Will Fleming on 8/22/15.
//  Copyright © 2015 PBlock. All rights reserved.
//

//
//  ABPRuleFileParserSpec.swift
//  pblock
//
//  Created by Will Fleming on 8/22/15.
//  Copyright © 2015 PBlock. All rights reserved.
//

import Quick
import Nimble
import CoreData
@testable import pblock

class HostFileParserSpec : QuickSpec {
  override func spec() {
    describe("initialization") {
      it("inits with a string & context") {
        let parser = ABPRuleFileParser(fileSource: "sample text")
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

        let parser = ABPRuleFileParser(fileURL: tmpPath)
        expect(parser).notTo(beNil())
      }
    }

    describe("parsing") {
      it("parses some simple rule lines") {
        let str = "127.0.0.1 example.com\n" +
                  "127.0.0.1 foo.bar"
        let parser = HostFileParser(fileSource: str)
        expect(parser.parsedRules().count).to(equal(2))
        expect(parser.parsedRules()[0].actionType).to(equal(RuleActionType.Block))
        expect(parser.parsedRules()[0].triggerUrlFilter).to(equal("example\\.com"))
      }

      it("parses lines that are just a host") {
        let str = "example.com"
        let parser = HostFileParser(fileSource: str)
        expect(parser.parsedRules().count).to(equal(1))
        expect(parser.parsedRules()[0].actionType).to(equal(RuleActionType.Block))
        expect(parser.parsedRules()[0].triggerUrlFilter).to(equal("example\\.com"))
      }

      it("parses some rule lines & some comments") {
        let str = "127.0.0.1 example.com\n" +
                  "# comment 1\n" +
                  "127.0.0.1 foo.bar"
        let parser = HostFileParser(fileSource: str)
        expect(parser.parsedRules().count).to(equal(2))
      }
    }
  }
}

