//
//  Util.swift
//  ShoppingNav
//
//  Created by 	Lesha Zhuk on 15.05.16.
//  Copyright © 2016 	Lesha Zhuk. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class Util : NSObject, NSFetchedResultsControllerDelegate{
    
    var fetchResultController: NSFetchedResultsController!
     var images: [Image] = []
    
    func requestDB(entity: String, formatKey: Session) -> [Image]{
        let fetchRequest = NSFetchRequest(entityName: entity)
        let ImageWishListPredicate = NSPredicate(format: "session = %@", formatKey)
        fetchRequest.predicate = ImageWishListPredicate
        let sortDescriptor = NSSortDescriptor(key: "id", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        if let managedObjectContext = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext {
            fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
            self.fetchResultController.delegate = self
            
            do {
                try self.fetchResultController.performFetch()
               

                images = self.fetchResultController.fetchedObjects as! [Image]
               
                
            } catch {
                print(error)
            }

        }


   return images }
}