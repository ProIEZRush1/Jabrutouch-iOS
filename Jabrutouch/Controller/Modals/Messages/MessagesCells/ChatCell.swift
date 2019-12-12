//
//  ChatCell.swift
//  Jabrutouch
//
//  Created by Shlomo Carmen on 05/12/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import UIKit

class ChatCell: UITableViewCell {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var groupName: UILabel!
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var groupImage: UIImageView!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
