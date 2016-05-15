//
//  Image.swift
//  ShoppingNav
//
//  Created by 	Lesha Zhuk on 5/9/16.
//  Copyright © 2016 	Lesha Zhuk. All rights reserved.
//
import Foundation
import CoreData


class Image: NSManagedObject {
    @NSManaged var image: NSData?
    @NSManaged var id: NSNumber?
    @NSManaged var sessionID: NSNumber
    @NSManaged var lantitude: NSNumber
    @NSManaged var lontitude: NSNumber
    @NSManaged var wishList: WishList
    @NSManaged var session: Session
}