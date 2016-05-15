//
//  SessionsTableViewController.swift
//  ShoppingNav
//
//  Created by 	Lesha Zhuk on 5/8/16.
//  Copyright © 2016 	Lesha Zhuk. All rights reserved.
//

import UIKit
import CoreData
import Social

class SessionTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    
    var sessions: [Session] = []
    var images: [Image] = []
    var shareImage: [AnyObject]=[]
    var fetchResultController: NSFetchedResultsController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refresh()
        
    }
    
    var newSessionName = ""
        {
        didSet {
                if( newSessionName == "" )
            {
                mistakeAlert("Write something!")
                
            }else {
                addSessionToStorage(newSessionName)
                refresh()
                
            }
        }
    }
    
    func addSessionToStorage(sessionName: String)
    {
        if let managedObjectContext = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext {
            let sessionContext = NSEntityDescription.insertNewObjectForEntityForName("Session", inManagedObjectContext: managedObjectContext) as! Session
            
            sessionContext.session_name = sessionName
            sessionContext.id = sessions.count
            
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
        let fetchRequest = NSFetchRequest(entityName: "Session")
        let sortDescriptor = NSSortDescriptor(key: "id", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        if let managedObjectContext = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext {
            fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
            fetchResultController.delegate = self
            
            do {
                try fetchResultController.performFetch()
            
               
                sessions = fetchResultController.fetchedObjects as! [Session]
            
            
                
            } catch {
                print(error)
            }
        }
        self.tableView.reloadData()
    }
    
    @IBAction func newSession(sender: AnyObject) {
        
        let alert = UIAlertController(title: "Session Name", message: "Enter a text", preferredStyle: .Alert)
        alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
           
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action: UIAlertAction!) in
    
        }))
        alert.addAction(UIAlertAction(title: "Submit", style: .Default, handler: { (action) -> Void in
            let textField = alert.textFields![0] as UITextField
            self.newSessionName = textField.text!
            
            
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
  
        func alertForSessionName() -> Void
    {
        
    }
    
    func mistakeAlert(mistakeText: String)
    {
        let alert = UIAlertController(title: "Mistake", message: mistakeText, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler:nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    var indexEditSession: NSIndexPath?
    var editSessionName = ""
        {
        didSet{
            if(editSessionName == ""){
                mistakeAlert("Edit something!")
            }else {
                editSession(editSessionName, indexPath: self.indexEditSession!)
                tableView.reloadRowsAtIndexPaths([self.indexEditSession!], withRowAnimation: .Fade)
            }
        }
    }
    
    func editSession(editSessionName: String, indexPath: NSIndexPath)
    {
        if let managedObjectContext = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext {
            let sessionToEdit = self.fetchResultController.objectAtIndexPath(indexPath) as! Session
            sessionToEdit.setValue(editSessionName, forKey: "session_name")
            
            do {
                try managedObjectContext.save()
            } catch {
                print(error)
            }
        }
    }
    
    func alertEditSession(defaultText: String)
    {
        
        let alert = UIAlertController(title: "Session Name", message: "Write a sassion name", preferredStyle: .Alert)
        alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
            textField.text = defaultText
        })
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            let textField = alert.textFields![0] as UITextField
            self.editSessionName = textField.text!
            
        }))
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return sessions.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cellSession", forIndexPath: indexPath) as! SessionTableViewCell
        cell.sessionName.text = self.sessions[indexPath.row].session_name
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showSession" {
        var destination = segue.destinationViewController
          if let navCon = destination as? UINavigationController {
                destination = navCon.visibleViewController!
            }
            let upcoming: WishListTableViewController = destination as! WishListTableViewController
            let indexPath = self.tableView.indexPathForSelectedRow!
            upcoming.sessionID=self.sessions[indexPath.row].id
            upcoming.session = self.sessions[indexPath.row]
            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
    
            
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
       
        
        let deleteAction = UITableViewRowAction(style: .Default, title: "Delete", handler: {(actin, indexPath) -> Void in
            self.sessions.removeAtIndex(indexPath.row)
            
            if let managedObjectContext = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext {
                let sessionToDelete = self.fetchResultController.objectAtIndexPath(indexPath) as! Session
                
                managedObjectContext.deleteObject(sessionToDelete)
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                do {
                    try managedObjectContext.save()
                } catch {
                    print(error)
                }
            }
        })

        
        
        
       
            let shareAction = UITableViewRowAction(style: .Default, title: "Share", handler: { (actin, indexPath) -> Void in
                //            var aaa=self.sessions[indexPath.row]
                //            let imag=Util.requestDB("Image", format: Image.Session, formatKey: aaa, sessionController: self)

        
            let fetchRequest = NSFetchRequest(entityName: "Image")
            let ImageWishListPredicate = NSPredicate(format: "session = %@", self.sessions[indexPath.row])
            fetchRequest.predicate = ImageWishListPredicate
            let sortDescriptor = NSSortDescriptor(key: "id", ascending: true)
            fetchRequest.sortDescriptors = [sortDescriptor]
            
            if let managedObjectContext = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext {
                self.fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
                self.fetchResultController.delegate = self

                do {
                    try self.fetchResultController.performFetch()
                    
                    self.images = self.fetchResultController.fetchedObjects as! [Image]
                    
                    
                } catch {
                    print(error)
                }
            }
        
            for img in self.images{
                self.shareImage.append(img.image!)
            }
            
                                
                
            let activityController = UIActivityViewController(activityItems: self.shareImage, applicationActivities: nil)
            self.presentViewController(activityController, animated: true, completion: nil)
        }
        
        )
        
        let editAction = UITableViewRowAction(style : .Default, title: "Rename", handler: {(actin, indexPath) -> Void in
            self.indexEditSession = indexPath
            self.alertEditSession(self.sessions[indexPath.row].session_name)
            
        })
        
        deleteAction.backgroundColor = Util.backgroundColor().0
        shareAction.backgroundColor = Util.backgroundColor().1
        editAction.backgroundColor  = Util.backgroundColor().2
                
        return [deleteAction, shareAction, editAction]
    }
}
