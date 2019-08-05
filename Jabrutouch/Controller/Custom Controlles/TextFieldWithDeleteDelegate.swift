//בעזרת ה׳ החונן לאדם דעת
//  TextFieldWithDeleteDelegate.swift
//  DigiThane
//
//  Created by Yoni Reiss on 06/07/2017.
//  Copyright © 2017 Ravtech. All rights reserved.
//

import UIKit

protocol TextFieldDeleteDelegate{
    func textFieldDidDelete(textField:UITextField)
}
class TextFieldWithDeleteDelegate: UITextField {
    var deleteDelegate : TextFieldDeleteDelegate?
    
    override func deleteBackward() {
        super.deleteBackward()
        
        print("deleteBackwards, text: \(self.text ?? "")")
        self.deleteDelegate?.textFieldDidDelete(textField: self)
    }
}
