//
//  ButtonCell.swift
//  Jabrutouch
//
//  Created by Shlomo Carmen on 07/10/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import UIKit

class ButtonCell: UITableViewCell {

    @IBOutlet weak var button: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        self.button.layer.cornerRadius = 10
        // Configure the view for the selected state
    }

}
