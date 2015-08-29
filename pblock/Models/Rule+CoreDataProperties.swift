//
//  Rule+CoreDataProperties.swift
//  pblock
//
//  Created by Will Fleming on 8/29/15.
//  Copyright © 2015 PBlock. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
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
