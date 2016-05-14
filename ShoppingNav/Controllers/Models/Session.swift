//
//  Session.swift
//  ShoppingNav
//
//  Created by 	Lesha Zhuk on 5/8/16.
//  Copyright © 2016 	Lesha Zhuk. All rights reserved.
//

import Foundation
import CoreData

class Session: NSManagedObject {
    
    @NSManaged var id: NSNumber
    @NSManaged var session_name: String
    @NSManaged var wishLists: NSSet?
    @NSManaged var images: NSSet?
}
