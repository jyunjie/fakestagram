//
//  FeedTableViewController.swift
//  FakeStagram
//
//  Created by JJ on 07/07/2016.
//  Copyright © 2016 JJ. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage


class FeedTableViewController: UITableViewController {
    
    var feedofPhotos = [String]()
    var feedofInfo = [String]()
    var photosUID = [String]()
    var countLikes = [String]()
    var currentUserName : String!
    var likesInfo = [Int]()
    var photosComment = [String]()
    var usersSet = Set<String>()
    let firebaseRef = FIRDatabase.database().reference()
    let storageRef = FIRStorage.storage().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getFollowing()
        imageAppending()  //done
        imageInfo()       //done
        photosInfo()
        checkLikes()
        self.usersSet.insert(User.currentUserUid()!)
        
    }
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = true
        self.tabBarController?.tabBar.hidden = false
        //        checkLikes()
    }
    
    
    
    // MARK: - Table view data source
    //    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    //        return 2
    //    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return (self.feedofPhotos.count)*2
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.row % 2 == 0 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! HomeTableViewCell
                let imageurl = feedofPhotos[(indexPath.row)]
                let imageInfo = feedofInfo[(indexPath.row)]
                //                let likeInfo = likesInfo[(indexPath.row)]
                let url = NSURL(string: imageurl)
                
                cell.postedImage.sd_setImageWithURL(url)
                cell.userName.text = imageInfo
                cell.likeButton.tag = indexPath.row
                //                let likesAmount : String = " \(String(likeInfo)) likes"
                //                cell.buttonLabel.setTitle(likesAmount, forState: .Normal)
                cell.likeButton.addTarget(self, action: #selector(FeedTableViewController.logAction(_:)), forControlEvents: .TouchUpInside)
                //                cell.commentButton.addTarget(self, action: "commentAction:", forControlEvents: .TouchUpInside)
                cell.delegate = self
                return cell
            } else {
                let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! HomeTableViewCell
                let imageurl = feedofPhotos[(indexPath.row)/2]
                let imageInfo = feedofInfo[(indexPath.row)/2]
                //                let likeInfo = likesInfo[(indexPath.row)/2]
                let url = NSURL(string: imageurl)
                
                cell.postedImage.sd_setImageWithURL(url)
                cell.userName.text = imageInfo
                cell.likeButton.tag = (indexPath.row)/2
                cell.commentButton.tag = (indexPath.row)/2
                //                let likesAmount : String = " \(String(likeInfo)) likes"
                //                cell.buttonLabel.setTitle(likesAmount, forState: .Normal)
                cell.likeButton.addTarget(self, action: #selector(FeedTableViewController.logAction(_:)), forControlEvents: .TouchUpInside)
                //                cell.commentButton.addTarget(self, action: "commentAction:", forControlEvents: .TouchUpInside)
                cell.delegate = self
                return cell
            }
        } else {
            let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "commentCell")
            //            let commentsText = self.photosComment[(indexPath.row)-1]
            cell.textLabel?.text = "Under maintenance "
            print(self.photosComment)
            return cell
        }
        
        
    }
    
    @IBAction func logAction(sender: UIButton){
        let imageRef = self.firebaseRef.child("Images").child(self.photosUID[sender.tag])
        
        imageRef.runTransactionBlock({ (currentData: FIRMutableData) -> FIRTransactionResult in
            if var post = currentData.value as? [String : AnyObject], let uid = User.currentUserUid() {
                var likes : Dictionary<String, Bool>
                likes = post["likes"] as? [String : Bool] ?? [:]
                var likesCount = post["likesCount"] as? Int ?? 0
                if let _ = likes[uid] {
                    // Unstar the post and remove self from stars
                    likesCount -= 1
                    likes.removeValueForKey(uid)
                    sender.setImage(UIImage(named: "love"), forState: .Normal)
                } else {
                    // Star the post and add self to stars
                    likesCount += 1
                    likes[uid] = true
                    sender.setImage(UIImage(named: "red"), forState: .Normal)
                }
                post["likesCount"] = likesCount
                post["likes"] = likes
                
                // Set value and report transaction success
                currentData.value = post
                
                self.likesInfo.removeAll()
                self.checkLikes()
                self.tableView.reloadData()
                
                return FIRTransactionResult.successWithValue(currentData)
            }
            return FIRTransactionResult.successWithValue(currentData)
        }) { (error, committed, snapshot) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    func imageAppending() {   //done
        let imageRef = firebaseRef.child("Images")
        imageRef.observeEventType(.ChildAdded, withBlock: { (snapshot) in
            if let imageDict = snapshot.value as? [String: AnyObject] {
                let containFollowing = imageDict["userID"] as? String
                if self.usersSet.contains(containFollowing!) {
                    
                    if let imageUrl = imageDict ["imageURL"] as? String {
                        self.feedofPhotos.append(imageUrl)
                        self.tableView.reloadData()
                    }
                }
            }
            }
        )}
    
    
    func imageInfo() {   //done
        let imageRef = firebaseRef.child("Images")
        imageRef.observeEventType(.ChildAdded, withBlock: { (snapshot) in
            if let imageInfoDict = snapshot.value as? [String: AnyObject] {
                let containFollowing = imageInfoDict["userID"] as? String
                if self.usersSet.contains(containFollowing!) {
                    
                    if let imageInfo = imageInfoDict ["userName"] as? String {
                        self.feedofInfo.append(imageInfo)
                        self.tableView.reloadData()
                    }
                }
            }
        })
    }
    
    func photosInfo() {
        let imageRef = firebaseRef.child("Images")
        imageRef.observeEventType(.ChildAdded, withBlock: { (snapshot) in
            if let imageID = snapshot.key as? String {
                
                self.photosUID.append(imageID)
                
            }
        })
    }
    
    //    func checkProfile() {
    //        let userRef = firebaseRef.child("users")
    //        userRef.observeEventType(.ChildAdded, withBlock: { (snapshot) in
    //            if (snapshot.key == User.currentUserUid()){
    //                if let userInfo = snapshot.value as? [String: AnyObject] {
    //                    if let username = userInfo ["username"] as? String {
    //                        self.currentUserName = username
    //                    }
    //
    //                }
    //            }
    //        })
    //    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row % 2 == 0 {
            return 450
        }
        else {
            return 40
        }
    }
    
    
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
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
    //    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    //        self.performSegueWithIdentifier("commentView", sender: self)
    //    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "commentView" {
            let destination: CommentViewController = segue.destinationViewController as! CommentViewController
            if let cell = sender as? HomeTableViewCell {
                
                let indexPath = self.tableView.indexPathForCell(cell)
                if indexPath?.row == 0 {
                    destination.title = self.photosUID[(indexPath!.row)]
                    destination.photosUID = self.photosUID[(indexPath!.row)]
                    print(indexPath?.row)
                }else{
                    destination.title = self.photosUID[(indexPath!.row)/2]
                    destination.photosUID = self.photosUID[(indexPath!.row)/2]
                    print(indexPath?.row)
                }
            }
        }
        
    }
    
    func checkLikes() {
        let imageRef = firebaseRef.child("Images")
        imageRef.observeEventType(.ChildAdded, withBlock: { (snapshot) in
            if let likesInfoDict = snapshot.value as? [String: AnyObject] {
                if let likesInfo = likesInfoDict ["likesCount"] as? Int {
                    self.likesInfo.append(likesInfo)
                    self.tableView.reloadData()
                    
                }
            }
        })
    }
    
    func getUserComments() {
        let firebaseRef = FIRDatabase.database().reference()
        let commentsRef = firebaseRef.child("Comments")
        commentsRef.observeEventType(.ChildAdded, withBlock:  { (snapshot) in
            commentsRef.child(snapshot.key).observeEventType(.ChildAdded, withBlock: {(snapshot) in
                if let commentDict = snapshot.value as? [String: AnyObject] {
                    let commentText = commentDict ["comment"] as? String
                    self.photosComment.append(commentText!)
                }
            })
        })
    }
    
    func getFollowing () {
        firebaseRef.child("users").child(User.currentUserUid()!).child("followers").observeEventType(.ChildAdded, withBlock: { (snapshot) in
            self.usersSet.insert(snapshot.key)
            print (self.usersSet)
        })
    }
    
}

extension FeedTableViewController: HomeTableViewCellDelegate{
    func likeBtnTapped(cell: HomeTableViewCell) {
        //        print("")
        
    }
    
    func commentBtnTapped(cell: HomeTableViewCell) {
        self.performSegueWithIdentifier("commentView", sender: cell)
    }
    
}
