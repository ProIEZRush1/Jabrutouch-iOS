//בעזרת ה׳ החונן לאדם דעת
//  LoginManager.swift
//  Jabrutouch
//
//  Created by Yoni Reiss on 31/07/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import Foundation
import Firebase

class LoginManager {
    
    private static var manager: LoginManager?
    
    private init() {
        
    }
    
    class var shared: LoginManager {
        if self.manager == nil {
            self.manager = LoginManager()
        }
        return self.manager!
    }
    
    //==========================================
    // MARK: - Public methods
    //==========================================
    
    func signIn(phoneNumber: String?, email: String?, password: String, completion:@escaping (_ result: Result<JTUser,JTError>)->Void){
        API.signIn(phoneNumber: phoneNumber, email: email, password: password, fcmToken: UserDefaultsProvider.shared.currentFcmToken ?? "") { (result:APIResult<LoginResponse>) in
            switch result {
            case .success(let response):
                self.userDidSignIn(user: response.user, password: password)
                DispatchQueue.main.async {
                    completion(.success(response.user))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func signOut(completion: ()->Void) {
        self.userDidSignOut()
        completion()
    }
    
    func requestVerificationCode(phoneNumber: String, completion:@escaping (_ result: Result<Any, JTError>)->Void){
        API.requestVerificationCode(phoneNumber: phoneNumber) { (result:APIResult<SendCodeResponse>) in
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    completion(.success(response))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func resendCode(phoneNumber: String, completion:@escaping (_ result: Result<Any, Error>)->Void){
        API.resendCode(phoneNumber: phoneNumber) { (result:APIResult<ResendCodeResponse>) in
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    completion(.success(response))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func validateCode(phoneNumber: String, code:String, completion:@escaping (_ result: Result<Int, Error>)->Void){
        API.validateCode(phoneNumber: phoneNumber, code: code) { (result:APIResult<ValidateCodeResponse>) in
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    completion(.success(response.id))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func signUp(userId: Int, firstName: String, lastName: String, phoneNumber: String, email: String, password: String, completion:@escaping (_ result: Result<JTUser,Error>)->Void){
        API.signUp(userId: userId, firstName: firstName, lastName: lastName, phoneNumber: phoneNumber, email: email, password: password, fcmToken: MessagesRepository.shared.fcmToken) { (result:APIResult<SignUpResponse>) in
            switch result {
            case .success(let response):
                self.userDidSignIn(user: response.user, password: password)
                DispatchQueue.main.async {
                    completion(.success(response.user))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func forgotPassword(email: String, completion:@escaping (_ result: Result<ForgotPasswordResponse,Error>)->Void){
        API.forgotPassword(email: email) { (result:APIResult<ForgotPasswordResponse>) in
            switch result {
            case .success(let response):
                
                DispatchQueue.main.async {
                    completion(.success(response))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func changPassword(userId: Int, oldPassword: String?, newPassword: String?, completion:@escaping (_ result: Result<ChangePasswordResponse,JTError>)->Void){
        guard let authToken = UserDefaultsProvider.shared.currentUser?.token else {
            completion(.failure(.authTokenMissing))
            return
        }
        API.changePassword(userId: userId, oldPassword: oldPassword, newPassword: newPassword, token: authToken) { (result:APIResult<ChangePasswordResponse>) in
            switch result {
            case .success(let response):
                
                DispatchQueue.main.async {
                    completion(.success(response))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getProfileImage(fileName: String, completion: @escaping (_ result: Result<UIImage,Error>)->Void) {
           AWSS3Provider.shared.handleFileDownload(fileName: fileName, bucketName: AWSS3Provider.appS3BucketName, progressBlock: nil) { (result) in
               switch result{
               case .success(let data):
                   if let image = UIImage(data: data) {
                       completion(.success(image))
                   }
                   else {
                   }
                   
               case .failure(let error):
                   completion(.failure(error))
               }
           }
       }
    
    func setCurrentUserDetails(_ user: JTUser, completion:@escaping (_ result: Result<JTUser,JTError>)->Void) {
        guard let authToken = UserDefaultsProvider.shared.currentUser?.token else {
            completion(.failure(.authTokenMissing))
            return
        }
        API.setUserParameters(authToken: authToken, user: user) { (result: APIResult<LoginResponse>) in
            switch result{
                
            case .success(let response):
                self.userDidSetParameters(user: user)
                completion(.success(response.user))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    

    //==========================================
    // MARK: - Private methods
    //==========================================
    
    private func userDidSignUp(user: JTUser, password: String) {
        UserRepository.shared.setCurrentUser(user, password: password)
        Crashlytics.crashlytics().setUserID(String(user.id))
    }
    
    private func userDidSignIn(user: JTUser, password: String) {
        UserRepository.shared.setCurrentUser(user, password: password)
        Crashlytics.crashlytics().setUserID(String(user.id))
                                            
        let _ = DonationManager.shared
        self.getProfileImage(fileName: user.imageLink) { (result: Result<UIImage, Error>) in
            switch result {
            case .success(let image):
                UserRepository.shared.setProfileImage(image: image)
            case .failure(_):
                break
            }
        }
    }
    
    private func userDidSignOut() {
        UserRepository.shared.clearCurrentUser()
    }
    
    private func userDidSetParameters(user: JTUser) {
        UserRepository.shared.updateCurrentUser(user)
    }
}
