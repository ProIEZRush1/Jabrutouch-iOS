//
//  ForgotPasswordViewController.swift
//  Jabrutouch
//
//  Created by Shlomo Carmen on 14/11/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import UIKit

class ForgotPasswordViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var exitButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var textFieldView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.textField.delegate = self
        
        self.setShadow()
        self.roundCornors()
        self.setBorders()
        
    }
    
    func roundCornors() {
        self.containerView.layer.cornerRadius = 31
        self.sendButton.layer.cornerRadius = 18
        self.textFieldView.layer.cornerRadius = self.textFieldView.bounds.height/2
        self.textField.layer.cornerRadius = self.textField.bounds.height/2
        
    }
    
    func setBorders() {
        self.textFieldView.layer.borderColor = Colors.borderGray.cgColor
        self.textFieldView.layer.borderWidth = 1.0
    }
    
    func setShadow() {
        let shadowOffset = CGSize(width: 0.0, height: 20)
        let color = #colorLiteral(red: 0.16, green: 0.17, blue: 0.39, alpha: 0.5)
        Utils.dropViewShadow(view: self.containerView, shadowColor: color, shadowRadius: 31, shadowOffset: shadowOffset)
    }
    
    @IBAction func sendButtonPressed(_ sender: Any) {
        
    }
    
    @IBAction func exitButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
