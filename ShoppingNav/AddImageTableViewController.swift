//
//  AddImageTableViewController.swift
//  ShoppingNav
//
//  Created by 	Lesha Zhuk on 5/9/16.
//  Copyright © 2016 	Lesha Zhuk. All rights reserved.
//
import UIKit
import CoreData
import CoreLocation

class AddImageTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate {
    //*** Этот класс мы полностью настроили на запись/прием введенной информации. *** Первым делом добавим аутлеты для всех объектов взаимодействия
    
    
    
    @IBOutlet weak var imageView: UIImageView!
    
    var wishList: WishList!
    var image: Image!
    let date : Double = NSDate().timeIntervalSince1970
    var locationManager = CLLocationManager()
    var manager:CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    
    // MARK: - Table view data source
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0 {
            if UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.allowsEditing = false
                imagePicker.sourceType = .PhotoLibrary
                
                self.presentViewController(imagePicker, animated: true, completion: nil)
            }
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // MARK: - UIImagePickerControllerDelegate methods
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        imageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        imageView.contentMode = UIViewContentMode.ScaleAspectFill
        imageView.clipsToBounds = true
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Action methods //Добавили кнопки
    
    func location()->(Double,Double){
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        let lat = locationManager.location?.coordinate.latitude
        let lon = locationManager.location?.coordinate.longitude
        return (lat!,lon!)
    }
    
    @IBAction func save(sender: UIBarButtonItem) {
     
        if let managedObjectContext = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext {
            image = NSEntityDescription.insertNewObjectForEntityForName("Image", inManagedObjectContext: managedObjectContext) as! Image
            
            //if let photoImage = imageView.image {
            
                image.image = UIImagePNGRepresentation(imageView.image!)
                let photoLocation=location()
                //image.lantitude=photoLocation.0
                //image.lontitude=photoLocation.1
                image.wishList = wishList
                image.id = date as NSNumber
            
            //}
            
            do {
                
                try managedObjectContext.save()
                //managedObjectContext.refreshAllObjects()
            } catch {
                print(error)
                return
                
            }
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}
