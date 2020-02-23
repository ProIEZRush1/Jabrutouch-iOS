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
    func setButtonImage(NormalImage: UIImage, highlightedImage: UIImage) {
        
    }
    
    func setProgress(progress: CGFloat?, fontColor: UIColor, ringColor: UIColor) {
        
    }
    
    // MARK: - Private Methods
    
    private func setProgressRing() {
        
    }
}
