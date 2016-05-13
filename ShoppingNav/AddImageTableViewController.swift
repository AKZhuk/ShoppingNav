//
//  AddImageTableViewController.swift
//  ShoppingNav
//
//  Created by 	Lesha Zhuk on 5/9/16.
//  Copyright © 2016 	Lesha Zhuk. All rights reserved.
//
import UIKit
import CoreData

class AddImageTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    //*** Этот класс мы полностью настроили на запись/прием введенной информации. *** Первым делом добавим аутлеты для всех объектов взаимодействия
    
    
    
    @IBOutlet weak var imageView: UIImageView!
    
    var wishList: WishList!
    var image: Image!
    let date : Double = NSDate().timeIntervalSince1970
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("ww\(wishList)")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    

    
    @IBAction func save(sender: UIBarButtonItem) {
     
        if let managedObjectContext = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext {
            image = NSEntityDescription.insertNewObjectForEntityForName("Image", inManagedObjectContext: managedObjectContext) as! Image
            
            //if let photoImage = imageView.image {
            
                image.image = UIImagePNGRepresentation(imageView.image!)
                //print("lol=\(wishList)")
                image.wishList = wishList
                image.id = date as NSNumber
            //image.id = Data as NSNumber
            //}
            
            do {
                
                try managedObjectContext.save()
                print("abc")
                //managedObjectContext.refreshAllObjects()
            } catch {
                print(error)
                return
                
            }
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}
