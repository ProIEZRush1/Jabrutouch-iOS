//
//  GeneralInformationCell.swift
//  Jabrutouch
//
//  Created by Shlomo Carmen on 07/10/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import UIKit

class GeneralInformationCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
