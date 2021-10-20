//
//  SurveyCustomAnswerCell.swift
//  Jabrutouch
//
//  Created by Avraham Kirsch on 20/10/2021.
//  Copyright © 2021 Ravtech. All rights reserved.
//

import UIKit

class SurveyCustomAnswerCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var customAnswerTextField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
