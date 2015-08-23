//
//  NSManagedObject+pblock.swift
//  pblock
//
//  Created by Will Fleming on 7/10/15.
//  Copyright © 2015 Will Fleming. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObject {
  convenience init(inContext managedObjectContext: NSManagedObjectContext) {
    let model = managedObjectContext.persistentStoreCoordinator?.managedObjectModel
    let entity = self.dynamicType.mappedEntityDescription(model)

    if nil != entity {
      self.init(entity: entity!, insertIntoManagedObjectContext:managedObjectContext)
    } else {
      // this is going to fail spectacularly: abort immediately, but also call init to make
      // the compiler happy
      dlog("FATAL: could not find the correct entity in \(managedObjectContext)")
      abort()
      //self.init(entity:NSEntityDescription(), insertIntoManagedObjectContext:managedObjectContext)
    }
  }

  class func mappedEntityDescription(model: NSManagedObjectModel?) -> NSEntityDescription? {
    let matchedEntity = model?.entities.filter({ (entity) -> Bool in
      return entity.managedObjectClassName == NSStringFromClass(object_getClass(self))
    }).first
    return matchedEntity
  }
}
