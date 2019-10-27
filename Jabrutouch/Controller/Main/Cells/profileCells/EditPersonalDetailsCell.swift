//
//  EditPersonalDetailsCell.swift
//  Jabrutouch
//
//  Created by Shlomo Carmen on 27/10/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import UIKit

class EditPersonalDetailsCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var firstNameTextField: TextFieldWithPadding!
    @IBOutlet weak var lastNameTextField: TextFieldWithPadding!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        self.addBorders()
        self.roundCorners()
        // Configure the view for the selected state
    }
    
    private func roundCorners() {
        self.firstNameTextField.layer.cornerRadius = self.firstNameTextField.bounds.height/2
        self.lastNameTextField.layer.cornerRadius = self.lastNameTextField.bounds.height/2
        self.profileImage.layer.cornerRadius = self.profileImage.bounds.height/2
    }
    
    private func addBorders() {
        self.firstNameTextField.layer.borderColor = Colors.borderGray.cgColor
        self.firstNameTextField.layer.borderWidth = 1.0
        
        self.lastNameTextField.layer.borderColor = Colors.borderGray.cgColor
        self.lastNameTextField.layer.borderWidth = 1.0
    }

}
