//
//  CommentsCell.swift
//  Facebook
//
//  Created by David on 1/20/19.
//  Copyright © 2019 David. All rights reserved.
//

import UIKit

class CommentsCell: UITableViewCell {
    @IBOutlet weak var avaImageView: UIImageView!
    @IBOutlet weak var fullNameLAbel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        //round corners
        avaImageView.layer.cornerRadius = avaImageView.frame.width / 2
        avaImageView.clipsToBounds = true
    }


}
