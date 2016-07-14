//
//  CommentViewController.swift
//  FakeStagram
//
//  Created by JJ on 10/07/2016.
//  Copyright © 2016 JJ. All rights reserved.
//

import UIKit
import Firebase

class CommentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    @IBOutlet var tableView: UITableView!
    @IBOutlet var textField: UITextField!
    var photosUID : String?
    var commentList = [String]()
    var commentUsernames = [String]()
    var currentUsername : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Open")
        self.navigationController?.navigationBarHidden = false
        self.tabBarController?.tabBar.hidden = true
        checkProfile()
        getUserComments()
        
        // Do any additional setup after loading the view.
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.commentList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("commentsCell")!
        let comments = self.commentList[indexPath.row]
        let username = self.commentUsernames[indexPath.row]
        cell.textLabel?.text = comments
        cell.detailTextLabel?.text = username
        return cell
    }
    @IBAction func enterBtn(sender: UIButton) {
        let firebaseRef = FIRDatabase.database().reference()
        let commentRef = firebaseRef.child("Comments").child(self.photosUID!).childByAutoId()
        guard textField.text != nil else {
            return
        }
        
        
        guard let currentUserUID = User.currentUserUid(), let comment = textField.text , let username = self.currentUsername  else{
            return
        }
        
        let commentDict = ["userID": currentUserUID, "comment": comment, "username": username]
        commentRef.setValue(commentDict)
        
    }
    
    func checkProfile() {
        let firebaseRef = FIRDatabase.database().reference()
        let userRef = firebaseRef.child("users")
        userRef.observeEventType(.ChildAdded, withBlock: { (snapshot) in
            if (snapshot.key == User.currentUserUid()){
                if let userInfo = snapshot.value as? [String: AnyObject] {
                    if let username = userInfo ["username"] as? String {
                        self.currentUsername = username
                    }
                    
                }
            }
        })
    }
    
    
    func getUserComments() {
        let firebaseRef = FIRDatabase.database().reference()
        let commentsRef = firebaseRef.child("Comments").child(self.photosUID!)
        commentsRef.observeEventType(.ChildAdded, withBlock:  { (snapshot) in
            if let commentDict = snapshot.value as? [String: AnyObject] {
                let commentText = commentDict ["comment"] as? String
                let commentUsername = commentDict ["username"] as? String
                self.commentList.append(commentText!)
                self.commentUsernames.append(commentUsername!)
                self.tableView.reloadData()
                
            }
        })
    }
    
}
