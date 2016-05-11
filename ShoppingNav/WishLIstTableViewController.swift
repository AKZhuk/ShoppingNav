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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if( session != nil){
            refresh()
        }
        
    }
    
    @IBAction func addWishList(sender: AnyObject) {
            let alert = UIAlertController(title: "WishList Name", message: "Enter a text", preferredStyle: .Alert)
        alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
            textField.text = "Add wishList"
        })
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
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
    
    func addWishListToStorage(WishListName: String)
    {
        if let managedObjectContext = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext {
            let WishListContext = NSEntityDescription.insertNewObjectForEntityForName("WishList", inManagedObjectContext: managedObjectContext) as! WishList
            
            WishListContext.name = WishListName
            WishListContext.session = session
            
            do {
                try managedObjectContext.save()
            } catch {
                print(error)
                return
            }
        }
        
    }
    
    func isNameValid(newName: String) -> Bool
    {
        //        let newSession = Session()
        //        newSession.session_name = newName
        //        newSession.id = sessions.count
        //        if sessions.contains(newSession) {
        //            return false;
        //        }else{
        //            return true;
        //        }
        return true;
    }
    
    func refresh()
    {
        let fetchRequest = NSFetchRequest(entityName: "WishList")
        let WishListSessionPredicate = NSPredicate(format: "session == %@", session)
        fetchRequest.predicate = WishListSessionPredicate
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        if let managedObjectContext = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext {
            fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
            fetchResultController.delegate = self
            
            do {
                try fetchResultController.performFetch()
                WishLists = fetchResultController.fetchedObjects as! [WishList]
            } catch {
                print(error)
            }
        }
        self.tableView.reloadData()
    }
    
    
    
    
    func mistakeAlert(mistakeText: String)
    {
        let alert = UIAlertController(title: "Mistake", message: mistakeText, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler:nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    var indexEditWishList: NSIndexPath?
    var editWishListName = ""
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
            let sessionToEdit = self.fetchResultController.objectAtIndexPath(indexPath) as! WishList
            sessionToEdit.setValue(editWishListName, forKey: "name")
            
            do {
                try managedObjectContext.save()
            } catch {
                print(error)
            }
        }
    }
    
    func alertEditSession(defaultText: String)
    {
        
        let alert = UIAlertController(title: "Session Name", message: "Enter a text", preferredStyle: .Alert)
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
            
             var destination = segue.destinationViewController as? UIViewController
             if let navCon = destination as? UINavigationController {
             destination = navCon.visibleViewController
             }
            /*
             let upcoming: CustomTableViewController = destination as! CustomTableViewController
             let indexPath = self.tableView.indexPathForSelectedRow!
             upcoming.Wish = self.WishLists[indexPath.row]
             self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
            
            */
            
            let upcoming: CustomTableViewController = segue.destinationViewController as! CustomTableViewController
            let indexPath = self.tableView.indexPathForSelectedRow!
            let a = WishLists[indexPath.row]
            print("\(a)")
            upcoming.WishLis = WishLists[indexPath.row]
            
            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        //Social
        let shareAction = UITableViewRowAction(style: .Default, title: "Share", handler: { (actin, indexPath) -> Void in
            let defaultText = "Just checking in at " + self.WishLists[indexPath.row].name
            let activityController = UIActivityViewController(activityItems: [defaultText], applicationActivities: nil)
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
        
        //Edit
        let editAction = UITableViewRowAction(style : .Default, title: "Edit", handler: {(actin, indexPath) -> Void in
            self.indexEditWishList = indexPath
            self.alertEditSession(self.WishLists[indexPath.row].name)
            
        })
        
        shareAction.backgroundColor = UIColor(red: 28.0/255.0, green: 165.0/255.0, blue: 253.0/255.0, alpha: 1.0)
        deleteAction.backgroundColor = UIColor(red: 202.0/255.0, green: 202.0/255.0, blue: 203.0/255.0, alpha: 1.0)
        editAction.backgroundColor  = UIColor(red: 102.0/255.0, green: 102.0/255.0, blue: 3.0/255.0, alpha: 1.0)
        
        return [deleteAction, shareAction, editAction]
    }
    
    
    
}
