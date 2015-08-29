//
//  RuleSource+CoreDataProperties.swift
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

extension RuleSource {

    @NSManaged var enabled: NSNumber?
    @NSManaged var name: String?
    @NSManaged var parserType: String?
    @NSManaged var url: String?
    @NSManaged var lastUpdatedAt: NSDate?
    @NSManaged var etag: String?
    @NSManaged var rules: NSOrderedSet?

}
