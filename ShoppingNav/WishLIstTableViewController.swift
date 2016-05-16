//
//  WishLIstTableViewController.swift
//  ShoppingNav
//
//  Created by 	Lesha Zhuk on 5/8/16.
//  Copyright © 2016 	Lesha Zhuk. All rights reserved.

import UIKit
import CoreData

class WishListTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    var WishLists: [WishList] = []
    var fetchResultController: NSFetchedResultsController!
    
    @IBOutlet weak var WishListLabel: UILabel!
    var session: Session!
    var sessionID: NSNumber!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        if( session != nil){
            refresh()
        }
        
    }
    
    @IBAction func addWishList(sender: AnyObject) {
            let alert = UIAlertController(title: "WishList Name", message: "Enter a text", preferredStyle: .Alert)
        alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
            
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action: UIAlertAction!) in
            print("Handle Cancel Logic here")
        }))
        
        alert.addAction(UIAlertAction(title: "Submit", style: .Default, handler: { (action) -> Void in
            let textField = alert.textFields![0] as UITextField
            self.newWishListName = textField.text!
            
            
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    var newWishListName = ""
        {
        didSet {
            if( newWishListName == "" )
            {
                mistakeAlert("WishList name would consist some value")
                
            }else {
                addWishListToStorage(newWishListName)
                refresh()
                
            }
        }
    }
    
    func mistakeAlert(mistakeText : String)
    {
        let alert = UIAlertController(title: "Mistake", message: mistakeText, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler:nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }

    
    
    func addWishListToStorage(WishListName: String)
    {
        if let managedObjectContext = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext {
            let WishListContext = NSEntityDescription.insertNewObjectForEntityForName("WishList", inManagedObjectContext: managedObjectContext) as! WishList
            
            WishListContext.name = WishListName
            WishListContext.id = WishLists.count
            WishListContext.session = session
            
            do {
                try managedObjectContext.save()
            } catch {
                print(error)
                return
            }
        }
        
    }
    
    
    func refresh()
    {
        let fetchRequest = NSFetchRequest(entityName: "WishList")
        let WishListSessionPredicate = NSPredicate(format: "session == %@", session)
        fetchRequest.predicate = WishListSessionPredicate
        let sortDescriptor = NSSortDescriptor(key: "id", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        if let managedObjectContext = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext {
            fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
            fetchResultController.delegate = self
            
            do {
                try fetchResultController.performFetch()
                WishLists = fetchResultController.fetchedObjects as! [WishList]
               // print("\(WishLists)")
            } catch {
                print(error)
            }
        }
        self.tableView.reloadData()
    }
    
   //mistake
    var indexEditWishList: NSIndexPath?
    var editWishListName = "111"
        {
        didSet{
            if(editWishListName == ""){

                mistakeAlert("WishList name would consist some value")
            }else {
                editWishList(editWishListName, indexPath: self.indexEditWishList!)
                tableView.reloadRowsAtIndexPaths([self.indexEditWishList!], withRowAnimation: .Fade)
            }
            
        }
        
    }
    
    func editWishList(editSessionName: String, indexPath: NSIndexPath)
    {
        if let managedObjectContext = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext {
            let wishListToEdit = self.fetchResultController.objectAtIndexPath(indexPath) as! WishList
            wishListToEdit.setValue(editWishListName, forKey: "name")
            
            do {
                try managedObjectContext.save()
            } catch {
                print(error)
            }
        }
    }
   
    func alertEditSession(defaultText: String)
    {
        
        let alert = UIAlertController(title: "Wish List Name", message: "Enter a text", preferredStyle: .Alert)
        alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
            textField.text = defaultText
        })
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            let textField = alert.textFields![0] as UITextField
            self.editWishListName = textField.text!
            
        }))
        self.presentViewController(alert, animated: true, completion: nil)
        
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
        // #warning Incomplete implementation, return the number of rows
        return WishLists.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cellWishList", forIndexPath: indexPath) as! WishListTableViewCell
        cell.WishListName.text = self.WishLists[indexPath.row].name
        
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showImages" {
            
             var destination = segue.destinationViewController 
             if let navCon = destination as? UINavigationController {
             destination = navCon.visibleViewController!
             }
            let upcoming:CustomTableViewController = destination as! CustomTableViewController
            
            let indexPath = self.tableView.indexPathForSelectedRow!
            
            upcoming.wishList = self.WishLists[indexPath.row]
           // upcoming.sessionID=self.session.id
            upcoming.session=session
            
            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        //Social
        let shareAction = UITableViewRowAction(style: .Default, title: "Share", handler: { (actin, indexPath) -> Void in
            let defaultText = "Just checking in at " + self.WishLists[indexPath.row].name
            let activityController = UIActivityViewController(activityItems: [defaultText], applicationActivities: nil)
            if (activityController.popoverPresentationController != nil) {
                activityController.popoverPresentationController!.sourceView = self.tableView.cellForRowAtIndexPath(indexPath)
                
                activityController.popoverPresentationController!.sourceRect = CGRect(
                    x: 250,
                    y: 130,
                    width: 1,
                    height: 1)
            }

    
            self.presentViewController(activityController, animated: true, completion: nil)
        })
        
        //Delete
        let deleteAction = UITableViewRowAction(style: .Default, title: "Delete", handler: {(actin, indexPath) -> Void in
            self.WishLists.removeAtIndex(indexPath.row)
            
            if let managedObjectContext = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext {
                let sessionToDelete = self.fetchResultController.objectAtIndexPath(indexPath) as! WishList
                
                managedObjectContext.deleteObject(sessionToDelete)
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                do {
                    try managedObjectContext.save()
                } catch {
                    print(error)
                }
            }
        })
        
        //Rename
        let editAction = UITableViewRowAction(style : .Default, title: "Rename", handler: {(actin, indexPath) -> Void in
            self.indexEditWishList = indexPath
            self.alertEditSession(self.WishLists[indexPath.row].name)
            
        })
        
        shareAction.backgroundColor = Util.backgroundColor().0
        deleteAction.backgroundColor = Util.backgroundColor().1
        editAction.backgroundColor  = Util.backgroundColor().2
        
        return [deleteAction, shareAction, editAction]
    }
    
    
    
}
