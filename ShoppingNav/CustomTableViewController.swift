//
//  CustomTableViewController.swift
//  ShoppingNav
//
//  Created by 	Lesha Zhuk on 5/9/16.
//  Copyright © 2016 	Lesha Zhuk. All rights reserved.
//


import UIKit
import CoreData
import CoreLocation

class CustomTableViewController: UITableViewController, NSFetchedResultsControllerDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate, CLLocationManagerDelegate {
    
    var locationManager = CLLocationManager()
    var manager:CLLocationManager!
    var fetchResultController: NSFetchedResultsController!
    
    var images: [Image] = []
    var session :Session!
    var wishList: WishList!
    var sessionID:  NSNumber!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if( wishList == nil){
            print("wishList error")
        }
        RequestToCoreData()
        
        
        // Удалить title у кнопки  back
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        }
    
    
    
    
    @IBAction func createPhoto(sender: UIBarButtonItem) {
        
        if( UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary)) {
            let picker = UIImagePickerController()
            picker.sourceType = .PhotoLibrary
            picker.delegate = self
            presentViewController(picker, animated:true, completion: nil)
    }
}

    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        var image = info[UIImagePickerControllerEditedImage] as? UIImage
        
        if image == nil {
            image = info[UIImagePickerControllerOriginalImage] as? UIImage
        }
        save(image!)
        RequestToCoreData()
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func location()->(Double,Double){
                locationManager = CLLocationManager()
                locationManager.delegate = self
                locationManager.desiredAccuracy = kCLLocationAccuracyBest
                locationManager.requestAlwaysAuthorization()
                locationManager.startUpdatingLocation()
            if( CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.Authorized){
        
           // currentLocation = locationManager.location
        
            }
        
        
                let lat = locationManager.location?.coordinate.latitude
                let lon = locationManager.location?.coordinate.longitude
                return (lat!,lon!)
            }
    
    func RequestToCoreData(){
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
            self.tableView.reloadData()
        }
}
    
    
    func save(image: UIImage) {
        
        if let managedObjectContext = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext {
            let imageCon = NSEntityDescription.insertNewObjectForEntityForName("Image", inManagedObjectContext: managedObjectContext) as! Image
            
            let photoLocation=location()
            print("lan=\(photoLocation.0)")
            print("lon=\(photoLocation.1)")
            
            imageCon.image = UIImagePNGRepresentation(image)!
            imageCon.lantitude=photoLocation.0
            imageCon.lontitude=photoLocation.1
            imageCon.wishList = wishList
            imageCon.session = session
            //image.id = date as NSNumber
            
            
            do {
                
                try managedObjectContext.save()
                
            } catch {
                print(error)
                return
            }
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }


    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.hidesBarsOnSwipe = true
        prefersStatusBarHidden()
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
//           var shareImage=[AnyObject]()
//
//            for image in self.images{
//              shareImage.append(self.images[indexPath.row].image!)
//            }

            
            

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
            upcoming.session =  session
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

