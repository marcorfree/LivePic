//
//  FeedsTableViewCell.swift
//  HangingOut
//
//  Created by Marco Rago on 28/11/15.
//  Copyright © 2015 marcorfree. All rights reserved.
//

import UIKit


//Manage each cell
class FeedsViewCell: UITableViewCell {

    
    @IBOutlet var imageView1: UIImageView!
    
    @IBOutlet var usernameLabel: UILabel!
    
    @IBOutlet var titleLabel: UILabel!
    
    @IBOutlet weak var imageProfile: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }


}
