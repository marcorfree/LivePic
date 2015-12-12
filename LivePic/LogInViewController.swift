//
//  ViewController.swift
//  HangingOut
//
//  Created by Marco Rago on 25/11/15.
//  Copyright © 2015 marcorfree. All rights reserved.
//

import UIKit
import Parse
import ParseFacebookUtilsV4

class LoginViewController: UIViewController {

    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    
    @IBOutlet var username: UITextField!

    @IBOutlet var password: UITextField!
    
    
    @IBOutlet var logInButton: UIButton!
    
    @IBOutlet var signUpButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //PFUser.logOut()
        //signUpParse()
        
        //getParseData()
        
        //updateParseData()
        
        self.logInButton.layer.cornerRadius = 5
        
        self.signUpButton.layer.cornerRadius = 5
        
        //self.view.backgroundColor = UIColor(patternImage: UIImage(named: "images.jpeg")!)
        
        self.navigationItem.title="Log In"

        print("Current User= \(PFUser.currentUser()?.username)")
        
        
        
    }

    
    override func viewDidAppear(animated: Bool) {
        //Executed after DidLoad
        if PFUser.currentUser() != nil {
            //print("Current User= \(PFUser.currentUser()!.username)")
            self.performSegueWithIdentifier("segue_TBC", sender: self)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        //Hide the navigation bar when it's displayed from logout
        self.navigationController?.navigationBarHidden = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        //Show again the navigation bar
        self.navigationController?.navigationBarHidden = false
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    
    
    
    @IBAction func signUpButton(sender: UIButton) {
        if username.text == "" || password.text == "" {
            showAlert("Error", error: "Enter a username and password")
        }
        else {
            signUpParse()
        }
        
    }
    
    @IBAction func logInButton(sender: UIButton) {
        if username.text == "" || password.text == "" {
            showAlert("Error", error: "Enter a username and password")
        }
        else {
            logInParse()
        }
    }
    
    
    @IBAction func facebookLogInButton(sender: UIButton) {
        
        let permissions = ["public_profile", "email", "user_friends"]
        
        PFFacebookUtils.logInInBackgroundWithReadPermissions(permissions) { (user: PFUser?, error: NSError?) -> Void in
            if let user = user {
                if user.isNew {
                    print("User signed up and logged in through Facebook!")
                    
                    /*
                    PFUser.currentUser().username = result.name
                    
                    valueForKey("name")
                    PFUser.currentUser().setValue(result.objectID, forKey: "fbId")
                    PFUser.currentUser().saveEventually() // Always use saveEventually if you want to be sure that the save will succeed
                    */
                    self.saveFacebookData(user)
                    self.performSegueWithIdentifier("segue_TBC", sender: self)
                } else {
                    print("User logged in through Facebook!")
                    self.performSegueWithIdentifier("segue_TBC", sender: self)
                }
            } else {
                print("Uh oh. The user cancelled the Facebook login.")
                self.showAlert("Could not Log In", error: "The login via Facebook was unsuccessful, please try again!")
            }
        }
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
    
    
    func saveFacebookData(user: PFUser) {
        print(user)
        let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
        let session = NSURLSession.sharedSession()
        let url = NSURL(string: "https://graph.facebook.com/me/picture?type=large&access_token="+accessToken)
        let request = NSURLRequest(URL: url!)
        let dataTask = session.dataTaskWithRequest(request) { (data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
            if error != nil {
                print( "*****   ERROR  *****")
                print(error)
                //self.showAlert("Could not retrieve your data", error: "The connection with Facebook was unsuccessful, please try again!")
            } else {
                
                print("*******   *********")
                
                let imageFile = PFFile(name:"image.png", data: data!)
                user["imageFile"] = imageFile
                self.pause()
                
                user.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
                    if (success) {
                        // The object has been saved.
                        print("OK")
                    } else {
                        // There was a problem, check error.description
                        print(error)
                    }
                }
                self.restore()
                
                
                /*
                user["image"] = data
                user.saveEventually()
                */
            }
            
        }
        dataTask.resume()

        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me?fields=name,email", parameters: nil)
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if (error != nil)
            {
                // Process error
                print("Process Error")
                self.showAlert("Could not retrieve your data", error: "\(error)")
            }
            else
            {
                let userName : NSString = result.valueForKey("name") as! NSString
                user["username"] =  userName as String
                let email : NSString = result.valueForKey("email") as! NSString
                user["email"] = email as String
                user.saveEventually()
                
            }
        })
        
       
        
    }
    

    
    func signUpParse(){
        //Can also create and save custom Parse Object, using saveInBackgroundnWithBlock of a new PFObject
        //Here using the "_User" Parse Class

        let user = PFUser()
        user.username = username.text
        user.password = password.text
        //user.email = "marco.rago@hotmail.it"
        // other fields can be set if you want to save more information
        //user["phone"] = "0039334"

        pause()
        
        user.signUpInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            
            self.restore()
            
            if error == nil {
                // Hooray! Let them use the app now.
                //print("Signed Up!")
                self.performSegueWithIdentifier("segue_TBC", sender: self)

            } else {
                // Examine the error object and inform the user.
                let errorString = error!.userInfo["error"] as! NSString
                self.showAlert("Could not Sign Up", error: String(errorString))
            }
        }
    }
    
    
    
    func logInParse(){
        //Can also create and save custom Parse Object, using saveInBackgroundnWithBlock of a new PFObject
        //Here using the "_User" Parse Class
        
        
        self.pause()
        
        PFUser.logInWithUsernameInBackground(username.text!, password:password.text!) {
            (user: PFUser?, error: NSError?) -> Void in
            self.restore()
            if error == nil {
                // Do stuff after successful login.
                //print("logged In")
                self.performSegueWithIdentifier("segue_TBC", sender: self)
            } else {
                // The login failed. Check error to see why.
                let errorString = error!.userInfo["error"] as! NSString
                self.showAlert("Could not Log In", error: String(errorString))
            }
        }
        
        /*
        if (FBSDKAccessToken.currentAccessToken() != nil)
        {
        
            let accessToken: FBSDKAccessToken = FBSDKAccessToken.currentAccessToken() // Use existing access token.
            
            // Log In (create/update currentUser) with FBSDKAccessToken
            PFFacebookUtils.logInInBackgroundWithAccessToken(accessToken, {
                (user: PFUser?, error: NSError?) -> Void in
                if user != nil {
                    print("User logged in through Facebook!")
                } else {
                    print("Uh oh. There was an error logging in.")
                }
            })
        
        }
        
        //
        // or
        //
        
        // Link PFUser with FBSDKAccessToken
        PFFacebookUtils.linkUserInBackground(user, withAccessToken: accessToken, {
        (succeeded: Bool?, error: NSError?) -> Void in
        if succeeded {
        print("Woohoo, the user is linked with Facebook!")
        }
        })*/
        
    }

    
    func showAlert(title: String, error: String ){
        let alert = UIAlertController(title: title, message: error, preferredStyle: UIAlertControllerStyle.Alert)
        
        //Handler (closure, method, func) will be executed if OK is pressed
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { action in
            //comment out this line and it will still work. It will not segue back to the previous screen.
            self.dismissViewControllerAnimated(true, completion: nil)
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
//PARSE
    
    func getParseData(){
        let query = PFQuery(className: "_User")
        
        query.getObjectInBackgroundWithId("2L7i0xyINB"){ (po: PFObject?, error: NSError?) -> Void in
            if error == nil {
                // Hooray! Let them use the app now.
                print(po)
            } else {
                // Examine the error object and inform the user.
                //print(error)
            }
        }
    }
        
    func updateParseData() {
        let query = PFQuery(className: "_User")
        
        query.getObjectInBackgroundWithId("2L7i0xyINB"){ (po: PFObject?, error: NSError?) -> Void in
            if error == nil {
                // Hooray! Let them use the app now.
                po!["email"] = "marco.rago@parse.it"
                po!.saveInBackground()
                //Better
                /*do {
                try po!.save()
                } catch {}*/
            } else {
                // Examine the error object and inform the user.
                //print(error)
            }
        }
    }

    



}

/*
// MARK: - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
let VCLogIn: ViewControllerLogIn = segue.destinationViewController as! ViewControllerLogIn
VCLogIn.username_passing = username.text!
VCLogIn.password_passing = password.text!

}
*/