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

    class func convertDataToDictionary(_ data:Data)->Dictionary<String,Any>?{
        do {
            let dictionary = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableLeaves) as? Dictionary<String,Any>
            return dictionary
        }
            
        catch let error as NSError{
            NSLog("Could not create dictionary from string, with error: \(error)")
            return nil
        }
    }
    
    class func convertDictionaryToString(_ dictionary:Dictionary<String,Any>)->String?{
        do {
            let data = try JSONSerialization.data(withJSONObject: dictionary, options: JSONSerialization.WritingOptions(rawValue: 0))
            let string = String(data: data, encoding: String.Encoding.utf8)
            return string
        }
            
        catch let error as NSError{
            NSLog("Could not parse dictionary, with error: \(error)")
            return nil
        }
    }
    
    class func showActivityView(inView view:UIView, withFrame frame: CGRect, text: String?) -> ActivityView {
        let activityView = ActivityView(frame: frame)
        activityView.alpha = 0.0
        view.addSubview(activityView)
        activityView.activityIndicator.startAnimating()
        UIView.animate(withDuration: 0.2, animations: {
            activityView.alpha = 1.0
        })
        return activityView
    }
    
    class func removeActivityView(_ activityView:ActivityView){
        
        UIView.animate(withDuration: 0.2, animations: {
            activityView.alpha = 0.0
        }) { (success: Bool) in
            activityView.removeFromSuperview()
        }
    }
}
