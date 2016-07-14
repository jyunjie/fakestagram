//
//  ProfileViewController.swift
//  FakeStagram
//
//  Created by JJ on 08/07/2016.
//  Copyright © 2016 JJ. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage

class UserViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    @IBOutlet var userCollection: UICollectionView!
    @IBOutlet var followBtn: UIButton!
    
    
    @IBOutlet var followersLabel: UILabel!
    let firebaseRef = FIRDatabase.database().reference()
    let fireStorageRef = FIRStorage.storage().reference()
    var feedofPhotos = [String]()
    var userUID = String()
    
    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        imageAppending()
//        
//    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        imageAppending()
        getFollowing()
        
    }
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.feedofPhotos.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("userImage", forIndexPath: indexPath) as! UserCollectionViewCell
        let imageurl = feedofPhotos[indexPath.row]
        let url = NSURL(string: imageurl)
        cell.userImage.sd_setImageWithURL(url)
        return cell
    }
    
    
    func imageAppending() {
        let imageRef = firebaseRef.child("Images")
        imageRef.observeEventType(.ChildAdded, withBlock: { (snapshot) in
            
            if let imageDict = snapshot.value as? [String: AnyObject] {
                if let userID = imageDict["userID"] as?String {
                    if userID == self.userUID {
                        if let imageUrl = imageDict ["imageURL"] as? String {
                            self.feedofPhotos.append(imageUrl)
                            self.userCollection.reloadData()
                        }
                    }
                }
            }
        })
    }
    @IBAction func followButton(sender: UIButton) {
        let userRef = firebaseRef.child("users").child(self.userUID)
        
        userRef.runTransactionBlock({ (currentData: FIRMutableData) -> FIRTransactionResult in
            if var post = currentData.value as? [String : AnyObject], let uid = User.currentUserUid() {
                var following : Dictionary<String, Bool>
                following = post["following"] as? [String : Bool] ?? [:]
                var followCount = post["followCount"] as? Int ?? 0
                if let _ = following[uid] {
                    // Unstar the post and remove self from stars
                    followCount -= 1
                    following.removeValueForKey(uid)
                    dispatch_async(dispatch_get_main_queue(), {
                        sender.setTitle("Follow", forState: .Normal)
                        sender.backgroundColor = UIColor.grayColor()
                        sender.setTitleColor(UIColor.blueColor(), forState: .Normal)
                    })
                    
                } else {
                    // Star the post and add self to stars
                    followCount += 1
                    following[uid] = true
                    dispatch_async(dispatch_get_main_queue(), {
                        sender.setTitle("Following", forState: .Normal)
                        sender.backgroundColor = UIColor.greenColor()
                        sender.setTitleColor(UIColor.whiteColor(), forState: .Normal)
                    })
                }
                post["followCount"] = followCount
                post["following"] = following
                
                // Set value and report transaction success
                currentData.value = post
                
                return FIRTransactionResult.successWithValue(currentData)
            }
            return FIRTransactionResult.successWithValue(currentData)
        }) { (error, committed, snapshot) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
        
        let currentUserRef = firebaseRef.child("users").child(User.currentUserUid()!)
        
        currentUserRef.runTransactionBlock({ (currentData: FIRMutableData) -> FIRTransactionResult in
            let uid = self.userUID
            if var post = currentData.value as? [String : AnyObject] {
                var followers : Dictionary<String, Bool>
                followers = post["Followers"] as? [String : Bool] ?? [:]
                var followerCount = post["followerCount"] as? Int ?? 0
                if let _ = followers[uid] {
                    // Unstar the post and remove self from stars
                    followerCount -= 1
                    followers.removeValueForKey(uid)
                    dispatch_async(dispatch_get_main_queue(), {
                        sender.setTitle("Follow", forState: .Normal)
                        sender.backgroundColor = UIColor.grayColor()
                        sender.setTitleColor(UIColor.blueColor(), forState: .Normal)
                    })
                    
                } else {
                    // Star the post and add self to stars
                    followerCount += 1
                    followers[uid] = true
                    dispatch_async(dispatch_get_main_queue(), {
                        sender.setTitle("Following", forState: .Normal)
                        sender.backgroundColor = UIColor.greenColor()
                        sender.setTitleColor(UIColor.whiteColor(), forState: .Normal)
                    })
                }
                post["followerCount"] = followerCount
                post["followers"] = followers
                
                // Set value and report transaction success
                currentData.value = post
                
                return FIRTransactionResult.successWithValue(currentData)
            }
            return FIRTransactionResult.successWithValue(currentData)
        }) { (error, committed, snapshot) in
            if let error = error {
                print(error.localizedDescription)
            }
        }

        
    }
    
    func getFollowing () {
        firebaseRef.child("users").child(self.userUID).child("followCount").observeEventType(.Value, withBlock: { (snapshot) in
            if let followCount = snapshot.value as? Int{
                self.followersLabel.text = "\(followCount)"
            }
        })
    }

}

