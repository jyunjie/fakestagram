//
//  CameraViewController.swift
//  FakeStagram
//
//  Created by JJ on 05/07/2016.
//  Copyright © 2016 JJ. All rights reserved.
//

import UIKit
import Fusuma
import Firebase

class CameraViewController: UIViewController, FusumaDelegate {
    let storage = FIRStorage.storage()
    let firebaseRef = FIRDatabase.database().reference()
    var downloadURL : String?
    var userName : String!
    var firstLaunch = true
    override func viewDidLoad() {
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        if firstLaunch{
            cameraOn()
            observeUser()
        }
    }
    
    
    
    func fusumaClosed() {
        
        self.tabBarController?.selectedIndex = 0
        firstLaunch = true
    }
    
    
    
    
    func fusumaImageSelected(image: UIImage) {
        let imageUID = NSUUID().UUIDString
        let imageRef = FIRStorage.storage().reference().child("Images").child("\(imageUID).png")
        if let uploadData = UIImageJPEGRepresentation(image, 0.1){
            imageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    print(error?.localizedDescription)
                    return
                }
                
                if let imageUrl = metadata?.downloadURL()?.absoluteString {
                    let imageDict = ["imageURL": imageUrl, "userID": User.currentUserUid()!, "userName" : self.userName , "likesCount" : 0]
                    self.firebaseRef.child("Images").child(imageUID).setValue(imageDict)
                    self.firebaseRef.child("users").child(User.currentUserUid()!).child("Uploaded").child(imageUID).setValue(true)
                }
            })

        }
        
        self.tabBarController?.selectedIndex = 0
        print("Image selected")
    }
    
    func observeUser() {
        let firebaseRef = FIRDatabase.database().reference()
        let userRef = firebaseRef.child("users")
        
        userRef.observeEventType(.ChildAdded, withBlock: {(snapshot) in
            
            if let tweetDict = snapshot.value as? [String : AnyObject]{
                print (snapshot.key)
                if (snapshot.key == User.currentUserUid()) {
                    if let tweetText = tweetDict["username"] as? String{
                        self.userName = tweetText
                    }
                }
            }
        })
        
    }
    

    
    func fusumaVideoCompleted(withFileURL fileURL: NSURL) {
        
        print("Called just after a video has been selected.")
    }
    
    // When camera roll is not authorized, this method is called.
    func fusumaCameraRollUnauthorized() {
        
        print("Camera roll unauthorized")
    }
    
    func cameraOn() {
        firstLaunch = false
        let fusuma = FusumaViewController()
        fusuma.delegate = self
        fusuma.hasVideo = true // If you want to let the users allow to use video.
        self.presentViewController(fusuma, animated: true, completion: nil)
    }
    
}
