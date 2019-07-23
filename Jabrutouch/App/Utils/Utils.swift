//בעזרת ה׳ החונן לאדם דעת
//  Utils.swift
//  Jabrutouch
//
//  Created by Yoni Reiss on 22/07/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import UIKit

class Utils {
    
    class func keyboardToolBarWithDoneButton(tintColor: UIColor, target: Any?, selector: Selector?) -> UIToolbar{
        let keyboardToolbar = UIToolbar()
        keyboardToolbar.sizeToFit()
        let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: target, action: selector)
        doneBarButton.tintColor = tintColor
        keyboardToolbar.items = [flexBarButton, doneBarButton]
        
        return keyboardToolbar
    }

    class func keyboardToolBarWithDoneAndCancelButtons(tintColor: UIColor, target: Any?, doneSelector: Selector?, cancelSelector: Selector?) -> UIToolbar{
        let keyboardToolbar = UIToolbar()
        keyboardToolbar.sizeToFit()
        let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: target, action: doneSelector)
        let cancelBarButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: target, action: cancelSelector)
        doneBarButton.tintColor = tintColor
        cancelBarButton.tintColor = tintColor
        keyboardToolbar.items = [cancelBarButton, flexBarButton, doneBarButton]
        
        return keyboardToolbar
    }
    
    class func convertDataToJSONObject(_ data:Data)-> Any?{
        do {
            let obj = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableLeaves)
            return obj
        }
            
        catch {
            return nil
        }
    }

}
