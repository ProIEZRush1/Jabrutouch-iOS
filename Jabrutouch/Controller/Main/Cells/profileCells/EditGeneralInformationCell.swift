//
//  EditGeneralInformationCell.swift
//  Jabrutouch
//
//  Created by Shlomo Carmen on 27/10/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import UIKit

class EditGeneralInformationCell: UITableViewCell {
    
    @IBOutlet weak var contanerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var arrowImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        self.roundCorners()
        self.addBorders()
        
    }
    private func roundCorners() {
           self.contanerView.layer.cornerRadius = self.contanerView.bounds.height/2
       }
       
       private func addBorders() {
           self.contanerView.layer.borderColor = Colors.borderGray.cgColor
           self.contanerView.layer.borderWidth = 1.0
         
       }
}
