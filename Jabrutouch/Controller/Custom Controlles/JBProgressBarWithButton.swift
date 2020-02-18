//
//  JBProgressBarWithButton.swift
//  Jabrutouch
//
//  Created by Shlomo Carmen on 16/02/2020.
//  Copyright © 2020 Ravtech. All rights reserved.
//

import UIKit
import UICircularProgressRing

class JBProgressBarWithButton: UIView {

    // MARK: - @IBOutlets
    @IBOutlet weak var downloadProgressView: UICircularProgressRing!
    @IBOutlet weak var button: UIButton!
        
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
        let nib:UINib = UINib(nibName: "ProgressBarWithButton", bundle: bundle)
        
        // Assumes UIView is top level and only object in CustomView.xib file
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
    
    // MARK: - Main Methods
    func setButtonImage(NormalImage: UIImage, highlightedImage: UIImage) {
        self.button.setImage(NormalImage, for: .normal)
        self.button.setImage(highlightedImage, for: .highlighted)
        
    }
    
    func setProgress(progress: CGFloat?, fontColor: UIColor, ringColor: UIColor) {
        if let progress = progress {
            self.button.isHidden = true
            self.downloadProgressView.isHidden = false
            
            self.downloadProgressView.value = progress
            self.setProgressRing(fontColor: fontColor, ringColor: ringColor)
        }
        else {
            self.button.isHidden = false
            self.downloadProgressView.isHidden = true
        }
    }
    
    // MARK: - Private Methods
    
    private func setProgressRing(fontColor: UIColor, ringColor: UIColor) {
        let startColor: UIColor = UIColor(red: 0.3, green: 0.31, blue: 0.82, alpha: 1)
        let endColor: UIColor = UIColor(red: 1, green: 0.37, blue: 0.31, alpha: 1)
        self.downloadProgressView.fontColor = fontColor
        self.downloadProgressView.outerRingColor = ringColor
        self.downloadProgressView.gradientOptions = UICircularRingGradientOptions(startPosition: .topRight,
        endPosition: .bottomRight,
        colors: [startColor, endColor],
        colorLocations: [0.1, 1])
    }
}
