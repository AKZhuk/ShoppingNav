//
//  WishList.swift
//  ShoppingNav
//
//  Created by 	Lesha Zhuk on 5/8/16.
//  Copyright © 2016 	Lesha Zhuk. All rights reserved.
//

import Foundation
import CoreData


class WishList: NSManagedObject {
    @NSManaged var name: String
    @NSManaged var id: NSNumber
    @NSManaged var session: Session
}
