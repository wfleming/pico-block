//
//  RuleSource.swift
//  pblock
//
//  Created by Will Fleming on 7/10/15.
//  Copyright © 2015 PBlock. All rights reserved.
//

import Foundation
import CoreData
import Alamofire

@objc(RuleSource)
class RuleSource: NSManagedObject {
  static let etagHeader = "ETag"

  class func refreshRemoteRuleSources() {
    let mgr = CoreDataManager.sharedInstance
    let fetchRequest = mgr.managedObjectModel!.fetchRequestTemplateForName("ThirdPartyRuleSources")
    do {
      let sources = try mgr.managedObjectContext!.executeFetchRequest(fetchRequest!)
      let enabledSources = (sources as! Array<RuleSource>).filter { $0.enabled!.boolValue }
      dlog("RuleSource.refreshRemoteRuleSources: \(enabledSources.count) sources")
      enabledSources.forEach { $0.refreshRules() }
    } catch {
      dlog("failed fetching: \(error)")
      abort()
    }

    //TODO: use ReactiveCocoa & flatMap everything: we can't run this until all remote sources are
    // refreshed
    //TODO: also, only do this if there have been actual rules changes.
    ContentRulesWriter().writeRules()
  }

  // fetch updated contents from a remote URL, and parse into local rules
  func refreshRules() {
    dlog("INFO: refreshing rules for \(name)")
    if !needsRefreshing() {
      dlog("INFO: rulesource \(name) does not need refreshing")
      return
    }
    if let parserType = parserClass() {
      if let url = url where nil == url.rangeOfString("localhost") {
        let coreDataCtx = CoreDataManager.sharedInstance.managedObjectContext!
        Alamofire.request(.GET, url)
          .responseString { _, response, result in
            dlog("INFO: got remote contents for \(self.name)")
            if !result.isSuccess {
              dlog("INFO: the response for \(self.name) does not indicate success: \(response)")
              return
            }
            // store etag (if present) for future use
            self.etag = response?.allHeaderFields[RuleSource.etagHeader] as! String?
            // parse returned rules
            if let contents = result.value {
              let parser = parserType.init(fileSource: contents)
              // destroy the old rules on this source
              if let oldRules = self.rules {
                oldRules.forEach { coreDataCtx.deleteObject($0 as! NSManagedObject) }
              }
              // parse the rules & save everything
              self.rules = NSOrderedSet(array: parser.parsedRules().map { (parsedRule) -> Rule in
                let rule = Rule(inContext: coreDataCtx, parsedRule: parsedRule)
                rule.source = self
                return rule
              })
              self.lastUpdatedAt = NSDate()
              dlog("rule source \(self.name) now has \(self.rules?.count) parsed rules")
              do {
                try coreDataCtx.save()
              } catch {
                dlog("save failed! \(error)")
                abort()
              }
            }
          }
      }
    }
  }

  private func parserClass() -> RuleFileParserProtocol.Type? {
    dlog("the parser for \(name) is \(parserType)")
    if nil == parserType {
      return nil
    }
    switch parserType! {
    case "ABPRuleFileParser":
      return ABPRuleFileParser.self
    case "HostFileParser":
      return HostFileParser.self
    default:
      return nil
    }
  }

  private func needsRefreshing() -> Bool {
    let updateWaitInterval = (60 * 60 * 6) as Double // 6 hours
    if let d = lastUpdatedAt {
      return (0 - d.timeIntervalSinceNow) > updateWaitInterval
      //TODO: we haven't updated in a while: if there's an ETAG, we can check it via a HEAD request
      //this is going to need some refactoring, though, since we need to go async
    } else {
      // no lastUpdatedAt means it's never been loaded
      return true
    }
  }
}
