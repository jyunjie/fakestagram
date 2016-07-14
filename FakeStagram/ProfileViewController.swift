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

class ProfileViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var profileUserNameTitle: UINavigationBar!
    
    let firebaseRef = FIRDatabase.database().reference()
    let fireStorageRef = FIRStorage.storage().reference()
    var feedofPhotos = [String]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkProfile()
        imageAppending()
        
    }
    
    func checkProfile() {
        let userRef = firebaseRef.child("users")
        userRef.observeEventType(.ChildAdded, withBlock: { (snapshot) in
            if (snapshot.key == User.currentUserUid()){
            if let userInfo = snapshot.value as? [String: AnyObject] {
                if let username = userInfo ["username"] as? String {
                    self.profileUserNameTitle.topItem?.title = username
                    
                }
                
                }
            }
        })
    }
 
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.feedofPhotos.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("profileimage", forIndexPath: indexPath) as! ProfileImageCollectionViewCell
        let imageurl = feedofPhotos[indexPath.row]
        let url = NSURL(string: imageurl)
        cell.profileImage.sd_setImageWithURL(url)
        return cell
    }
    
    func imageAppending() {
        let imageRef = firebaseRef.child("Images")
        imageRef.observeEventType(.ChildAdded, withBlock: { (snapshot) in
            
            if let imageDict = snapshot.value as? [String: AnyObject] {
                if let userID = imageDict["userID"] as?String {
                    if userID == User.currentUserUid() {
                if let imageUrl = imageDict ["imageURL"] as? String {
                    self.feedofPhotos.append(imageUrl)
                    self.collectionView.reloadData()
                        }
                    }
                }
            }
        })
    }
    @IBAction func logOut(sender: AnyObject) {
        try! FIRAuth.auth()!.signOut()
        User.removeUserUid()
    }
}


