//
//  AppDelegate_CoreData.swift
//  pblock
//
//  Created by Will Fleming on 7/10/15.
//  Copyright © 2015 Will Fleming. All rights reserved.
//

import Foundation
import CoreData

// a class to keep all the CoreData boilerplate out of the app delegate
class CoreDataManager: NSObject {
  static let sharedInstance = CoreDataManager()

  lazy var managedObjectModel: NSManagedObjectModel? = {
    let modelURL = NSBundle.mainBundle().URLForResource("Model", withExtension:"momd")
    if  nil == modelURL {
      return nil
    }
    return NSManagedObjectModel(contentsOfURL: modelURL!)
  }()

  lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
    let storeURL = self.appDocumentsDir()?.URLByAppendingPathComponent("pblock.CDBStore")
    let model = self.managedObjectModel

    if nil == model || nil == storeURL {
      return nil
    }

    let fm = NSFileManager.defaultManager()

    var coordinator = NSPersistentStoreCoordinator(managedObjectModel: model!)
    let opts = [
      NSMigratePersistentStoresAutomaticallyOption: true,
      NSInferMappingModelAutomaticallyOption: true
    ]
    do {
      try coordinator.addPersistentStoreWithType(NSSQLiteStoreType,
        configuration: nil, URL: storeURL, options: opts
      )
    } catch {
      dlog("error setting up persistent store: \(error)")
      exit(1) // exit immediately: things are bad
    }

    return coordinator
  }()

  lazy var managedObjectContext: NSManagedObjectContext? = {
    /* Returns the managed object context for the application (which is already bound to the
     * persistent store coordinator for the application.) This property is optional since there are
     * legitimate error conditions that could cause the creation of the context to fail.
     */
    let coordinator = self.persistentStoreCoordinator
    if coordinator == nil {
      return nil
    }

    var managedObjectContext = NSManagedObjectContext(
      concurrencyType: NSManagedObjectContextConcurrencyType.PrivateQueueConcurrencyType
    )
    managedObjectContext.persistentStoreCoordinator = coordinator
    return managedObjectContext
  }()

  func appDocumentsDir() -> NSURL? {
    return NSFileManager.defaultManager().URLsForDirectory(
      NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask
    ).last!
  }
}
