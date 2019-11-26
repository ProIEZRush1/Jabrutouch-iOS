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
    
    class func convertStringToDictionary(_ string:String)->NSDictionary?{
        do {
            let data = string.data(using: String.Encoding.utf8)
            let dictionary = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableLeaves) as! NSDictionary
            return dictionary
        }
            
        catch let error as NSError{
            NSLog("Could not create dictionary from string, with error: \(error)")
            return nil
        }
    }
    
    class func convertTimeInSecondsToDisplayString(_ time: TimeInterval) -> String {
        if time.isNaN { return "--:--"}
        let minutes = Int(time/60)
        let seconds = Int(time.truncatingRemainder(dividingBy: 60))
        let minutesString = minutes < 10 ? "0\(minutes)" : "\(minutes)"
        let secondsString = seconds < 10 ? "0\(seconds)" : "\(seconds)"
        return "\(minutesString):\(secondsString)"
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
    
    class func setProgressbar(count: Double, view: JBProgressBar, rounded: Bool, cornerRadius: CGFloat, bottomRadius: Bool) {
        let count = count
        let progress = CGFloat(count)
        view.progress = progress
        view.rounded = rounded
        view.layer.cornerRadius = cornerRadius
        if bottomRadius {
            view.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        }
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
    
    class func linearGradientImage(size: CGSize, colors: [UIColor]) -> UIImage? {
        let gradientLayer = CAGradientLayer()
        let frame = CGRect.init(x:0, y:0, width:size.width, height: size.height)
        gradientLayer.frame = frame
        gradientLayer.colors = colors.map{$0.cgColor}
        gradientLayer.startPoint = CGPoint.init(x:0.0, y:0.5)
        gradientLayer.endPoint = CGPoint.init(x:1.0, y:0.5)
        UIGraphicsBeginImageContextWithOptions(gradientLayer.frame.size, gradientLayer.isOpaque, 0.0);
        gradientLayer.render(in: UIGraphicsGetCurrentContext()!)
        if let image = UIGraphicsGetImageFromCurrentImageContext() {
            UIGraphicsEndImageContext()            
            image.resizableImage(withCapInsets: UIEdgeInsets.zero)
            return image
        }
        return nil
    }
    
    
}
