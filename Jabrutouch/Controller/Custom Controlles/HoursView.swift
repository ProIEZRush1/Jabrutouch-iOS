//
//  HoursView.swift
//  Jabrutouch
//
//  Created by Shlomo Carmen on 23/02/2020.
//  Copyright © 2020 Ravtech. All rights reserved.
//

import UIKit

class HoursView: UIView {
    
    // MARK: - @IBOutlets
    
    @IBOutlet weak var currentLabel: UILabel!
    @IBOutlet weak var nextLabel: UILabel!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var currentNumberYConstraint: NSLayoutConstraint!
    @IBOutlet weak var nextNumberYConstraint: NSLayoutConstraint!
    
    // MARK: - Properties
    
    var view: UIView!
    
    // MARK: - Init
    
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
        let nib:UINib = UINib(nibName: "HoursView", bundle: bundle)
        
        // Assumes UIView is top level and only object in CustomView.xib file
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
    
    // MARK: - Main Methods
    func changeValue(newValue: String) {
        self.nextLabel.text = newValue
        UIView.animate(withDuration: 0.7, animations: {
            self.currentNumberYConstraint.constant = -40
            self.currentLabel.alpha = 0
            self.nextNumberYConstraint.constant = 0
            self.nextLabel.alpha = 1
            DispatchQueue.main.asyncAfter(deadline:  .now() + 0.6) {
                self.setDefultPosition()

            }
            self.layoutIfNeeded()
        })
    }
    
    func setDefultPosition() {
        self.currentNumberYConstraint.constant = 0
        self.currentLabel.alpha = 1
        self.nextNumberYConstraint.constant = 40
        self.nextLabel.alpha = 0
        self.currentLabel.text = self.nextLabel.text
    }
    
    // MARK: - Private Methods
    
    func setShadow() {
        let shadowOffset = CGSize(width: 0.0, height: 20)
        let color = #colorLiteral(red: 0.2359343767, green: 0.2592330873, blue: 0.7210982442, alpha: 0.48)
        Utils.dropViewShadow(view: self.currentLabel, shadowColor: color, shadowRadius: 20, shadowOffset: shadowOffset)
    }
}
