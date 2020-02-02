//בעזרת ה׳ החונן לאדם דעת
//  JTBarPageIndicator.swift
//  Jabrutouch
//
//  Created by Yoni Reiss on 16/07/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import UIKit

//@IBDesignable
class JTBarPageIndicator: UIView {

    @IBInspectable var selectedIndex: Int = 0 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    @IBInspectable var count: Int = 4
    @IBInspectable var selectedColor: UIColor = Colors.appBlue
    @IBInspectable var unselectedColor: UIColor = Colors.appLightGray
    @IBInspectable var barWidth: CGFloat = 45.0
    @IBInspectable var barHeight: CGFloat = 3
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
