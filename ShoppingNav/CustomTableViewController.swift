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

class CustomTableViewController: UITableViewController, NSFetchedResultsControllerDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate , CLLocationManagerDelegate{
    
    var locationManager = CLLocationManager()
    var manager:CLLocationManager!
    var fetchResultController: NSFetchedResultsController!
    
    var images: [Image] = []
    var session :Session!
    var wishList: WishList!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refresh()
        
        locationManager = CLLocationManager()
        locationManager.requestAlwaysAuthorization()
        
//        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
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
        refresh()
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func location()->(Double,Double){
        
                locationManager.delegate = self
                locationManager.desiredAccuracy = kCLLocationAccuracyBest
                self.locationManager.distanceFilter = 1
        
                locationManager.startUpdatingLocation()
            if( CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.Authorized){
            
            }
                let lat = locationManager.location?.coordinate.latitude
                let lon = locationManager.location?.coordinate.longitude
                return (lat!,lon!)
            }
    
    func refresh(){
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
            
//            let photoLocation=location()
//            print("lan=\(photoLocation.0)")
//            print("lon=\(photoLocation.1)")
            imageCon.image = UIImagePNGRepresentation(image)!
//           imageCon.lantitude=photoLocation.0
//            imageCon.lontitude=photoLocation.1
            imageCon.wishList = wishList
            imageCon.session = session
            
            
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
        if CLLocationManager.locationServicesEnabled() {
            self.locationManager.startUpdatingLocation()
            self.locationManager.startUpdatingHeading()
        }
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
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showNavigate" {
            
            var destination = segue.destinationViewController
            if let navCon = destination as? UINavigationController {
                destination = navCon.visibleViewController!
            }
            let upcoming: ViewController = destination as! ViewController
            
            let indexPath = self.tableView.indexPathForSelectedRow!
      
            upcoming.lantitude = self.images[indexPath.row].lantitude
            upcoming.lontitude=self.images[indexPath.row].lontitude
          
            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }

    
    // MARK: - Table view delegate
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        
        let shareAction = UITableViewRowAction(style: .Default, title: "Share", handler: { (actin, indexPath) -> Void in
            let shareImages =  self.images[indexPath.row].image!
            let activityController = UIActivityViewController(activityItems: [shareImages], applicationActivities: nil)
        
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
        let deleteAction = UITableViewRowAction(style: .Destructive, title: "Delete", handler: {(actin, indexPath) -> Void in
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
        
        shareAction.backgroundColor = Util.backgroundColor().1
        deleteAction.backgroundColor = Util.backgroundColor().0
     
        return [deleteAction, shareAction]
    }
  }

