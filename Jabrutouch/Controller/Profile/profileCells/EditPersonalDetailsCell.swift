//
//  EditPersonalDetailsCell.swift
//  Jabrutouch
//
//  Created by Shlomo Carmen on 27/10/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import UIKit

class EditPersonalDetailsCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak private var firstNameView: UIView!
    @IBOutlet weak private var lastNameView: UIView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var firstNameTextField: TextFieldWithPadding!
    @IBOutlet weak var lastNameTextField: TextFieldWithPadding!
    @IBOutlet weak var profileImageButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.roundCorners()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        self.addBorders()
        self.setShadow()
    }
    
    func roundCorners() {
        self.firstNameView.layer.cornerRadius = self.firstNameView.bounds.height/2
        self.lastNameView.layer.cornerRadius = self.lastNameView.bounds.height/2
        self.firstNameTextField.layer.cornerRadius = self.firstNameTextField.bounds.height/2
        self.lastNameTextField.layer.cornerRadius = self.lastNameTextField.bounds.height/2
        self.profileImage.layer.cornerRadius = self.profileImage.bounds.height/2
        self.profileImageButton.layer.cornerRadius = self.profileImageButton.bounds.height/2
        self.profileImage.clipsToBounds = true
//        self.profileImageButton.clipsToBounds = true
    }
    
    private func addBorders() {
        self.firstNameView.layer.borderColor = Colors.borderGray.cgColor
        self.firstNameView.layer.borderWidth = 1.0
        
        self.lastNameView.layer.borderColor = Colors.borderGray.cgColor
        self.lastNameView.layer.borderWidth = 1.0
    }
    
    func setShadow(){
        let color = #colorLiteral(red: 0.1, green: 0.12, blue: 0.57, alpha: 0.1)
        self.profileImageButton.layer.shadowPath = UIBezierPath(roundedRect: self.profileImageButton.bounds, cornerRadius: self.profileImageButton.bounds.height/2).cgPath        
        Utils.dropViewShadow(view: self.profileImageButton, shadowColor: color, shadowRadius: 26, shadowOffset: CGSize(width: 0, height: 8))
    }

}
