//
//  PostViewController.swift
//  HangingOut
//
//  Created by Marco Rago on 27/11/15.
//  Copyright © 2015 marcorfree. All rights reserved.
//

import UIKit
import Parse

extension UIImage {
    var highestQualityJPEGNSData:NSData { return UIImageJPEGRepresentation(self, 1.0)! }
    var highQualityJPEGNSData:NSData    { return UIImageJPEGRepresentation(self, 0.75)!}
    var mediumQualityJPEGNSData:NSData  { return UIImageJPEGRepresentation(self, 0.5)! }
    var lowQualityJPEGNSData:NSData     { return UIImageJPEGRepresentation(self, 0.25)!}
    var lowestQualityJPEGNSData:NSData  { return UIImageJPEGRepresentation(self, 0.0)! }
}


class PostViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet var imageView1: UIImageView!
    
    @IBOutlet var textField1: UITextField!
    
    let placeholder = "person-placeholder.jpg"
    
    var imageSelected: Bool = false
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageSelected = false
        
        textField1.text = ""

        //Init placeholder
        imageView1.image = UIImage(named: self.placeholder)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
        //Replace the image in the center with the one selected
        imageView1.image = image
        imageSelected = true
    }
    
    @IBAction func chooseImageButton(sender: UIButton) {
        
        let image = UIImagePickerController()
        image.delegate = self
        //Camera is not accessible via the Simulator
        image.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        image.allowsEditing = false
        
        //Open Photo Library
        self.presentViewController(image, animated: true, completion: nil)
        
    }
    
    
    @IBAction func postImageButton(sender: UIButton) {
        
        if textField1.text == "" {
            //error1
            self.showAlert("Could not post", error: "Please enter a message to share")
        } else if imageSelected == false {
            //error2
            self.showAlert("Could not post", error: "Please select an image to share")
        } else {
            
            //Take the image currently stored in ImageView1
            //let imageData = UIImagePNGRepresentation(self.imageView1.image!)
            //imageData compressed
            let imageData = self.imageView1.image!.lowestQualityJPEGNSData
            //Get bytes size of image
            var imageSize = Float(imageData.length)
            //Transform into Megabytes
            imageSize /= (1024*1024)
            //Íprint("Image size is \(imageSize)Mb")
            if imageSize >= 10 {
                self.showAlert("Your image is too big!", error: "Maximum dimension is 10MB for each image")
            }
            else
            {
            
                let imageFile = PFFile(name:"image.png", data:imageData)
                
                let post = PFObject(className: "Post")
                post["title"] = self.textField1.text
                post["username"] = PFUser.currentUser()?.username
                
                //Check the size
                post["imageFile"] = imageFile
                pause()

                post.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
                    if (success) {
                        // The object has been saved.
                        self.showAlert("Image Posted!", error: "Your image has been posted successfully")
                        self.imageSelected = false
                        self.textField1.text = ""
                        //Init placeholder
                        self.imageView1.image = UIImage(named: self.placeholder)
                    } else {
                        // There was a problem, check error.description
                        self.showAlert("Could not post", error: error!.description)
                    }
                }
                self.restore()
            }
        }
    }
   
    
    
    func showAlert(title: String, error: String ){
        let alert = UIAlertController(title: title, message: error, preferredStyle: UIAlertControllerStyle.Alert)
        
        //Handler (closure, method, func) will be executed if OK is pressed
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { action in
            //comment out this line and it will still work. It will not segue back to the previous screen.
            //self.dismissViewControllerAnimated(true, completion: nil)
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }

    func pause(){
        activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
    }
    
    func restore(){
        activityIndicator.stopAnimating()
        UIApplication.sharedApplication().endIgnoringInteractionEvents()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
