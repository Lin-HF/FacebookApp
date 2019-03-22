//
//  SearchUserCell.swift
//  Facebook
//
//  Created by David on 1/21/19.
//  Copyright © 2019 David. All rights reserved.
//

import UIKit

class SearchUserCell: UITableViewCell {

    //ui obj
    @IBOutlet weak var avaImageView: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var friendButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
        //rounded corners
        avaImageView.layer.cornerRadius = avaImageView.frame.width / 2
        avaImageView.clipsToBounds = true
    }



}
