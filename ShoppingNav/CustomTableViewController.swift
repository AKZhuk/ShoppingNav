//
//  CustomTableViewController.swift
//  ShoppingNav
//
//  Created by 	Lesha Zhuk on 5/9/16.
//  Copyright © 2016 	Lesha Zhuk. All rights reserved.
//


import UIKit
import CoreData

class CustomTableViewController: UITableViewController, NSFetchedResultsControllerDelegate, UIImagePickerControllerDelegate {
    
    var images: [Image] = []
    
    var fetchResultController: NSFetchedResultsController!
    var session = Session!.self
    var wishList: WishList!
    var sessionID:  NSNumber!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //print("jsdkjdsgks\(sessionID)")
        //print("c=\(wishList)")
        if( wishList == nil){
            print("wishList error")
        }

        let fetchRequest = NSFetchRequest(entityName: "Image")
        let ImageWishListPredicate = NSPredicate(format: "wishList = %@", wishList)
      fetchRequest.predicate = ImageWishListPredicate
        let sortDescriptor = NSSortDescriptor(key: "id", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        if let managedObjectContext = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext {
            fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
            fetchResultController.delegate = self
            
            do {
                try fetchResultController.performFetch()
                
                images = fetchResultController.fetchedObjects as! [Image]
            } catch {
                print(error)
            }
        }
        
        // Удалить title у кнопки  back
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
    }
    
    
    @IBAction func shomCamera(sender: AnyObject) {
       var lol = AddImageTableViewController()
        //lol.ShowCamera()
//        if UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary) {
//            let imagePicker = UIImagePickerController()
//            imagePicker.delegate = self
//                imagePicker.allowsEditing = false
//            imagePicker.sourceType = .PhotoLibrary
//            
//            self.presentViewController(imagePicker, animated: true, completion: nil)
//        }

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.hidesBarsOnSwipe = true
        prefersStatusBarHidden()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return images.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! CustomTableViewCell
        
        // Настройка ячейки
        cell.thumbnailImageView.image = UIImage(data: images[indexPath.row].image!)
        
        //cell.typeLabel.text = images[indexPath.row].type
        
        return cell
    }
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            if let _newIndexPath = newIndexPath {
                tableView.insertRowsAtIndexPaths([_newIndexPath], withRowAnimation: .Fade)
            }
        case .Delete:
            if let _newIndexPath = newIndexPath {
                tableView.deleteRowsAtIndexPaths([_newIndexPath], withRowAnimation: .Fade)
            }
        case .Update:
            if let _newIndexPath = newIndexPath {
                tableView.reloadRowsAtIndexPaths([_newIndexPath], withRowAnimation: .Fade)
            }
        default:
            tableView.reloadData()
        }
        images = controller.fetchedObjects as! [Image]
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
    
    // MARK: - Table view delegate
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        //Social
        let shareAction = UITableViewRowAction(style: .Default, title: "Share", handler: { (actin, indexPath) -> Void in
            let shareImages =  self.images[indexPath.row].image!
            var shareImage=[NSData]()
           
            for _ in self.images {
                shareImage.append(self.images[indexPath.row].image!)
            }

            let activityController = UIActivityViewController(activityItems: [shareImages], applicationActivities: nil)
            self.presentViewController(activityController, animated: true, completion: nil)
        })
        
        //Delete
        let deleteAction = UITableViewRowAction(style: .Default, title: "Delete", handler: {(actin, indexPath) -> Void in
            self.images.removeAtIndex(indexPath.row)
            
            if let managedObjectContext = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext {
                let restarauntToDelete = self.fetchResultController.objectAtIndexPath(indexPath) as! Image
                
                managedObjectContext.deleteObject(restarauntToDelete)
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                do {
                    try managedObjectContext.save()
                } catch {
                    print(error)
                }
            }

        })
        
        shareAction.backgroundColor = UIColor(red: 28.0/255.0, green: 165.0/255.0, blue: 253.0/255.0, alpha: 1.0)
        deleteAction.backgroundColor = UIColor(red: 202.0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 1.0)
        
        return [deleteAction, shareAction]
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowCamera" {
            var destination = segue.destinationViewController as? UIViewController
            if let navCon = destination as? UINavigationController {
                destination = navCon.visibleViewController
            }
            let upcoming: AddImageTableViewController = destination as! AddImageTableViewController
    	
            upcoming.wishList = wishList
            upcoming.sessionID =  self.sessionID
        }
    }

    
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    /*override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let destinationController = segue.destinationViewController as! DetailViewController
                destinationController.restaurant = images[indexPath.row]
            }
        }
    }*/
}

