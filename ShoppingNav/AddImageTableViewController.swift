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
    
    var WishLis: WishList!
    var image: Image!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
                imagePicker.sourceType = .Camera
                
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
            
            if let photoImage = imageView.image {
                image.wishList = WishLis/////jfh
                image.image = UIImagePNGRepresentation(photoImage)
            }
            
            do {
                try managedObjectContext.save()
            } catch {
                print(error)
                return
            }
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}
