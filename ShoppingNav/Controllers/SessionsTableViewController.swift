//
//  SessionsTableViewController.swift
//  ShoppingNav
//
//  Created by 	Lesha Zhuk on 5/8/16.
//  Copyright © 2016 	Lesha Zhuk. All rights reserved.
//

import UIKit
import CoreData

class SessionTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    
    var sessions: [Session] = []
    var fetchResultController: NSFetchedResultsController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refresh()
        
    }
    
    var newSessionName = ""
        {
        didSet {
            
            //            if isNameValid()
            //            {
            if( newSessionName == "" )
            {
                mistakeAlert("Session name would consist some value")
                
            }else {
                addSessionToStorage(newSessionName)
                refresh()
                
            }
            
            //            }else {
            //                mistakeAlert("This name has already been. Please, enter uniqe name")
            //            }
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
            textField.text = "Pretty Molly"
        })
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            let textField = alert.textFields![0] as UITextField
            self.newSessionName = textField.text!
            
            
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    /*@IBAction func 1newSession(sender: AnyObject) {
        let alert = UIAlertController(title: "Session Name", message: "Enter a text", preferredStyle: .Alert)
        alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
            textField.text = "Pretty Molly"
        })
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            let textField = alert.textFields![0] as UITextField
            self.newSessionName = textField.text!
            
            
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }*/
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
                mistakeAlert("Session name would consist some value")
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
        
        let alert = UIAlertController(title: "Session Name", message: "Enter a text", preferredStyle: .Alert)
        alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
            textField.text = defaultText
        })
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            let textField = alert.textFields![0] as UITextField
            self.editSessionName = textField.text!
            
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
        return sessions.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cellSession", forIndexPath: indexPath) as! SessionTableViewCell
        cell.sessionName.text = self.sessions[indexPath.row].session_name
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showSession" {
            var destination = segue.destinationViewController as? UIViewController
            if let navCon = destination as? UINavigationController {
                destination = navCon.visibleViewController
            }
           // let upcoming: WishListTableViewController = destination as! WishListTableViewController
            let indexPath = self.tableView.indexPathForSelectedRow!
            //upcoming.session = self.sessions[indexPath.row]
            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        //Social
        let shareAction = UITableViewRowAction(style: .Default, title: "Share", handler: { (actin, indexPath) -> Void in
            let defaultText = "Just checking in at " + self.sessions[indexPath.row].session_name
            let activityController = UIActivityViewController(activityItems: [defaultText], applicationActivities: nil)
            self.presentViewController(activityController, animated: true, completion: nil)
        })
        
        //Delete
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
        
        //Edit
        let editAction = UITableViewRowAction(style : .Default, title: "Edit", handler: {(actin, indexPath) -> Void in
            self.indexEditSession = indexPath
            self.alertEditSession(self.sessions[indexPath.row].session_name)
            
        })
        
        shareAction.backgroundColor = UIColor(red: 28.0/255.0, green: 165.0/255.0, blue: 253.0/255.0, alpha: 1.0)
        deleteAction.backgroundColor = UIColor(red: 202.0/255.0, green: 202.0/255.0, blue: 203.0/255.0, alpha: 1.0)
        editAction.backgroundColor  = UIColor(red: 102.0/255.0, green: 102.0/255.0, blue: 3.0/255.0, alpha: 1.0)
        
        return [deleteAction, shareAction, editAction]
    }
    
    
    
    /*
     // Override to support rearranging the table view.
     override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
