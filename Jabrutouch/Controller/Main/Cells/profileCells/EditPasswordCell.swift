//
//  EditPasswordCell.swift
//  Jabrutouch
//
//  Created by Shlomo Carmen on 13/11/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import UIKit

class EditPasswordCell: UITableViewCell {

    @IBOutlet weak var oldContanerView: UIView!
    @IBOutlet weak var oldShadowView: UIView!
    @IBOutlet weak var newContanerView: UIView!
    @IBOutlet weak var newShadowView: UIView!
    @IBOutlet weak var confirmContanerView: UIView!
    @IBOutlet weak var confirmShadowView: UIView!
    @IBOutlet weak var oldPasswordTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var confirmTextField: UITextField!
    @IBOutlet weak var forgotFassword: UIButton!
    
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
        self.oldContanerView.layer.cornerRadius = self.oldContanerView.bounds.height/2
        self.oldShadowView.layer.cornerRadius = self.confirmContanerView.bounds.height/2
        self.newContanerView.layer.cornerRadius = self.newContanerView.bounds.height/2
        self.newShadowView.layer.cornerRadius = self.confirmContanerView.bounds.height/2
        self.confirmContanerView.layer.cornerRadius = self.confirmContanerView.bounds.height/2
        self.confirmShadowView.layer.cornerRadius = self.confirmContanerView.bounds.height/2
    }
    
    private func addBorders() {
        self.oldContanerView.layer.borderColor = Colors.borderGray.cgColor
        self.oldContanerView.layer.borderWidth = 1.0
        
        self.newContanerView.layer.borderColor = Colors.borderGray.cgColor
        self.newContanerView.layer.borderWidth = 1.0
        
        self.confirmContanerView.layer.borderColor = Colors.borderGray.cgColor
        self.confirmContanerView.layer.borderWidth = 1.0
        
    }
    @IBAction func forgotPasswordPressed(_ sender: UIButton) {
        
    }

}
