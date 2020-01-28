//
//  HistoryCell.swift
//  Jabrutouch
//
//  Created by Shlomo Carmen on 27/01/2020.
//  Copyright © 2020 Ravtech. All rights reserved.
//

import UIKit

class HistoryCell: UITableViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var keterImageView: UIImageView!
    
    @IBOutlet weak var receiptView: UIView!
    @IBOutlet weak var receiptLabel: UILabel!
    @IBOutlet weak var receiptImageView: UIImageView!
    @IBOutlet weak var nextButton: UIButton!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.roundCorners()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func roundCorners() {
        self.receiptView.layer.cornerRadius = self.receiptView.bounds.height/2
        self.receiptView.layer.borderColor = Colors.textMediumBlue.cgColor
        self.receiptView.layer.borderWidth = 1.0
    }

}
