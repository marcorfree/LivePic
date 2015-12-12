//
//  ProfileViewController.swift
//  HangingOut
//
//  Created by Marco Rago on 01/12/15.
//  Copyright © 2015 marcorfree. All rights reserved.
//

import UIKit
import Parse
//import ParseFacebookUtilsV4

class ProfileViewController: UIViewController {

    @IBOutlet var imageView1: UIImageView!
    
    
    @IBOutlet var label1: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        label1.text =  PFUser.currentUser()?.valueForKey("username") as! String
        PFUser.currentUser()?.valueForKey("email")
        //let data = PFUser.currentUser()?.valueForKey("image") as! NSData
        
        
        
        (PFUser.currentUser()?.valueForKey("imageFile") as! PFFile).getDataInBackgroundWithBlock {
            (imageData: NSData?, error: NSError?) -> Void in
            if error == nil {
                let image = UIImage(data: imageData!)
                self.imageView1.image = image
            }
        }
     }
    
    
    @IBAction func logOutButton(sender: UIBarButtonItem) {
        PFUser.logOut()
        self.performSegueWithIdentifier("segue_logOut", sender: self)    }
    
    
    
    func showAlert(title: String, error: String ){
        let alert = UIAlertController(title: title, message: error, preferredStyle: UIAlertControllerStyle.Alert)
        
        //Handler (closure, method, func) will be executed if OK is pressed
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { action in
            //comment out this line and it will still work. It will not segue back to the previous screen.
            self.dismissViewControllerAnimated(true, completion: nil)
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    

   
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
