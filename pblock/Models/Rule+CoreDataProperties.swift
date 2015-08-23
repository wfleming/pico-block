//
//  Rule+CoreDataProperties.swift
//  pblock
//
//  Created by Will Fleming on 8/22/15.
//  Copyright © 2015 Will Fleming. All rights reserved.
//
//  Delete this file and regenerate it using "Create NSManagedObject Subclass…"
//  to keep your implementation up to date with your model.
//

import Foundation
import CoreData

extension Rule {

    @NSManaged var actionSelector: String?
    @NSManaged var actionTypeRaw: NSNumber?
    @NSManaged var sourceText: String?
    @NSManaged var triggerLoadTypeRaw: NSNumber?
    @NSManaged var triggerResourceTypeRaw: NSNumber?
    @NSManaged var triggerUrlFilter: String?
    @NSManaged var unsupported: NSNumber?
    @NSManaged var source: RuleSource?
    @NSManaged var triggerIfDomain: NSOrderedSet?
    @NSManaged var triggerUnlessDomain: NSOrderedSet?

}
