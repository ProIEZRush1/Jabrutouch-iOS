//
//  DedicationCardView.swift
//  Jabrutouch
//
//  Created by Shlomo Carmen on 30/01/2020.
//  Copyright © 2020 Ravtech. All rights reserved.
//

import UIKit

class DedicationCardView: UIView {

    //========================================
    // MARK: - Properties
    //========================================
   
   
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
    @IBOutlet weak var topLabelConstraint: NSLayoutConstraint!
    
    
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
        self.layer.cornerRadius = 15
        
    }
    func setBorders() {
        self.textFieldView.layer.borderColor = Colors.borderGray.cgColor
        self.textFieldView.layer.borderWidth = 1.0
    }
    
    func setShadow() {
        let color = #colorLiteral(red: 0.1, green: 0.12, blue: 0.57, alpha: 0.4)
        Utils.dropViewShadow(view: self, shadowColor: color, shadowRadius: 12, shadowOffset: CGSize(width: 0, height: 12))
    }
    
    
}
