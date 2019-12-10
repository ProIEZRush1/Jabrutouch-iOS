//בעזרת ה׳ החונן לאדם דעת
//  API.swift
//  Jabrutouch
//
//  Created by Yoni Reiss on 29/07/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import Foundation

class API {
    
    //========================================
    // MARK: - Login Flow
    //========================================
    
    class func requestVerificationCode(phoneNumber: String, completionHandler:@escaping (_ response: APIResult<SendCodeResponse>)->Void) {
        guard let request = HttpRequestsFactory.createSendCodeRequest(phoneNumber: phoneNumber) else {
            completionHandler(APIResult.failure(.unableToCreateRequest))
            return
        }
        HttpServiceProvider.shared.excecuteRequest(request: request) { (data, response, error) in
            self.processResult(data: data, response: response, error: error, completionHandler: completionHandler)

        }
    }
    
    class func resendCode(phoneNumber: String, completionHandler:@escaping (_ response: APIResult<ResendCodeResponse>)->Void) {
        guard let request = HttpRequestsFactory.createResendCodeRequest(phoneNumber: phoneNumber) else {
            completionHandler(APIResult.failure(.unableToCreateRequest))
            return
        }
        HttpServiceProvider.shared.excecuteRequest(request: request) { (data, response, error) in
            self.processResult(data: data, response: response, error: error, completionHandler: completionHandler)
        }
    }
    
    class func validateCode(phoneNumber: String, code:String, completionHandler:@escaping (_ response: APIResult<ValidateCodeResponse>)->Void) {
        guard let request = HttpRequestsFactory.createValidateCodeRequest(phoneNumber: phoneNumber, code: code) else {
            completionHandler(APIResult.failure(.unableToCreateRequest))
            return
        }
        HttpServiceProvider.shared.excecuteRequest(request: request) { (data, response, error) in
            self.processResult(data: data, response: response, error: error, completionHandler: completionHandler)
        }
    }
    
    class func signIn(phoneNumber: String?, email: String?, password:String, fcmToken: String, completionHandler:@escaping (_ response: APIResult<LoginResponse>)->Void) {
        guard let request = HttpRequestsFactory.createLoginRequest(email: email, phoneNumber: phoneNumber, password: password, fcmToken: fcmToken) else {
            completionHandler(APIResult.failure(.unableToCreateRequest))
            return
        }
        HttpServiceProvider.shared.excecuteRequest(request: request) { (data, response, error) in
            self.processResult(data: data, response: response, error: error, completionHandler: completionHandler)
        }
    }
    
    class func signUp(userId: Int, firstName:String, lastName:String, phoneNumber: String, email: String, password:String, fcmToken: String, completionHandler:@escaping (_ response: APIResult<SignUpResponse>)->Void) {
        guard let request = HttpRequestsFactory.createSignUpRequest(userId: userId, firstName: firstName, lastName: lastName, email: email, phoneNumber: phoneNumber, fcmToken: fcmToken, password: password) else {
            completionHandler(APIResult.failure(.unableToCreateRequest))
            return
        }
        HttpServiceProvider.shared.excecuteRequest(request: request) { (data, response, error) in
            self.processResult(data: data, response: response, error: error, completionHandler: completionHandler)
        }
    }
    
    class func forgotPassword(email: String?, completionHandler:@escaping (_ response: APIResult<ForgotPasswordResponse>)->Void) {
        guard let request = HttpRequestsFactory.forgotPasswordRequest(email: email) else {
            completionHandler(APIResult.failure(.unableToCreateRequest))
            return
        }
        HttpServiceProvider.shared.excecuteRequest(request: request) { (data, response, error) in
            self.processResult(data: data, response: response, error: error, completionHandler: completionHandler)
        }
    }
    
    //========================================
    // MARK: - Content
    //========================================
    
    class func getMasechtot(completionHandler:@escaping (_ response: APIResult<GetMasechtotResponse>)->Void) {
        guard let request = HttpRequestsFactory.createGetMasechtotRequest() else {
            completionHandler(APIResult.failure(.unableToCreateRequest))
            return
        }
        HttpServiceProvider.shared.excecuteRequest(request: request) { (data, response, error) in
            self.processResult(data: data, response: response, error: error, completionHandler: completionHandler)
        }
    }
    
    class func getGemarahLesson(masechetId:Int, page: Int, authToken: String, completionHandler:@escaping (_ response: APIResult<GetGemaraLessonResponse>)->Void) {
        guard let request = HttpRequestsFactory.createGetGemaraLessonRequest(masechetId: masechetId, page: page, token: authToken) else {
            completionHandler(APIResult.failure(.unableToCreateRequest))
            return
        }
        HttpServiceProvider.shared.excecuteRequest(request: request) { (data, response, error) in
            self.processResult(data: data, response: response, error: error, completionHandler: completionHandler)
        }
    }
    
