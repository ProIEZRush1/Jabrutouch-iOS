//
//  JBProgressBar.swift
//  Jabrutouch
//
//  Created by Shlomo Carmen on 22/10/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import UIKit

//@IBDesignable
class JBProgressBar: UIView {

    @IBInspectable var progress: CGFloat = 0.0 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable var rounded: Bool = true
    
    @IBInspectable var startColor: UIColor = UIColor(red: 0.3, green: 0.31, blue: 0.82, alpha: 1)
    @IBInspectable var endColor: UIColor = UIColor(red: 1, green: 0.37, blue: 0.31, alpha: 1)
    @IBInspectable var barTint: UIColor = #colorLiteral(red: 0.831, green: 0.863, blue: 0.906, alpha: 0.33)
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        // 1. Fill all view in bckground color
        context.setFillColor(UIColor.white.cgColor)
        context.fill(rect)
        
        // 2. Draw bar. If rounded create rounded rect path for the bar.
        if self.rounded {
            let progressPath = CGPath(roundedRect: rect, cornerWidth: rect.height/2, cornerHeight: rect.height/2, transform: nil)
            context.addPath(progressPath)
            context.clip()
        }
        context.setFillColor(self.barTint.cgColor)
        context.fill(rect)
        
        // 3. Draw progress. If rounded create rounded rect path for the progress.
        let progressRect = CGRect(x: 0, y: 0, width: rect.width*self.progress, height: rect.height)
        if self.rounded {
            let progressPath = CGPath(roundedRect: progressRect, cornerWidth: rect.height/2, cornerHeight: rect.height/2, transform: nil)
            context.addPath(progressPath)
            context.clip()
        }
        let colors = [self.startColor.cgColor, self.endColor.cgColor]
        if let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors as CFArray, locations: [0.54, 1]) {
            context.drawLinearGradient(gradient, start: CGPoint.zero, end: CGPoint(x: progressRect.maxX, y: 0.0), options: .drawsBeforeStartLocation)
        }
    }

}
