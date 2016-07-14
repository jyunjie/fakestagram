//
//  SearchTableViewController.swift
//  FakeStagram
//
//  Created by JJ on 12/07/2016.
//  Copyright © 2016 JJ. All rights reserved.
//

import UIKit
import Firebase

class SearchTableViewController: UITableViewController {
    let firebaseRef = FIRDatabase.database().reference()
    var username = [String]()
    var userUIDValue = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        checkUsers()
        checkUID()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.username.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("userCell", forIndexPath: indexPath)
        let username = self.username[indexPath.row]
        let userUID = self.userUIDValue[indexPath.row]
        cell.textLabel?.text = username
        cell.detailTextLabel?.text = userUID
        return cell
    }
    
    
    func checkUsers() {
        let firebaseRef = FIRDatabase.database().reference()
        let userRef = firebaseRef.child("users")
        
        userRef.observeEventType(.ChildAdded, withBlock: {(snapshot) in
            
            if let tweetDict = snapshot.value as? [String : AnyObject]{
                print (snapshot.key)
                if (snapshot.key != User.currentUserUid()) {
                    if let tweetText = tweetDict["username"] as? String{
                        self.username.append(tweetText)
                        self.tableView.reloadData()
                    }
                }
            }
        })
        
    }
    
    
    func checkUID() {
        let firebaseRef = FIRDatabase.database().reference()
        let userRef = firebaseRef.child("users")
        
        
        userRef.observeEventType(.ChildAdded, withBlock: {(snapshot) in
            
            if (snapshot.value as? [String : AnyObject]) != nil{
                if (snapshot.key != User.currentUserUid()){
                    print (snapshot.key)
                    self.userUIDValue.append(snapshot.key)
                }
                
            }
        })
        
    }
    
    /*
     // Override to support editing the table view.
     override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
     if editingStyle == .Delete {
     // Delete the row from the data source
     tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
     } else if editingStyle == .Insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
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
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "userSegue"{
            let destination = segue.destinationViewController as! UserViewController
            let indexPath = self.tableView.indexPathForSelectedRow!
            destination.userUID = self.userUIDValue[(indexPath.row)]
            destination.title = self.username[indexPath.row]
        }
    }
    
    
}
