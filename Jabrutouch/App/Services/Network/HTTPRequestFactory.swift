//בעזרת ה׳ החונן לאדם דעת
//  HTTPRequestFactory.swift
//  Jabrutouch
//
//  Created by Yoni Reiss on 29/07/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import Foundation

class HttpRequestsFactory {
    
    static let baseUrlLink = Bundle.main.object(forInfoDictionaryKey: "APIBaseUrl") as! String

    //==========================================
    // MARK: - Login Flow
    //==========================================
    
    class func createSendCodeRequest(phoneNumber: String) -> URLRequest?{
        guard let baseUrl = URL(string: HttpRequestsFactory.baseUrlLink) else { return nil }
        let link = baseUrl.appendingPathComponent("send_code/").absoluteString
        let body: [String:String] = ["phone": phoneNumber]
        guard let url = self.createUrl(fromLink: link, urlParams: nil) else { return nil }
        let request = self.createRequest(url, method: .post, body: body, additionalHeaders: nil)
        return request
    }
    
    class func createResendCodeRequest(phoneNumber: String) -> URLRequest?{
        guard let baseUrl = URL(string: HttpRequestsFactory.baseUrlLink) else { return nil }
        let link = baseUrl.appendingPathComponent("send_again/").absoluteString
        let body: [String:String] = ["phone": phoneNumber]
        guard let url = self.createUrl(fromLink: link, urlParams: nil) else { return nil }
        let request = self.createRequest(url, method: .post, body: body, additionalHeaders: nil)
        return request
    }
    
    class func createValidateCodeRequest(phoneNumber:String, code: String) -> URLRequest?{
        guard let baseUrl = URL(string: HttpRequestsFactory.baseUrlLink) else { return nil }
        let link = baseUrl.appendingPathComponent("send_again/").absoluteString
        let body: [String:Any] = [ "phone": phoneNumber, "code": code]
        guard let url = self.createUrl(fromLink: link, urlParams: nil) else { return nil }
        let request = self.createRequest(url, method: .post, body: body, additionalHeaders: nil)
        return request
    }
    
    class func createSignUpRequest(firstName: String, lastName:String, email:String, phoneNumber:String, fcmToken:String, password: String) -> URLRequest?{
        guard let baseUrl = URL(string: HttpRequestsFactory.baseUrlLink) else { return nil }
        let link = baseUrl.appendingPathComponent("sing_up/").absoluteString
        let body: [String:Any] = ["first_name": firstName, "last_name": lastName, "email": email, "password": password, "device_type":"ios", "phone": phoneNumber, "fcm_token": fcmToken]
        guard let url = self.createUrl(fromLink: link, urlParams: nil) else { return nil }
        let request = self.createRequest(url, method: .patch, body: body, additionalHeaders: nil)
        return request
    }
    
    class func createLoginRequest(email: String?, phoneNumber: String?, password: String, fcmToken: String) -> URLRequest?{
        guard let baseUrl = URL(string: HttpRequestsFactory.baseUrlLink) else { return nil }
        if email == nil && phoneNumber == nil { return nil }
        let link = baseUrl.appendingPathComponent("login/").absoluteString
        let body: [String:Any] = [ "email": email ?? "", "password": password, "device_type":"ios", "phone": phoneNumber ?? "", "fcm_token": fcmToken]
        guard let url = self.createUrl(fromLink: link, urlParams: nil) else { return nil }
        let request = self.createRequest(url, method: .post, body: body, additionalHeaders: nil)
        return request
    }
    
    //==========================================
    // MARK: - Login Flow
    //==========================================
    
    class func createGetUserRequest(token: String) -> URLRequest?{
        guard let baseUrl = URL(string: HttpRequestsFactory.baseUrlLink) else { return nil }
        let link = baseUrl.appendingPathComponent("users/6/").absoluteString
        guard let url = self.createUrl(fromLink: link, urlParams: nil) else { return nil }
        let additionalHeaders: [String:String] = ["Authorization": "token \(token)"]
        let request = self.createRequest(url, method: .get, body: nil, additionalHeaders: additionalHeaders)
        return request
    }
    
    class func createChangePasswordRequest(oldPassword: String, newPassword: String, token: String) -> URLRequest?{
        guard let baseUrl = URL(string: HttpRequestsFactory.baseUrlLink) else { return nil }
        let link = baseUrl.appendingPathComponent("login/").absoluteString
        let body: [String:Any] = ["old_password": oldPassword, "new_password": newPassword]
        guard let url = self.createUrl(fromLink: link, urlParams: nil) else { return nil }
        let additionalHeaders: [String:String] = ["Authorization": "token \(token)"]

        let request = self.createRequest(url, method: .post, body: body, additionalHeaders: additionalHeaders)
        return request
    }
    //==========================================
    // MARK: - Utils & Helpers
    //==========================================

    private class func createUrl(fromLink link: String, urlParams: [String:String]?) -> URL? {
        guard let url = URL(string: link), var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return nil }
        
        var urlQueryItems:[URLQueryItem] = []
        for (key,value) in urlParams ?? [:] {
            let urlQueryItem = URLQueryItem(name: key, value: value)
            urlQueryItems.append(urlQueryItem)
        }
        urlComponents.queryItems = urlQueryItems
        guard let result = urlComponents.url else {
            return nil
        }
        return result
    }
    
    private class func createRequest(_ url:URL,method:HttpRequestMethod,body:[String:Any]?,additionalHeaders:[String:String]?)->URLRequest {
        
        let timeoutInterval = 10.0
        let request:NSMutableURLRequest = NSMutableURLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: timeoutInterval)
        request.httpMethod = method.rawValue
        if body != nil {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: body!, options: JSONSerialization.WritingOptions.prettyPrinted)
            }
            catch let error {
                print(error.localizedDescription)
            }
        }
        if additionalHeaders != nil{
            for (key,value) in additionalHeaders!{
                request.addValue(value, forHTTPHeaderField: key)
            }
            
        }
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        return request as URLRequest
    }
}
