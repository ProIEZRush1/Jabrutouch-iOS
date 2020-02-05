//בעזרת ה׳ החונן לאדם דעת
//  CustomTrackHeightSlider.swift
//  Jabrutouch
//
//  Created by Yoni Reiss on 29/08/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import UIKit

//@IBDesignable
class CustomTrackHeightSlider: UISlider {

   
    @IBInspectable var trackHeight: CGFloat = 2
    
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        //set your bounds here
        return CGRect(x: bounds.minX, y: bounds.midY-trackHeight, width: bounds.width, height: self.trackHeight)
    }

}
