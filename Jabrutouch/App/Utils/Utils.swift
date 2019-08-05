//בעזרת ה׳ החונן לאדם דעת
//  Utils.swift
//  Jabrutouch
//
//  Created by Yoni Reiss on 22/07/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import UIKit

class Utils {
    
    // MARK: - Alerts
    
    class func showAlertMessage(_ message:String ,viewControler:UIViewController){
        let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: Strings.ok, style: .default, handler: nil)
        alertController.addAction(okAction)
        DispatchQueue.main.async {
            viewControler.present(alertController, animated: true, completion: nil)
        }
    }
    class func showAlertMessage(_ message:String,title:String?,viewControler:UIViewController){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: Strings.ok, style: .default, handler: nil)
        alertController.addAction(okAction)
        DispatchQueue.main.async {
            viewControler.present(alertController, animated: true, completion: nil)
        }
    }
    class func showAlertMessage(_ message:String,title:String?,viewControler:UIViewController,handler:@escaping ((_ action:UIAlertAction)->Void)){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: Strings.ok, style: .default, handler: handler)
        alertController.addAction(okAction)
        DispatchQueue.main.async {
            viewControler.present(alertController, animated: true, completion: nil)
        }
    }
    
    class func showAlertMessage(_ message:String,title:String?,viewControler:UIViewController,actions:[UIAlertAction]) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        for action in actions {
            alertController.addAction(action)
        }
        
        DispatchQueue.main.async {
            viewControler.present(alertController, animated: true, completion: nil)
        }
    }
    
    
    // MARK: - Custom keyboards
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
    
    
    // MARK: - Parsing and Conversion
    
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
    

    // MARK: - ActivityView
    
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
    
    // MARK: - UI
    
    class func setViewShape(view: UIView, viewBorderWidht: CGFloat = 0, viewBorderColor: UIColor = .white, viewCornerRadius: CGFloat = 0) {
        view.layer.cornerRadius = viewCornerRadius
        view.layer.borderWidth = viewBorderWidht
        view.layer.borderColor = viewBorderColor.cgColor
    }
    
    class func dropViewShadow(view: UIView, shadowColor: UIColor, shadowRadius: CGFloat, shadowOffset: CGSize) {
        view.layer.shadowColor = shadowColor.cgColor
        view.layer.shadowOffset = shadowOffset
        view.layer.shadowOpacity = 1.0
        view.layer.shadowRadius = shadowRadius
        view.layer.masksToBounds = false
        view.translatesAutoresizingMaskIntoConstraints = false

    }
    
    // MARK: - Validation
    
    class func validateEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    class func validatePhoneNumber(_ phoneNumber: String) -> Bool {
        let charcterSet  = CharacterSet(charactersIn: "+0123456789").inverted
        let inputString = phoneNumber.components(separatedBy: charcterSet)
        let filtered = inputString.joined(separator: "")
        if let lastPlusIndex = phoneNumber.lastIndex(of: "+") {
            return  (phoneNumber == filtered) && lastPlusIndex == phoneNumber.startIndex
        }
        else {
            return  (phoneNumber == filtered)
        }
    }
}
