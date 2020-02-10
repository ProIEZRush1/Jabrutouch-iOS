//
//  PersonalDetailsCell.swift
//  Jabrutouch
//
//  Created by Shlomo Carmen on 07/10/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import UIKit

class PersonalDetailsCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var country: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
