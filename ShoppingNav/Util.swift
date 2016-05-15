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
    
    static var fetchResultController: NSFetchedResultsController!
    
    class func backgroundColor()-> (UIColor,UIColor,UIColor){
    
        
        let deleteActionColor = UIColor(red: 202.0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 2.0)
        let shareActionColor = UIColor(red: 28.0/255.0, green: 165.0/255.0, blue: 253.0/255.0, alpha: 1.0)
       let  editActionColor  = UIColor(red: 217/255.0, green: 72/255.0, blue: 20/255.0, alpha: 1.0)
        return(deleteActionColor,shareActionColor,editActionColor)
    }
    
    class func requestDB(entity: String, format:Session ,formatKey: Session, sessionController: SessionTableViewController) -> Array<Image>{
        var images: [Image] = []
        let fetchRequest = NSFetchRequest(entityName: entity)
        let ImageWishListPredicate = NSPredicate(format: "\(format) = %@", formatKey)
        fetchRequest.predicate = ImageWishListPredicate
        let sortDescriptor = NSSortDescriptor(key: "id", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        if let managedObjectContext = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext {
            fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
            sessionController.fetchResultController.delegate = sessionController
            
            do {
                try sessionController.fetchResultController.performFetch()
               

                var images = sessionController.fetchResultController.fetchedObjects as! [Image]
                print(images[2].session)
            } catch {
                print(error)
            }
        }
        var lol: [String] = []
        lol = ["ololo","lol","ololo"]
        for l in lol { print(l)}
        for _ in images{ print(images[2].id) }
   return images }
}