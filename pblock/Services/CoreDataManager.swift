//
//  AppDelegate_CoreData.swift
//  pblock
//
//  Created by Will Fleming on 7/10/15.
//  Copyright © 2015 PBlock. All rights reserved.
//

import Foundation
import CoreData

// a class to keep all the CoreData boilerplate out of the app delegate
class CoreDataManager: NSObject {
  static let sharedInstance = CoreDataManager()

  lazy var managedObjectModel: NSManagedObjectModel? = {
    if nil == self._memoModel {
      let modelURL = NSBundle.mainBundle().URLForResource("Model", withExtension:"momd")
      if  nil == modelURL {
        return nil
      }
      self._memoModel = NSManagedObjectModel(contentsOfURL: modelURL!)
    }
    return self._memoModel
  }()
  private var _memoModel: NSManagedObjectModel?

  lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
    if nil == self._memoStore {
      let storeURL = self.appDocumentsDir()?.URLByAppendingPathComponent("pblock.CDBStore")
      let model = self.managedObjectModel

      if nil == model || nil == storeURL {
        return nil
      }

      let fm = NSFileManager.defaultManager()

      self._memoStore = NSPersistentStoreCoordinator(managedObjectModel: model!)
      let opts = [
        NSMigratePersistentStoresAutomaticallyOption: true,
        NSInferMappingModelAutomaticallyOption: true
      ]
      do {
        try self._memoStore?.addPersistentStoreWithType(NSSQLiteStoreType,
          configuration: nil, URL: storeURL, options: opts
        )
      } catch {
        dlog("error setting up persistent store: \(error)")
        exit(1) // exit immediately: things are bad
      }
    }

    return self._memoStore
  }()
  private var _memoStore: NSPersistentStoreCoordinator?

  lazy var managedObjectContext: NSManagedObjectContext? = {
    /* Returns the managed object context for the application (which is already bound to the
     * persistent store coordinator for the application.) This property is optional since there are
     * legitimate error conditions that could cause the creation of the context to fail.
     */
    synchronized(self) {
      if nil == self._memoCtx {
        dlog("creating the main context")
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
          return
        }

        self._memoCtx = NSManagedObjectContext(
          concurrencyType: NSManagedObjectContextConcurrencyType.PrivateQueueConcurrencyType
        )
        self._memoCtx?.persistentStoreCoordinator = coordinator
      }
    }
    return self._memoCtx
  }()
  private var _memoCtx: NSManagedObjectContext?

  func childManagedObjectContext() -> NSManagedObjectContext? {
    let ctx = NSManagedObjectContext(
      concurrencyType: NSManagedObjectContextConcurrencyType.PrivateQueueConcurrencyType
    )
    ctx.parentContext = managedObjectContext
    return ctx
  }

  // when saving a child context, you also need to save the parent, and you need to block
  func saveContext(ctx: NSManagedObjectContext?) {
    func trySave(ctx: NSManagedObjectContext?, msg: String) {
      do {
        try ctx?.save()
      } catch {
        dlog("\(msg): \(error)")
      }
    }

    if ctx == managedObjectContext {
      trySave(ctx, msg: "saving the root context failed")
    } else if ctx?.parentContext == managedObjectContext {
      ctx?.performBlock {
        trySave(ctx, msg: "saving the child context failed")
        ctx?.parentContext?.performBlock {
          trySave(ctx?.parentContext, msg: "saving the root context failed")
        }
      }
    } else {
      assert(false, "you're doing something strange with your managed object contexts")
    }
  }

  private func appDocumentsDir() -> NSURL? {
    return NSFileManager.defaultManager().URLsForDirectory(
      NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask
    ).last!
  }
}
