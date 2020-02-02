//
//  DonorsCell.swift
//  Jabrutouch
//
//  Created by Shlomo Carmen on 27/01/2020.
//  Copyright © 2020 Ravtech. All rights reserved.
//

import UIKit

class DonorsCell: UITableViewCell {

    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var flagImageView: UIImageView!
    @IBOutlet weak var logoImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
