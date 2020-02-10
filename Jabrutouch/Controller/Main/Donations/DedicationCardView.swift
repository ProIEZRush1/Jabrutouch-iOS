//
//  DedicationCardView.swift
//  Jabrutouch
//
//  Created by Shlomo Carmen on 30/01/2020.
//  Copyright © 2020 Ravtech. All rights reserved.
//

import UIKit

protocol DedicationCardDelegate {
    func changedName(_ name: String)
}

class DedicationCardView: UIView {

    //========================================
    // MARK: - Properties
    //========================================
   
    var delegate: DedicationCardDelegate?
   
    //========================================
    // MARK: - @IBOutlets
    //========================================
    
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var dedicationLabel: UILabel!
    @IBOutlet weak var textField: TextFieldWithPadding!
    @IBOutlet weak var textFieldView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var topLabelConstraint: NSLayoutConstraint!
    @IBOutlet weak var editNameButton: UIButton!
    @IBOutlet weak var editNameTFView: UIView!
    @IBOutlet weak var editNameTextField: TextFieldWithPadding!
    @IBOutlet weak var saveNameButton: UIButton!
    
    
    //========================================
    // MARK: - LifeCycle
    //========================================
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.xibSetup()
        
    }
    
    override func awakeFromNib() {
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.xibSetup()
        

    }
    
    // Our custom view from the XIB file
    var view: UIView!
    
    func xibSetup() {
        self.view = loadViewFromNib()
        
        // use bounds not frame or it'll be offset
        self.view.frame = bounds
        
        // Make the view stretch with containing view
        self.view.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
        
        // Adding custom subview on top of our view (over any custom drawing > see note below)
        self.addSubview(view)
        self.backgroundColor = .clear
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib:UINib = UINib(nibName: "DedicationCardView", bundle: bundle)
        
        // Assumes UIView is top level and only object in CustomView.xib file
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
    
    func roundCornors() {
        self.textFieldView.layer.cornerRadius = self.textFieldView.bounds.height/2
        self.textField.layer.cornerRadius = self.textField.bounds.height/2
        self.editNameTFView.layer.cornerRadius = self.editNameTFView.bounds.height/2
        self.editNameTextField.layer.cornerRadius = self.editNameTextField.bounds.height/2
        self.layer.cornerRadius = 15
        self.containerView.layer.cornerRadius = 15
        self.profileImage.layer.cornerRadius = self.profileImage.bounds.height/2
        
    }
    
    func setBorders() {
        self.textFieldView.layer.borderColor = Colors.borderGray.cgColor
        self.textFieldView.layer.borderWidth = 1.0
        
        self.editNameTFView.layer.borderColor = Colors.borderGray.cgColor
        self.editNameTFView.layer.borderWidth = 1.0
    }
    
    func setShadow() {
        let color = #colorLiteral(red: 0.157, green: 0.166, blue: 0.393, alpha: 0.2)
        Utils.dropViewShadow(view: self.containerView, shadowColor: color, shadowRadius: 14, shadowOffset: CGSize(width: 0, height: 14))
    }
    
    @IBAction func editNameButtonPressed(_ sender: Any) {
        self.editNameTextField.becomeFirstResponder()
        self.userNameLabel.isHidden = true
        self.editNameTFView.isHidden = false
    }
    
    @IBAction func saveNameButtonPressed(_ sender: Any) {
        self.userNameLabel.isHidden = false
        self.editNameTFView.isHidden = true
        self.editNameTextField.resignFirstResponder()
        
        if let name = self.editNameTextField.text {
            self.delegate?.changedName(name)
        }
//        self.editNameTextField.text = ""
    }
    
}
