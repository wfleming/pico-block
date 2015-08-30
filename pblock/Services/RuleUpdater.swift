//
//  RuleUpdater.swift
//  pblock
//
//  Created by Will Fleming on 8/30/15.
//  Copyright © 2015 PBlock. All rights reserved.
//

import Foundation
import Alamofire
import ReactiveCocoa
import CoreData

class RuleUpdater {
  private let etagHeader = "ETag"
  let updateWaitInterval = (60 * 60 * 6) as Double // 6 hours
  private var sources: Array<RuleSource>

  class func forAllEnabledSources() -> RuleUpdater {
    let mgr = CoreDataManager.sharedInstance
    let fetchRequest = mgr.managedObjectModel!.fetchRequestTemplateForName("ThirdPartyRuleSources")
    do {
      let sources = try mgr.managedObjectContext!.executeFetchRequest(fetchRequest!)
      let enabledSources = (sources as! Array<RuleSource>).filter {
        if let b = $0.enabled?.boolValue {
          return b
        } else {
          // consider record with enabled => nil to be disabled: this shouldn't happen, though?
          dlog("RuleUpdater: source \($0.name) had unexpected nil enabled")
          return false
        }
      }
      dlog("RuleUpdater.forAllEnabledSources: \(enabledSources.count) sources")
      return self.init(sources: enabledSources)
    } catch {
      dlog("RuleUpdater.forAllEnabledSources failed fetching: \(error)")
      abort()
    }
  }

  required init(sources: Array<RuleSource>) {
    self.sources = sources
  }

  // constructs a signal that encapsulates all update logic: this signal will emit an integer
  // which is the number of rule soures that actually fetched & parsed new rules.
  func doUpdate() -> RACSignal {
    return RACSignal.zip(self.sources.map { updateSource($0) }).scanWithStart(0,
      reduce: { (memo: AnyObject!, next: AnyObject!) -> AnyObject! in
        let memoInt = memo as! Int
        if let nextTuple = next as? RACTuple {
          return nextTuple.allObjects().reduce(0,
            combine: { (sum: Int, updated: AnyObject) -> Int in
              if let updatedBool = updated as? Bool where updatedBool {
               return sum + 1
              } else {
                return sum
              }
            })
        }
        return memoInt
      })
  }

  // construct a signal for a source that emits whether the rule needs updating
  func sourceNeedsUpdate(source: RuleSource) -> RACSignal {
    return RACSignal.createSignal({ (sub: RACSubscriber!) -> RACDisposable! in
      var urlFetch: Request?
      if let d = source.lastUpdatedAt {
        let isOld = (0 - d.timeIntervalSinceNow) > self.updateWaitInterval
        if isOld {
          if let etag = source.etag where etag.characters.count > 0 {
            // fetch the HEAD of the url, compare etag
            urlFetch = Alamofire.request(.HEAD, source.url!)
              .response { (_, response, _, _) in
                var cacheExpired = true
                if let respEtag = response?.allHeaderFields[self.etagHeader] as! String? {
                  if respEtag.characters.count > 0 {
                    cacheExpired = respEtag != etag
                  }
                }
                sub.sendNext(cacheExpired)
                sub.sendCompleted()
            }
          } else {
            // we haven't updated in a while, and don't have a cache header to check, so return true
            sub.sendNext(true)
            sub.sendCompleted()
          }
        } else {
          // we've been updated fairly recently, don't bother checking etag
          sub.sendNext(false)
          sub.sendCompleted()
        }
      } else {
        // no lastUpdatedAt means it's never been loaded
        sub.sendNext(true)
        sub.sendCompleted()
      }

      return RACDisposable {
        urlFetch?.cancel()
      }
    })
  }

  func updateSource(source: RuleSource) -> RACSignal {
    var urlFetch: Request?
    return RACSignal.createSignal({ (sub: RACSubscriber!) -> RACDisposable! in
      self.sourceNeedsUpdate(source).subscribeNext({ (needsUpdateObj: AnyObject!) -> Void in
        if let needsUpdate = needsUpdateObj as? Bool where needsUpdate {
          if let url = source.url where nil == url.rangeOfString("localhost") {
            urlFetch = self.reqSourceContents(source, sub)
          } else {
            sub.sendNext(false)
            sub.sendCompleted()
          }
        } else {
          sub.sendNext(false)
          sub.sendCompleted()
        }
      })

      return RACDisposable {
        urlFetch?.cancel()
      }
    })
  }

  func reqSourceContents(source: RuleSource, _ subscriber: RACSubscriber) -> Request {
    return Alamofire.request(.GET, source.url!)
      .responseString { _, response, result in
        dlog("RuleUpdater: got response for contents of \(source.name)")
        if !result.isSuccess {
          dlog("RuleUpdater: the response for \(source.name) does not indicate success: \(response)")
          subscriber.sendNext(false)
          subscriber.sendCompleted()
          return
        }
        // store etag (if present) for future use
        source.etag = response?.allHeaderFields[self.etagHeader] as! String?
        // parse returned rules
        if let contents = result.value {
          self.parseNewRules(source, contents, subscriber)
        }
      }
  }

  func parseNewRules(source: RuleSource, _ contents: String, _ subscriber: RACSubscriber) {
    defer {
      subscriber.sendNext(true)
      subscriber.sendCompleted()
    }
    let coreDataCtx = CoreDataManager.sharedInstance.managedObjectContext!
    let parserClass = source.parserClass()!
    let parser = parserClass.init(fileSource: contents)
    // destroy the old rules on this source
    if let oldRules = source.rules {
      oldRules.forEach { coreDataCtx.deleteObject($0 as! NSManagedObject) }
    }
    // parse the rules & save everything
    source.rules = NSOrderedSet(array: parser.parsedRules().map { (parsedRule) -> Rule in
      let rule = Rule(inContext: coreDataCtx, parsedRule: parsedRule)
      rule.source = source
      return rule
      })
    source.lastUpdatedAt = NSDate()
    dlog("rule source \(source.name) now has \(source.rules?.count) parsed rules")
    do {
      try coreDataCtx.save()
    } catch {
      dlog("save failed! \(error)")
      abort()
    }
  }
}