//בעזרת ה׳ החונן לאדם דעת
//  TextFieldWithPadding.swift
//  DigiThane
//
//  Created by Yoni Reiss on 04/07/2017.
//  Copyright © 2017 Ravtech. All rights reserved.
//

import UIKit

@IBDesignable
class TextFieldWithPadding: UITextField {

    
    @IBInspectable var leadingPadding:CGFloat = 25.0
    @IBInspectable var trailingPadding:CGFloat = 25.0
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        let width = bounds.width - self.leadingPadding - self.trailingPadding
        let size = CGSize(width: width, height: bounds.height)
        let origin = CGPoint(x: self.leadingPadding, y: 0)
        return CGRect(origin: origin, size: size)
    }
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let width = bounds.width - self.leadingPadding - self.trailingPadding
        let size = CGSize(width: width, height: bounds.height)
        let origin = CGPoint(x: self.leadingPadding, y: 0)
        return CGRect(origin: origin, size: size)
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
