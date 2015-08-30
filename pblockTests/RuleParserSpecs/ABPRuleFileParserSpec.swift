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

class ABPRuleFileParserSpec : QuickSpec {
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
        let str = "example.com\n" +
                  "foo.bar"
        let parser = ABPRuleFileParser(fileSource: str)
        expect(parser.parsedRules().count) == 2
      }

      it("parses some rule lines & some comments") {
        let str = "example.com\n" +
                  "# comment 1\n" +
                  "! comment 2\n" +
                  "foo.bar"
        let parser = ABPRuleFileParser(fileSource: str)
        expect(parser.parsedRules().count) == 2
      }
    }
  }
}