    class func getGemarahMasechetLessons(masechetId:Int, authToken: String, completionHandler:@escaping (_ response: APIResult<GetGemaraLessonsResponse>)->Void) {
        guard let request = HttpRequestsFactory.createGetGemaraMasechetLessonsRequest(masechetId: masechetId, token: authToken) else {
            completionHandler(APIResult.failure(.unableToCreateRequest))
            return
        }
        HttpServiceProvider.shared.excecuteRequest(request: request) { (data, response, error) in
            self.processResult(data: data, response: response, error: error, completionHandler: completionHandler)
        }
    }
    
    class func getMishnaLessons(masechetId:Int, chapter: Int, authToken: String, completionHandler:@escaping (_ response: APIResult<GetMishnaLessonsResponse>)->Void) {
        guard let request = HttpRequestsFactory.createGetMishnaLessonsRequest(masechetId: masechetId, chapter: chapter, token: authToken) else {
            completionHandler(APIResult.failure(.unableToCreateRequest))
            return
        }
        HttpServiceProvider.shared.excecuteRequest(request: request) { (data, response, error) in
            self.processResult(data: data, response: response, error: error, completionHandler: completionHandler)
        }
    }
    
    //========================================
    // MARK: - Messages
    //========================================
    
    class func getMessages(authToken: String, completionHandler:@escaping (_ response: APIResult<GetMessagesResponse>)->Void) {
        guard let request = HttpRequestsFactory.createGetMessageListRequest(token: authToken) else {
            completionHandler(APIResult.failure(.unableToCreateRequest))
            return
        }
        HttpServiceProvider.shared.excecuteRequest(request: request) { (data, response, error) in
            self.processResult(data: data, response: response, error: error, completionHandler: completionHandler)
        }
    }
    
    class func gcreateMessages(subject: String, image: String, text: String, read: Bool, chatTipe: Int, parentId: Int, fromUser: Int, toUser: Int, authToken: String, completionHandler:@escaping (_ response: APIResult<GetMessagesResponse>)->Void) {
           guard let request = HttpRequestsFactory.createMessageRequest(subject: subject, image: image, text: text, read: read, chatTipe: chatTipe, parentId: parentId, fromUser: fromUser, toUser: toUser, token: authToken) else {
               completionHandler(APIResult.failure(.unableToCreateRequest))
               return
           }
           HttpServiceProvider.shared.excecuteRequest(request: request) { (data, response, error) in
               self.processResult(data: data, response: response, error: error, completionHandler: completionHandler)
           }
       }
    
    
    //========================================
    // MARK: - Analytics
    //========================================
    
    class func postAnalyticsEvent(token: String, eventType: String, category: String, mediaType: String, lessonId: String, duration:Int64?, online: Int?, completionHandler:@escaping (_ response: APIResult<PostAnalyticsEventResponse>)->Void) {
        guard let request = HttpRequestsFactory.createPostAnalyticEventRequest(token: token, event: eventType, category: category, mediaType: mediaType, pageId: lessonId, duration: duration, online: online) else {
            completionHandler(APIResult.failure(.unableToCreateRequest))
            return
        }
        HttpServiceProvider.shared.excecuteRequest(request: request) { (data, response, error) in
            self.processResult(data: data, response: response, error: error, completionHandler: completionHandler)
        }
    }
    
    //========================================
    // MARK: - Response Processing
    //========================================
    
    private class func processResult<T: APIResponseModel>(data: Data?, response: URLResponse?, error: Error?, completionHandler:@escaping (_ response: APIResult<T>)->Void) {
        if let _error = error {
            completionHandler(APIResult.failure(.serverError(_error)))
        }
        else if let _data = data {
            
            guard let values = Utils.convertDataToDictionary(_data) else {
                completionHandler(APIResult.failure(.unableToParseResponse))
                return
            }
            guard let serverResponse = ServerGenericResponse(values: values) else {
                completionHandler(APIResult.failure(.unableToParseResponse))
                return
            }
            if serverResponse.success {
                if let values = serverResponse.data {
                    if let apiResponse = T(values: values) {
                        completionHandler(.success(apiResponse))
                    }
                    else {
                        completionHandler(APIResult.failure(.unableToParseResponse))
                    }
                }
                else {
                    completionHandler(APIResult.failure(.unableToParseResponse))
                }
            }
            else {
                // TODO - implement specific error evaluation
                if serverResponse.errors.count > 0 {
                    let fieldError = serverResponse.errors[0]
                    completionHandler(.failure(.custom(fieldError.message)))
                }
                else {
                    completionHandler(.failure(.unknown))
                }
                
            }
        }
        else {
            completionHandler(.failure(.unknown))
        }
    }
}
