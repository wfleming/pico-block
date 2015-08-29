//
//  RuleSource+CoreDataProperties.swift
//  pblock
//
//  Created by Will Fleming on 8/22/15.
//  Copyright © 2015 PBlock. All rights reserved.
//
//  Delete this file and regenerate it using "Create NSManagedObject Subclass…"
//  to keep your implementation up to date with your model.
//

import Foundation
import CoreData

extension RuleSource {

    @NSManaged var enabled: NSNumber?
    @NSManaged var name: String?
    @NSManaged var url: String?
    @NSManaged var parserType: String?
    @NSManaged var rules: NSOrderedSet?

}
