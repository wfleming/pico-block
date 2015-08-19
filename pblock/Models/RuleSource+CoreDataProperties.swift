//
//  RuleSource+CoreDataProperties.swift
//  pblock
//
//  Created by Will Fleming on 7/13/15.
//  Copyright © 2015 Will Fleming. All rights reserved.
//
//  Delete this file and regenerate it using "Create NSManagedObject Subclass…"
//  to keep your implementation up to date with your model.
//

import Foundation
import CoreData

extension RuleSource {

    @NSManaged var enabled: NSNumber?
    @NSManaged var url: String?
    @NSManaged var rules: NSOrderedSet?

}