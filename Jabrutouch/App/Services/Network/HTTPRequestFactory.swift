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
        // encrypt phone number wrapped in {msg:encryptedMsg}
        guard let secretMsg = OTPSecurityManager.encryptMsg(phone: phoneNumber) else {
            print("secretMsg is null!!!!!")
            return nil
        }
        
        guard let baseUrl = URL(string: HttpRequestsFactory.baseUrlLink) else { return nil }
        let link = baseUrl.appendingPathComponent("send_code/").absoluteString
//        let body: [String:String] = ["phone": phoneNumber]
        let body: [String:String] = ["msg": secretMsg]
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
        let link = baseUrl.appendingPathComponent("validate_code/").absoluteString
        let body: [String:Any] = [ "phone": phoneNumber, "code": code]
        guard let url = self.createUrl(fromLink: link, urlParams: nil) else { return nil }
        let request = self.createRequest(url, method: .post, body: body, additionalHeaders: nil)
        return request
    }

    //==========================================
    // MARK: - Email Verification Flow
    //==========================================

    class func createSendEmailCodeRequest(email: String) -> URLRequest? {
        // Encrypt email wrapped in {msg:encryptedMsg}
        guard let secretMsg = OTPSecurityManager.encryptEmail(email: email) else {
            print("secretMsg for email is null!")
            return nil
        }

        guard let baseUrl = URL(string: HttpRequestsFactory.baseUrlLink) else { return nil }
        let link = baseUrl.appendingPathComponent("send_email_code/").absoluteString
        let body: [String:String] = ["msg": secretMsg]
        guard let url = self.createUrl(fromLink: link, urlParams: nil) else { return nil }
        let request = self.createRequest(url, method: .post, body: body, additionalHeaders: nil)
        return request
    }

    class func createValidateEmailCodeRequest(email: String, code: String) -> URLRequest? {
        // Encrypt email and code wrapped in {msg:encryptedMsg}
        guard let secretMsg = OTPSecurityManager.encryptEmailCode(email: email, code: code) else {
            print("secretMsg for email code validation is null!")
            return nil
        }

        guard let baseUrl = URL(string: HttpRequestsFactory.baseUrlLink) else { return nil }
        let link = baseUrl.appendingPathComponent("validate_email_code/").absoluteString
        let body: [String:String] = ["msg": secretMsg]
        guard let url = self.createUrl(fromLink: link, urlParams: nil) else { return nil }
        let request = self.createRequest(url, method: .post, body: body, additionalHeaders: nil)
        return request
    }

    class func createEmailSignUpRequest(userId: Int, firstName: String, lastName: String, email: String, phoneNumber: String, fcmToken: String, password: String) -> URLRequest? {
        guard let baseUrl = URL(string: HttpRequestsFactory.baseUrlLink) else { return nil }
        let link = baseUrl.appendingPathComponent("email_signup/").absoluteString
        let body: [String:Any] = [
            "user_id": userId,
            "first_name": firstName,
            "last_name": lastName,
            "email": email,
            "phone": phoneNumber,
            "password": password,
            "device_type": "ios",
            "fcm_token": fcmToken
        ]
        guard let url = self.createUrl(fromLink: link, urlParams: nil) else { return nil }
        let request = self.createRequest(url, method: .post, body: body, additionalHeaders: nil)
        return request
    }

    class func createSignUpRequest(userId: Int, firstName: String, lastName:String, email:String, phoneNumber:String, fcmToken:String, password: String) -> URLRequest?{
        guard let baseUrl = URL(string: HttpRequestsFactory.baseUrlLink) else { return nil }
        let link = baseUrl.appendingPathComponent("sing_up/\(userId)/").absoluteString
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
    
    class func forgotPasswordRequest(email: String?) -> URLRequest?{
        guard let baseUrl = URL(string: HttpRequestsFactory.baseUrlLink) else { return nil }
        if email == nil { return nil }
        let link = baseUrl.appendingPathComponent("request_password_reset/").absoluteString  // Updated to use secure reset link endpoint
        let body: [String:Any] = [ "email": email ?? ""]
        guard let url = self.createUrl(fromLink: link, urlParams: nil) else { return nil }
        let request = self.createRequest(url, method: .post, body: body, additionalHeaders: nil)
        return request
    }

    class func confirmResetPasswordRequest(token: String, newPassword: String) -> URLRequest?{
        guard let baseUrl = URL(string: HttpRequestsFactory.baseUrlLink) else { return nil }
        let link = baseUrl.appendingPathComponent("confirm_reset_password/").absoluteString
        let body: [String:Any] = [ "token": token, "new_password": newPassword]
        guard let url = self.createUrl(fromLink: link, urlParams: nil) else { return nil }
        let request = self.createRequest(url, method: .post, body: body, additionalHeaders: nil)
        return request
    }
    
    class func changePasswordRequest(userId: Int, oldPassword: String?, newPassword: String?, token: String) -> URLRequest?{
        guard let baseUrl = URL(string: HttpRequestsFactory.baseUrlLink) else { return nil }
        if oldPassword == nil && newPassword == nil { return nil }
        let link = baseUrl.appendingPathComponent("users/\(userId)/change_password/").absoluteString
        let body: [String:Any] = [ "old_password": oldPassword ?? "", "new_password": newPassword ?? ""]
        guard let url = self.createUrl(fromLink: link, urlParams: nil) else { return nil }
        let additionalHeaders: [String:String] = ["Authorization": "token \(token)"]
        let request = self.createRequest(url, method: .post, body: body, additionalHeaders: additionalHeaders)
        return request
    }
    
    //==========================================
    // MARK: - User Flow
    //==========================================
    
    class func createGetUserRequest(userId: Int, token: String) -> URLRequest?{
        guard let baseUrl = URL(string: HttpRequestsFactory.baseUrlLink) else { return nil }
        let link = baseUrl.appendingPathComponent("users/\(userId)/").absoluteString
        guard let url = self.createUrl(fromLink: link, urlParams: nil) else { return nil }
        let additionalHeaders: [String:String] = ["Authorization": "token \(token)"]
        let request = self.createRequest(url, method: .get, body: nil, additionalHeaders: additionalHeaders)
        return request
    }
    
    class func createSetUserRequest(user: JTUser, token: String) -> URLRequest?{
        guard let baseUrl = URL(string: HttpRequestsFactory.baseUrlLink) else { return nil }
        let link = baseUrl.appendingPathComponent("users/\(user.id)").absoluteString
        let body: [String:Any] = user.jsonValues
        guard let url = self.createUrl(fromLink: link, urlParams: nil) else { return nil }
        let additionalHeaders: [String:String] = ["Authorization": "token \(token)"]
        let request = self.createRequest(url, method: .put, body: body, additionalHeaders: additionalHeaders)
        return request
    }
    
    class func createRemoveAccount(userId: Int, token: String) -> URLRequest?{
        guard let baseUrl = URL(string: HttpRequestsFactory.baseUrlLink) else { return nil }
        let link = baseUrl.appendingPathComponent("users/\(userId)").absoluteString
        guard let url = self.createUrl(fromLink: link, urlParams: nil) else { return nil }
        let additionalHeaders: [String:String] = ["Authorization": "token \(token)"]
        let request = self.createRequest(url, method: .delete,  body: nil, additionalHeaders: additionalHeaders)
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
    
    class func createGetEditUserParameters( token: String) -> URLRequest?{
        guard let baseUrl = URL(string: HttpRequestsFactory.baseUrlLink) else { return nil }
        let link = baseUrl.appendingPathComponent("profile_data").absoluteString
        guard let url = self.createUrl(fromLink: link, urlParams: nil) else { return nil }
        let additionalHeaders: [String:String] = ["Authorization": "token \(token)"]
        let request = self.createRequest(url, method: .get, body: nil, additionalHeaders: additionalHeaders)
        return request
    }
    
    class func createSetUserTour(token: String, tourNum: Int, user: Int, viewed: Bool) -> URLRequest?{
        guard let baseUrl = URL(string: HttpRequestsFactory.baseUrlLink) else { return nil }
        let link = baseUrl.appendingPathComponent("tour").absoluteString
        guard let url = self.createUrl(fromLink: link, urlParams: nil) else { return nil }
        let additionalHeaders: [String:String] = ["Authorization": "token \(token)"]
        let body = ["tour_num": tourNum, "user": user, "viewed": viewed] as [String : Any]
        let request = self.createRequest(url, method: .post, body: body, additionalHeaders: additionalHeaders)
        return request
    }
    
    class func createGetPopup( token: String) -> URLRequest?{
        guard let baseUrl = URL(string: HttpRequestsFactory.baseUrlLink) else { return nil }
        let link = baseUrl.appendingPathComponent("popups").absoluteString
        guard let url = self.createUrl(fromLink: link, urlParams: nil) else { return nil }
        let additionalHeaders: [String:String] = ["Authorization": "token \(token)"]
        let request = self.createRequest(url, method: .get, body: nil, additionalHeaders: additionalHeaders)
        return request
    }
    
    //==========================================
    // MARK: - Content
    //==========================================
    
    class func createGetMasechtotRequest() -> URLRequest?{
        guard let baseUrl = URL(string: HttpRequestsFactory.baseUrlLink) else { return nil }
        let link = baseUrl.appendingPathComponent("masechtot_list/").absoluteString
        guard let url = self.createUrl(fromLink: link, urlParams: nil) else { return nil }
        let request = self.createRequest(url, method: .get, body: nil, additionalHeaders: nil)
        return request
    }
    
    class func createGetGemaraLessonRequest(masechetId: Int,page: Int, token: String) -> URLRequest?{
        guard let baseUrl = URL(string: HttpRequestsFactory.baseUrlLink) else { return nil }
        let link = baseUrl.appendingPathComponent("gemara/masechet/\(masechetId)/page/\(page)/").absoluteString
        guard let url = self.createUrl(fromLink: link, urlParams: nil) else { return nil }
        let additionalHeaders: [String:String] = ["Authorization": "token \(token)"]
        let request = self.createRequest(url, method: .get, body: nil, additionalHeaders: additionalHeaders)
        return request
    }
    
    class func createGetGemaraMasechetLessonsRequest(masechetId: Int, token: String) -> URLRequest?{
        guard let baseUrl = URL(string: HttpRequestsFactory.baseUrlLink) else { return nil }
        let link = baseUrl.appendingPathComponent("gemara/masechet/\(masechetId)/").absoluteString
        guard let url = self.createUrl(fromLink: link, urlParams: nil) else { return nil }
        let additionalHeaders: [String:String] = ["Authorization": "token \(token)"]        
        let request = self.createRequest(url, method: .get, body: nil, additionalHeaders: additionalHeaders)
        return request
    }
    
    class func createGetMishnaLessonsRequest(masechetId: Int, chapter:Int, token: String) -> URLRequest?{
        guard let baseUrl = URL(string: HttpRequestsFactory.baseUrlLink) else { return nil }
        let link = baseUrl.appendingPathComponent("mishna/masechet/\(masechetId)/chapter/\(chapter)/").absoluteString
        guard let url = self.createUrl(fromLink: link, urlParams: nil) else { return nil }
        let additionalHeaders: [String:String] = ["Authorization": "token \(token)"]
        let request = self.createRequest(url, method: .get, body: nil, additionalHeaders: additionalHeaders)
        return request
    }
    
    class func createGetMishnaLessonRequest(masechetId: Int, chapter:Int, mishna: Int, token: String) -> URLRequest?{
        guard let baseUrl = URL(string: HttpRequestsFactory.baseUrlLink) else { return nil }
        let link = baseUrl.appendingPathComponent("mishna/masechet/\(masechetId)/chapter/\(chapter)/mishna/\(mishna)").absoluteString
        guard let url = self.createUrl(fromLink: link, urlParams: nil) else { return nil }
        let additionalHeaders: [String:String] = ["Authorization": "token \(token)"]
        let request = self.createRequest(url, method: .get, body: nil, additionalHeaders: additionalHeaders)
        return request
    }
    
    class func createGetDonationData(token: String) -> URLRequest?{
        guard let baseUrl = URL(string: HttpRequestsFactory.baseUrlLink) else { return nil }
        let link = baseUrl.appendingPathComponent("donation_data/v1").absoluteString
        guard let url = self.createUrl(fromLink: link, urlParams: nil) else { return nil }
        let additionalHeaders: [String:String] = ["Authorization": "token \(token)"]
        let request = self.createRequest(url, method: .get, body: nil, additionalHeaders: additionalHeaders)
        return request
    }
    
    class func createGetUserDonation(token: String) -> URLRequest?{
        guard let baseUrl = URL(string: HttpRequestsFactory.baseUrlLink) else { return nil }
        let link = baseUrl.appendingPathComponent("user/donation").absoluteString
        guard let url = self.createUrl(fromLink: link, urlParams: nil) else { return nil }
        let additionalHeaders: [String:String] = ["Authorization": "token \(token)"]
        let request = self.createRequest(url, method: .get, body: nil, additionalHeaders: additionalHeaders)
        return request
    }
    
    class func createGetLessonDonationRequest(lessonId:Int, isGemara:Bool, downloaded: Bool, token: String) -> URLRequest?{
        guard let baseUrl = URL(string: HttpRequestsFactory.baseUrlLink) else { return nil }
        let link = baseUrl.appendingPathComponent("lesson_donations/\(lessonId)").absoluteString
        guard let url = self.createUrl(fromLink: link, urlParams: ["is_gemara":"\(isGemara.intValue)","download":"\(downloaded.intValue)" ]) else { return nil }
        let additionalHeaders: [String:String] = ["Authorization": "token \(token)"]
        
        let request = self.createRequest(url, method: .get, body: nil, additionalHeaders: additionalHeaders)
        return request
    }
    
    class func createDonationLikeRequest(lessonId: Int, isGemara: Bool, crownId: Int, token: String) -> URLRequest?{
        guard let baseUrl = URL(string: HttpRequestsFactory.baseUrlLink) else { return nil }
        let link = baseUrl.appendingPathComponent("like").absoluteString
        let body: [String:Any] = ["lesson_id": lessonId, "is_gemara": isGemara, "crown_id": crownId]
        guard let url = self.createUrl(fromLink: link, urlParams: nil) else { return nil }
        let additionalHeaders: [String:String] = ["Authorization": "token \(token)"]
        
        let request = self.createRequest(url, method: .post, body: body, additionalHeaders: additionalHeaders)
        return request
    }
    
    class func createDonationPaymentRequest(sum: Int, paymentType: Int, nameToRepresent: String, dedicationText: String, status: String, dedicationTemplate:Int, country: String, token: String) -> URLRequest?{
        guard let baseUrl = URL(string: HttpRequestsFactory.baseUrlLink) else { return nil }
        let link = baseUrl.appendingPathComponent("user_payment").absoluteString
        let body: [String:Any] = ["sum": sum, "payment_type": paymentType, "dedication_text": dedicationText, "status": status, "dedication_template": dedicationTemplate, "name_to_represent": nameToRepresent, "country": country]
        guard let url = self.createUrl(fromLink: link, urlParams: nil) else { return nil }
        let additionalHeaders: [String:String] = ["Authorization": "token \(token)"]
        
        let request = self.createRequest(url, method: .post, body: body, additionalHeaders: additionalHeaders)
        return request
    }
    
    class func createCouponRedemptionRequest(coupone: String, nameToRepresent: String, dedicationText: String, dedicationTemplate:Int, commit: Bool, token: String) -> URLRequest?{
        guard let baseUrl = URL(string: HttpRequestsFactory.baseUrlLink) else { return nil }
        let link = baseUrl.appendingPathComponent("coupon").absoluteString
        let body: [String:Any] = ["coupon": coupone, "dedication_text": dedicationText,  "dedication_template": dedicationTemplate, "name_to_represent": nameToRepresent, "commit": commit]
        guard let url = self.createUrl(fromLink: link, urlParams: nil) else { return nil }
        let additionalHeaders: [String:String] = ["Authorization": "token \(token)"]
        
        let request = self.createRequest(url, method: .post, body: body, additionalHeaders: additionalHeaders)
        return request
    }
    
    class func createGetPushNotification(token: String) -> URLRequest?{
        guard let baseUrl = URL(string: HttpRequestsFactory.baseUrlLink) else { return nil }
        let link = baseUrl.appendingPathComponent("send_donation_mail").absoluteString
        guard let url = self.createUrl(fromLink: link, urlParams: nil) else { return nil }
        let additionalHeaders: [String:String] = ["Authorization": "token \(token)"]
        
        let request = self.createRequest(url, method: .post, body: nil, additionalHeaders: additionalHeaders)
        return request
    }
    class func createGetMessageListRequest(token: String) -> URLRequest?{
        guard let baseUrl = URL(string: HttpRequestsFactory.baseUrlLink) else { return nil }
        let link = baseUrl.appendingPathComponent("messages").absoluteString
        guard let url = self.createUrl(fromLink: link, urlParams: nil) else { return nil }
        let additionalHeaders: [String:String] = ["Authorization": "token \(token)"]
        let request = self.createRequest(url, method: .get, body: nil, additionalHeaders: additionalHeaders)
        return request
    }
    
    class func createMessageRequest(message: String, sentAt: Date, title: String, messageType: Int, toUser: Int, chatId: Int?,lessonId:Int?, gemara: Bool?, linkTo: Int?, token: String) -> URLRequest?{
        guard let baseUrl = URL(string: HttpRequestsFactory.baseUrlLink) else { return nil }
        let link = baseUrl.appendingPathComponent("messages").absoluteString
        let body: [String:Any] = ["message": message, "sent_at": sentAt.timeIntervalSince1970 * 1000, "title": title, "message_type": messageType, "to_user": toUser, "chat_id": chatId , "lesson_id": lessonId, "gemara": gemara ?? false, "link_to": linkTo ?? 1]
        guard let url = self.createUrl(fromLink: link, urlParams: nil) else { return nil }
        let additionalHeaders: [String:String] = ["Authorization": "token \(token)"]
        
        let request = self.createRequest(url, method: .post, body: body, additionalHeaders: additionalHeaders)
        return request
    }
    
    //{"event":"watch", "category": "Gemara", "media_type": "video", "page_id":"141" , "duration": 2, "online": 1}
    
    class func createPostAnalyticEventRequest(token: String, event: String, category:String, mediaType: String, pageId: String, duration: Int64?, online: Int?) -> URLRequest?{
        guard let baseUrl = URL(string: HttpRequestsFactory.baseUrlLink) else { return nil }
        let link = baseUrl.appendingPathComponent("user/analytics/").absoluteString
        guard let url = self.createUrl(fromLink: link, urlParams: nil) else { return nil }
        
        var body: [String:Any] = ["event": event, "category": category, "media_type": mediaType, "page_id": pageId]
        if let _duration = duration {
            body["duration"] =  _duration
        }
        if let _online = online {
            body["online"] = _online
        }
        let additionalHeaders: [String:String] = ["Authorization": "token \(token)"]
        let request = self.createRequest(url, method: .post, body: body, additionalHeaders: additionalHeaders)
        return request
    }
    
    
    class func createPostCampaignMailRequest(token: String) -> URLRequest?{
        guard let baseUrl = URL(string: HttpRequestsFactory.baseUrlLink) else { return nil }
        let link = baseUrl.appendingPathComponent("campaign_mail").absoluteString
        guard let url = self.createUrl(fromLink: link, urlParams: nil) else { return nil }
        let additionalHeaders: [String:String] = ["Authorization": "token \(token)"]
        let request = self.createRequest(url, method: .post, body: nil, additionalHeaders: additionalHeaders)
        return request
    }
    
    class func createGetLastVersion(token: String, currentAppVersion: Int) -> URLRequest?{
        guard let baseUrl = URL(string: HttpRequestsFactory.baseUrlLink) else { return nil }
        let link = baseUrl.appendingPathComponent("").absoluteString
        guard let url = self.createUrl(fromLink: link, urlParams: ["device":"ios","app_version":"\(currentAppVersion)"]) else { return nil }
        let additionalHeaders: [String:String] = ["Authorization": "token \(token)"]
        let request = self.createRequest(url, method: .get, body: nil, additionalHeaders: additionalHeaders)
        return request
    }

    class func createGetNewsFeedLatest(token: String) -> URLRequest?{
        guard let baseUrl = URL(string: HttpRequestsFactory.baseUrlLink) else { return nil }
        let link = baseUrl.appendingPathComponent("news_feed/latest/").absoluteString
        guard let url = self.createUrl(fromLink: link, urlParams: nil) else { return nil }
        let additionalHeaders: [String:String] = ["Authorization": "token \(token)"]
        let request = self.createRequest(url, method: .get, body: nil, additionalHeaders: additionalHeaders)
        return request
    }
    
    class func createGetNewsFeedAll(token: String, offSet: String?) -> URLRequest?{
        guard let baseUrl = URL(string: HttpRequestsFactory.baseUrlLink) else { return nil }
        let link = baseUrl.appendingPathComponent("news_feed/").absoluteString
        guard let url = self.createUrl(fromLink: link, urlParams: ["offset": offSet ?? "0"]) else { return nil }
        let additionalHeaders: [String:String] = ["Authorization": "token \(token)"]
        let request = self.createRequest(url, method: .get, body: nil, additionalHeaders: additionalHeaders)
        return request
    }

    
    class func createGetSurveyUserStatus(userID: Int, token: String) -> URLRequest?{
        guard let baseUrl = URL(string: HttpRequestsFactory.baseUrlLink) else { return nil }
        let link = baseUrl.appendingPathComponent("survey_user_status/\(userID)/").absoluteString
        guard let url = self.createUrl(fromLink: link, urlParams: nil) else { return nil }
        let additionalHeaders: [String:String] = ["Authorization": "token \(token)"]
        let request = self.createRequest(url, method: .get, body: nil, additionalHeaders: additionalHeaders)
        return request
    }
    
    class func createPostSurveyUserAnswers(token: String, body: [[String:Any?]]) -> URLRequest?{
        guard let baseUrl = URL(string: HttpRequestsFactory.baseUrlLink) else { return nil }
        let link = baseUrl.appendingPathComponent("survey/user_answer/").absoluteString
        guard let url = self.createUrl(fromLink: link, urlParams: nil) else { return nil }
        var answersBody: [String:Any]
        if body.count == 1 {
            answersBody = ["items": body.first ]
        } else {
            answersBody = ["items": body ]
        }
        let additionalHeaders: [String:String] = ["Authorization": "token \(token)"]
        let request = self.createRequest(url, method: .post, body: answersBody, additionalHeaders: additionalHeaders)
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

        // Add app version header for API versioning (backward compatibility)
        if let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
            request.addValue(version, forHTTPHeaderField: "X-App-Version")
        }
        return request as URLRequest
    }
}
