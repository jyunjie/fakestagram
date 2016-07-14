//
//  HomeTableViewCell.swift
//  FakeStagram
//
//  Created by JJ on 06/07/2016.
//  Copyright © 2016 JJ. All rights reserved.
//

import UIKit
import Firebase
protocol HomeTableViewCellDelegate {
    
    func likeBtnTapped(cell:HomeTableViewCell)
    func commentBtnTapped(cell:HomeTableViewCell)
    
}
class HomeTableViewCell: UITableViewCell {
    @IBOutlet var buttonLabel: UIButton!
    @IBOutlet var commentButton: UIButton!
    @IBOutlet var likeButton: UIButton!
    var delegate: HomeTableViewCellDelegate?
    
    @IBOutlet weak var postedImage: UIImageView!
    @IBOutlet var userName: UILabel!
    var feedOfLikes = [String]()
    let firebaseRef = FIRDatabase.database().reference()
    
    @IBAction func likeBtn(sender: AnyObject) {
        
        delegate?.likeBtnTapped(self)
        
    }
    @IBAction func commentBtn(sender: AnyObject) {
        delegate?.commentBtnTapped((self))

    }
}
