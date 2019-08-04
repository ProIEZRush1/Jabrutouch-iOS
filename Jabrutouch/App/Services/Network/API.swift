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
        HttpProvider.excecuteRequest(request: request) { (data, response, error) in
            self.processResult(data: data, response: response, error: error, completionHandler: completionHandler)

        }
    }
    
    class func resendCode(phoneNumber: String, completionHandler:@escaping (_ response: APIResult<ResendCodeResponse>)->Void) {
        guard let request = HttpRequestsFactory.createResendCodeRequest(phoneNumber: phoneNumber) else {
            completionHandler(APIResult.failure(.unableToCreateRequest))
            return
        }
        HttpProvider.excecuteRequest(request: request) { (data, response, error) in
            self.processResult(data: data, response: response, error: error, completionHandler: completionHandler)
        }
    }
    
    class func validateCode(phoneNumber: String, code:String, completionHandler:@escaping (_ response: APIResult<ValidateCodeResponse>)->Void) {
        guard let request = HttpRequestsFactory.createValidateCodeRequest(phoneNumber: phoneNumber, code: code) else {
            completionHandler(APIResult.failure(.unableToCreateRequest))
            return
        }
        HttpProvider.excecuteRequest(request: request) { (data, response, error) in
            self.processResult(data: data, response: response, error: error, completionHandler: completionHandler)
        }
    }
    
    class func signIn(phoneNumber: String?, email: String?, password:String, fcmToken: String, completionHandler:@escaping (_ response: APIResult<LoginResponse>)->Void) {
        guard let request = HttpRequestsFactory.createLoginRequest(email: email, phoneNumber: phoneNumber, password: password, fcmToken: fcmToken) else {
            completionHandler(APIResult.failure(.unableToCreateRequest))
            return
        }
        HttpProvider.excecuteRequest(request: request) { (data, response, error) in
            self.processResult(data: data, response: response, error: error, completionHandler: completionHandler)
        }
    }
    
    class func signUp(firstName:String, lastName:String, phoneNumber: String, email: String, password:String, fcmToken: String, completionHandler:@escaping (_ response: APIResult<SignUpResponse>)->Void) {
        guard let request = HttpRequestsFactory.createSignUpRequest(firstName: firstName, lastName: lastName, email: email, phoneNumber: phoneNumber, fcmToken: fcmToken, password: password) else {
            completionHandler(APIResult.failure(.unableToCreateRequest))
            return
        }
        HttpProvider.excecuteRequest(request: request) { (data, response, error) in
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
                completionHandler(.failure(.unknown))
            }
        }
        else {
            completionHandler(.failure(.unknown))
        }
    }
}
