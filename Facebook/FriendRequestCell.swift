//
//  RequestUserCell.swift
//  Facebook
//
//  Created by David on 1/28/19.
//  Copyright © 2019 David. All rights reserved.
//

import UIKit

protocol FriendRequestCellDelegate: class {
    
    func updateFriendshipRequestDelegate(with action: String, status: Int, from cell: UITableViewCell)
    
}

class FriendRequestCell: UITableViewCell {

    @IBOutlet weak var avaImageView: UIImageView!
    @IBOutlet weak var fullnameLabel: UILabel!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var messageLabel: UILabel!
    var delegate: FriendRequestCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        //border for delete button
        let border = CALayer()
        border.borderWidth = 1.5
        border.borderColor = UIColor.lightGray.cgColor
        border.frame = CGRect(x: 0, y: 0, width: deleteButton.frame.width, height: deleteButton.frame.height)
        
        deleteButton.layer.addSublayer(border)
        deleteButton.layer.cornerRadius = 3
        deleteButton.layer.masksToBounds = true
        
        //for confirm button
        confirmButton.layer.cornerRadius = 3
        
    }
    @IBAction func confirmButton_clicked(_ sender: Any) {
        confirmButton.isHidden = true
        deleteButton.isHidden = true
        messageLabel.isHidden = false
        messageLabel.text = "Request accepted"
        delegate?.updateFriendshipRequestDelegate(with: "confirm",status: 3, from: self)
    }
    
    @IBAction func deleteButton_clicked(_ sender: Any) {
        confirmButton.isHidden = true
        deleteButton.isHidden = true
        messageLabel.isHidden = false
        messageLabel.text = "Request removed"
        delegate?.updateFriendshipRequestDelegate(with: "reject",status: 0, from: self)
    }
}
