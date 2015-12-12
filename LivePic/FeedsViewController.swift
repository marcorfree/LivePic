//
//  FeedsViewController.swift
//  HangingOut
//
//  Created by Marco Rago on 28/11/15.
//  Copyright © 2015 marcorfree. All rights reserved.
//

import UIKit
import Parse

class FeedsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var tableView1: UITableView!
    
    var usernames = [String]()
    
    var titles = [String]()
    
    //var images = [UIImage]()
    var imageFiles = [PFFile]()
    
    var A = [PFObject]()
    
    var imageProfiles = [String: PFFile]()
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        
        
        // Manage refreshControl
        //msg that appears when Pull To refreshControl pop-ups
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refreshControl")
        // you can use "refreshControl:" in case
        self.refreshControl.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView1.addSubview(refreshControl)
        /*
        //If navigation Controller is used
        self.tableView.contentInset = UIEdgeInsetsZero;
        */
    }//viewDidLoad()

    
    override func viewWillAppear(animated: Bool) {
        getFeeds()
    }
    
    func refresh() {
        PFQuery.clearAllCachedResults()
        getFeeds()
        self.refreshControl.endRefreshing()
    }


    
    func getFeeds() {
        let followersQuery = PFQuery(className:"Followers")
        followersQuery.whereKey("follower", equalTo:PFUser.currentUser()!.username!)
        //followersQuery.orderByDescending("CreatedAt")
        
        
        
        self.pause()

        // ********************
        //let group = dispatch_group_create()
        
        followersQuery.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                // The find succeeded.
                //print("Successfully retrieved \(objects!.count) followings.")
                self.usernames.removeAll(keepCapacity: true)
                self.titles.removeAll(keepCapacity: true)
                self.imageFiles.removeAll(keepCapacity: true)
                
                self.A.removeAll(keepCapacity: true)
                
                
                self.imageProfiles.removeAll(keepCapacity: true)
                for object in objects! {
                    
                    let imageProfileQuery = PFQuery(className:"_User")
                    imageProfileQuery.whereKey("username", equalTo: object["following"])
                    imageProfileQuery.findObjectsInBackgroundWithBlock {
                        (users: [PFObject]?, error: NSError?) -> Void in
                        
                        if error == nil {
                            
                            let usr = users!.first!["username"] as! String
                            let img : PFFile = users!.first!["imageFile"] as! PFFile
                            self.imageProfiles[usr] = img
                        } else {
                        // Log details of the failure
                        print("Error: \(error!) \(error!.userInfo)")
                        }//endelse
                   
                    }//endblock imageProfileQuery
                } //end for


                
                
                // Do something with the found objects
                for object in objects! {
                    //self.followings.append(object.["following"] as! String)
                   
                    let postQuery = PFQuery(className:"Post")
                    postQuery.whereKey("username", equalTo: object["following"])
                    
                    /*if let objects = try? postQuery.findObjects() {
                        for object in objects {
                             self.A.append(object)
                        }
                    }
                    else {
                        // Log details of the failure
                        print("Error: Retrieving followings")
                    }*/
                    
                    
                    postQuery.findObjectsInBackgroundWithBlock {
                        (objects: [PFObject]?, error: NSError?) -> Void in
                        
                        if error == nil {
                            // The find succeeded.
                            //print("Successfully retrieved \(objects!.count) scores.")
                            if let objects = objects {
                                for object in objects {
                                    self.A.append(object)
                                    
                                    /*
                                    //Do not remove ***  Issues with threads
                                    self.usernames.append(object["username"] as! (String))
                                    self.titles.append(object["title"] as! (String))
                                    //Postpone the images download later on, for performance purposes
                                    self.imageFiles.append(object["imageFile"] as! PFFile)
                                    /***************************************/
                                    */
                                    self.tableView1.reloadData()
                              }//end for
                            }//end if
                        } else {
                            // Log details of the failure
                            print("Error: \(error!) \(error!.userInfo)")
                        }//endelse
                        self.A.sortInPlace( { $0.createdAt!.compare($1.createdAt!) == NSComparisonResult.OrderedDescending } )
                    }//endblock postQuery
                } //endfor
            } //endif
        } //endblock followersQuery
        //dispatch_async(dispatch_get_main_queue()) { [unowned self] in self.tableView.reloadData() }
        //self.tableView.performSelectorOnMainThread(Selector("reloadData"), withObject: nil, waitUntilDone: true)
        self.restore()
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return  titles.count
    }

    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //Specify that the cell is an own cell, not the stard one
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! FeedsViewCell

        // Configure the cell...
        
        
        cell.usernameLabel.text = A[indexPath.row]["username"] as? String
        
        cell.titleLabel.text = A[indexPath.row]["title"] as? String
        
        (A[indexPath.row]["imageFile"] as! PFFile).getDataInBackgroundWithBlock {
            (imageData: NSData?, error: NSError?) -> Void in
            if error == nil {
                let image = UIImage(data:imageData!)
                cell.imageView1.image = image
            }
        }

        
        let str : String = A[indexPath.row]["username"] as! String
        
        if let imageData = try? imageProfiles[str]!.getData() as NSData?
        {
            
            let image = UIImage(data:imageData!)
            cell.imageProfile.image = image
        } else {
            print("Error:")
        }
        
        
            
    
        /*cell.usernameLabel.text = usernames[indexPath.row]

        cell.titleLabel.text = titles[indexPath.row]

        imageFiles[indexPath.row].getDataInBackgroundWithBlock {
            (imageData: NSData?, error: NSError?) -> Void in
            if error == nil {
                let image = UIImage(data:imageData!)
                cell.imageView1.image = image
            }
        }
        */
        
        return cell
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
    
    
    
    //The height of the cell in can be even left to the the default. Set at runtime, for dynamic cells
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 220
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
