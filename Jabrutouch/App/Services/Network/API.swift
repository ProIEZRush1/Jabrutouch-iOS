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
    
    class func changePassword(userId: Int, oldPassword: String?, newPassword: String?, token: String, completionHandler:@escaping (_ response: APIResult<ChangePasswordResponse>)->Void) {
        guard let request = HttpRequestsFactory.changePasswordRequest(userId: userId, oldPassword: oldPassword, newPassword: newPassword, token: token) else {
            completionHandler(APIResult.failure(.unableToCreateRequest))
            return
        }
        HttpServiceProvider.shared.excecuteRequest(request: request) { (data, response, error) in
            self.processResult(data: data, response: response, error: error, completionHandler: completionHandler)
        }
    }
    
    class func getEditUserParameters(authToken: String, completionHandler:@escaping (_ response: APIResult<GetEditUserParametersResponse>)->Void) {
        guard let request = HttpRequestsFactory.createGetEditUserParameters( token: authToken) else {
            completionHandler(APIResult.failure(.unableToCreateRequest))
            return
        }
        HttpServiceProvider.shared.excecuteRequest(request: request) { (data, response, error) in
            self.processResult(data: data, response: response, error: error, completionHandler: completionHandler)
        }
    }
    
    class func setUserTour(authToken: String, tourNum: Int, user: Int, viewed: Bool, completionHandler:()) {
    guard let request = HttpRequestsFactory.createSetUserTour(token: authToken, tourNum: tourNum, user: user, viewed: viewed) else {
            completionHandler
            return
        }
        HttpServiceProvider.shared.excecuteRequest(request: request) { (data, response, error) in
            print(request)
        
//            self.processResult(data: data, response: response, error: error, completionHandler: )
        }
    }
    
    class func setUserParameters(authToken: String, user: JTUser, completionHandler:@escaping (_ response: APIResult<LoginResponse>)->Void) {
        guard let request = HttpRequestsFactory.createSetUserRequest(user: user, token: authToken) else {
            completionHandler(APIResult.failure(.unableToCreateRequest))
            return
        }
        HttpServiceProvider.shared.excecuteRequest(request: request) { (data, response, error) in
            self.processResult(data: data, response: response, error: error, completionHandler: completionHandler)
        }
    }
    
    class func removeAccount(authToken: String, userId: Int, completionHandler:@escaping (_ response: APIResult<AccountRemoved> )->Void) {
        guard let request = HttpRequestsFactory.createRemoveAccount(userId: userId, token: authToken) else {
            completionHandler(APIResult.failure(.unableToCreateRequest))
            return
        }
        HttpServiceProvider.shared.excecuteRequest(request: request) { (data, response, error) in
            self.processResult(data: data, response: response, error: error, completionHandler: completionHandler)
        }
    }
    
    class func getPopups(authToken: String, completionHandler:@escaping (_ response: APIResult<JTPopup>)->Void) {
        guard let request = HttpRequestsFactory.createGetPopup( token: authToken) else {
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
    
    class func getMishnaLesson(masechetId:Int, chapter: Int, mishna: Int,  authToken: String, completionHandler:@escaping (_ response: APIResult<GetMishnaLessonResponse>)->Void) {
        guard let request = HttpRequestsFactory.createGetMishnaLessonRequest(masechetId: masechetId, chapter: chapter, mishna: mishna, token: authToken) else {
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
    // MARK: - Donations
    //========================================
    
    class func getDonationsData(authToken: String, completionHandler:@escaping (_ response: APIResult<DonationResponse>)->Void) {
        guard let request = HttpRequestsFactory.createGetDonationData(token: authToken) else {
            completionHandler(APIResult.failure(.unableToCreateRequest))
            return
        }
        HttpServiceProvider.shared.excecuteRequest(request: request) { (data, response, error) in
            self.processResult(data: data, response: response, error: error, completionHandler: completionHandler)
        }
    }
    
    class func getUserDonations(authToken: String, completionHandler:@escaping (_ response: APIResult<UserDonationResponse>)->Void) {
        guard let request = HttpRequestsFactory.createGetUserDonation(token: authToken) else {
            completionHandler(APIResult.failure(.unableToCreateRequest))
            return
        }
        HttpServiceProvider.shared.excecuteRequest(request: request) { (data, response, error) in
            self.processResult(data: data, response: response, error: error, completionHandler: completionHandler)
        }
    }
    
    class func getLessonDonation(lessonId:Int,isGemara:Bool, downloaded: Bool,authToken: String, completionHandler:@escaping (_ response: APIResult<LessonDonationResponse>)->Void) {
        guard let request = HttpRequestsFactory.createGetLessonDonationRequest(lessonId:lessonId, isGemara:isGemara, downloaded: downloaded,token: authToken) else {
            completionHandler(APIResult.failure(.unableToCreateRequest))
            return
        }
        HttpServiceProvider.shared.excecuteRequest(request: request) { (data, response, error) in
            self.processResult(data: data, response: response, error: error, completionHandler: completionHandler)
        }
    }
    
    class func createDonationLikeRequest(lessonId: Int, isGemara: Bool, crownId: Int, authToken: String, completionHandler:@escaping (_ response: APIResult<CreateLikeResponse>)->Void) {
        guard let request = HttpRequestsFactory.createDonationLikeRequest(lessonId: lessonId, isGemara: isGemara, crownId: crownId, token: authToken) else {
            completionHandler(APIResult.failure(.unableToCreateRequest))
            return
        }
        HttpServiceProvider.shared.excecuteRequest(request: request) { (data, response, error) in
            self.processResult(data: data, response: response, error: error, completionHandler: completionHandler)
        }
    }
    
    class func createDonationPayment(sum: Int, paymentType: Int, dedicationText: String, status: String, dedicationTemplate:Int, nameToRepresent: String, country: String, authToken: String, completionHandler:@escaping (_ response: APIResult<CreatePaymentResponse>)->Void) {
        guard let request = HttpRequestsFactory.createDonationPaymentRequest(sum: sum, paymentType: paymentType, nameToRepresent: nameToRepresent, dedicationText: dedicationText, status: status, dedicationTemplate: dedicationTemplate, country: country, token: authToken) else {
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
    
    class func createMessage(message: String, sentAt: Date, title: String, messageType: Int, toUser: Int, chatId: Int?, lessonId:Int?, gemara: Bool?, linkTo: Int?, token: String, completionHandler:@escaping (_ response: APIResult<GetCreateMessageResponse>)->Void) {
        guard let request = HttpRequestsFactory.createMessageRequest(message: message, sentAt: sentAt, title: title, messageType: messageType, toUser: toUser, chatId: chatId, lessonId: lessonId, gemara: gemara, linkTo: linkTo, token: token) else {
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
                    switch fieldError.message {
                    case "Invalid token.":
                        completionHandler(.failure(.invalidToken))
                    default:
                        completionHandler(.failure(.custom(fieldError.message)))
                    }
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
