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

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(animated: Bool) {
        let fusuma = FusumaViewController()
        fusuma.delegate = self
        fusuma.hasVideo = true // If you want to let the users allow to use video.
        self.presentViewController(fusuma, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func fusumaImageSelected(image: UIImage) {
        let storageRef = storage.reference()
        let imagesRef = storageRef.child("images")

        print(imagesRef.fullPath)
    }
    
    // Return the image but called after is dismissed.
    func fusumaDismissedWithImage(image: UIImage) {
        
        print("Called just after FusumaViewController is dismissed.")
        self.tabBarController?.selectedIndex = 0
    }
    
    func fusumaVideoCompleted(withFileURL fileURL: NSURL) {
        
        print("Called just after a video has been selected.")
    }
    
    // When camera roll is not authorized, this method is called.
    func fusumaCameraRollUnauthorized() {
        
        print("Camera roll unauthorized")
    }
    
    func cameraOn() {
        let fusuma = FusumaViewController()
        fusuma.delegate = self
        fusuma.hasVideo = true // If you want to let the users allow to use video.
        self.presentViewController(fusuma, animated: true, completion: nil)
    }

}
