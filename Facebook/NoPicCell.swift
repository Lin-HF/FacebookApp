//
//  NoPicCell.swift
//  Facebook
//
//  Created by David on 1/14/19.
//  Copyright © 2019 David. All rights reserved.
//

import UIKit

class NoPicCell: UITableViewCell {
    
    // ui obj
    @IBOutlet weak var avaImageView: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var postTextLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var commentsButton: UIButton!
    @IBOutlet weak var optionsButton: UIButton!
    
    //first loading function
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        avaImageView.layer.cornerRadius = avaImageView.frame.width / 2
        avaImageView.clipsToBounds = true
    }


}
