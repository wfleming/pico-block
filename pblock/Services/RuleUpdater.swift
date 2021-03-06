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
  private var coreDataCtx: NSManagedObjectContext

  class func forAllEnabledSources() -> RuleUpdater {
    let mgr = CoreDataManager.sharedInstance
    let fetchRequest = mgr.managedObjectModel!.fetchRequestTemplateForName("ThirdPartyRuleSources")
    do {
      let ctx = mgr.childManagedObjectContext()!
      let sources = try ctx.executeFetchRequest(fetchRequest!)
      let enabledSources = (sources as! Array<RuleSource>).filter {
        if let b = $0.enabled?.boolValue {
          return b
        } else {
          // NOTE: I don't think this is happening anymore (using a child context fixed it):
          // going to leave this logging for a while in case it reoccurs.
          // consider record with enabled => nil to be disabled: this shouldn't happen, though?
          dlog("source \($0.name) had unexpected nil enabled  \($0)")
          return false
        }
      }
      dlog("\(enabledSources.count) sources")
      return self.init(ctx: ctx, sources: enabledSources)
    } catch {
      dlog("failed fetching: \(error)")
      abort()
    }
  }

  required init(ctx: NSManagedObjectContext, sources: Array<RuleSource>) {
    self.coreDataCtx = ctx
    self.sources = sources
  }

  // constructs a signal that encapsulates all update logic: this signal will emit an integer
  // which is the number of rule soures that actually fetched & parsed new rules.
  func doUpdate() -> RACSignal {
    return RACSignal.zip(self.sources.map { updateSource($0) })
      .map({ (val: AnyObject!) -> AnyObject! in
        if let nextTuple = val as? RACTuple {
          return nextTuple.allObjects().reduce(0,
            combine: { (sum: Int, updated: AnyObject) -> Int in
              if let updatedBool = updated as? Bool where updatedBool {
                return sum + 1
              } else {
                return sum
              }
            })
        } else {
          return 0
        }
      })
  }

  // construct a signal for a source that emits whether the rule needs updating
  func sourceNeedsUpdate(source: RuleSource) -> RACSignal {
    assert(!source.fault, "PROBLEM: fault is not firing \(source)")

    return RACSignal.createSignal({ (sub: RACSubscriber!) -> RACDisposable! in
      var urlFetch: Request?
      if let d = source.lastUpdatedAt {
        let isOld = (0 - d.timeIntervalSinceNow) > self.updateWaitInterval
        if isOld {
          if let etag = source.etag where etag.characters.count > 0 {
            // fetch the HEAD of the url, compare etag
            urlFetch = Alamofire.request(.HEAD, source.url!)
              .response(queue: dispatch_get_global_queue(QOS_CLASS_UTILITY, 0),
                responseSerializer: Request.stringResponseSerializer(),
                completionHandler: { (_, response, _) in
                    var cacheExpired = true
                    if let respEtag = response?.allHeaderFields[self.etagHeader] as! String? {
                      if respEtag.characters.count > 0 {
                        cacheExpired = respEtag != etag
                      }
                    }
                    sub.sendNext(cacheExpired)
                    sub.sendCompleted()
                })
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
      .response(queue: dispatch_get_global_queue(QOS_CLASS_UTILITY, 0),
        responseSerializer: Request.stringResponseSerializer(),
        completionHandler: { _, response, result in
          dlog("got response for contents of \(source.name)")
          if !result.isSuccess {
            dlog("the response for \(source.name) does not indicate success: \(response)")
            subscriber.sendNext(false)
            subscriber.sendCompleted()
            return
          }
          // store caching info on rule source
          source.lastUpdatedAt = NSDate()
          source.etag = response?.allHeaderFields[self.etagHeader] as! String?
          CoreDataManager.sharedInstance.saveContext(self.coreDataCtx)
          // parse returned rules
          if let contents = result.value {
            self.parseNewRules(source.objectID, contents, subscriber)
          }
        })
  }

  func parseNewRules(sourceId: NSManagedObjectID, _ contents: String, _ subscriber: RACSubscriber) {
    defer {
      subscriber.sendNext(true)
      subscriber.sendCompleted()
    }
    // because this runs in yet another thread, it needs its own
    let childCtx = CoreDataManager.sharedInstance.childManagedObjectContext()!
    let source = childCtx.objectWithID(sourceId) as! RuleSource
    let parserClass = source.parserClass()!
    let parser = parserClass.init(fileSource: contents)
    // destroy the old rules on this source
    if let oldRules = source.rules {
      oldRules.forEach { childCtx.deleteObject($0 as! NSManagedObject) }
    }
    // parse the rules & save everything
    source.rules = NSOrderedSet(array: parser.parsedRules().map { (parsedRule) -> Rule in
      let rule = Rule(inContext: childCtx, parsedRule: parsedRule)
      rule.source = source
      return rule
      })
    source.lastUpdatedAt = NSDate()
    dlog("rule source \(source.name) now has \(source.rules?.count) parsed rules")
    CoreDataManager.sharedInstance.saveContext(childCtx)
  }
}