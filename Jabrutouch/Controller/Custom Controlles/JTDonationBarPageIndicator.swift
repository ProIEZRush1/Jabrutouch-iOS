//
//  JTDonationBarPageIndicator.swift
//  Jabrutouch
//
//  Created by Avraham Deutsch on 26/07/2020.
//  Copyright © 2020 Ravtech. All rights reserved.
//

import UIKit

//@IBDesignable
class JTDonationBarPageIndicator: UIView {

    @IBInspectable var selectedIndex: Int = 0 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    @IBInspectable var count: Int = 3
    @IBInspectable var selectedColor: UIColor = Colors.appBlue
    @IBInspectable var unselectedColor: UIColor = Colors.appLightGray
    @IBInspectable var barWidth: CGFloat = 7
    @IBInspectable var barHeight: CGFloat = 7
    @IBInspectable var spacing: CGFloat = 9.0
    
    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        let spacingCount = CGFloat(count - 1)
        var startX = rect.midX - barWidth * (CGFloat(count)/2) - spacing * (spacingCount/2)
        
        for index in 0..<count {
            let rect = CGRect(x: startX, y: rect.midY - barHeight/2, width: barWidth, height: barHeight)
            let path = UIBezierPath(roundedRect: rect, byRoundingCorners: UIRectCorner.allCorners, cornerRadii: CGSize(width: barHeight/2, height: barHeight/2))
            ctx.addPath(path.cgPath)
            let color = index == self.selectedIndex ? self.selectedColor : self.unselectedColor
            ctx.setFillColor(color.cgColor)
            ctx.fillPath()
            startX += (barWidth+spacing)
        }
    }
 

}


