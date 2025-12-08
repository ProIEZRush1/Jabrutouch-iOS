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
    
    func signIn(phoneNumber: String?, email: String?, password: String, completion:@escaping (_ result: Result<JTUser,JTError>) -> Void) {
        
        /*guard let fcmToken = UserDefaultsProvider.shared.currentFcmToken else {
            completion(.failure(.custom("We are preparing your device for login. Please wait a few moments and try again.")))
            return
        }*/
        
        let fcmToken = UserDefaultsProvider.shared.currentFcmToken ?? "NOTOKEN"
        API.signIn(phoneNumber: phoneNumber, email: email, password: password, fcmToken: fcmToken) { (result: APIResult<LoginResponse>) in
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
    
    func requestVerificationCode(phoneNumber: String, completion:@escaping (_ result: Result<SendCodeResponse, JTError>)->Void){
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

    //==========================================
    // MARK: - Email Verification Flow
    //==========================================

    func requestEmailVerificationCode(email: String, completion:@escaping (_ result: Result<SendCodeResponse, JTError>)->Void){
        API.requestEmailVerificationCode(email: email) { (result:APIResult<SendCodeResponse>) in
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

    func validateEmailCode(email: String, code: String, completion:@escaping (_ result: Result<Int, Error>)->Void){
        API.validateEmailCode(email: email, code: code) { (result:APIResult<ValidateEmailCodeResponse>) in
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

    func emailSignUp(userId: Int, firstName: String, lastName: String, email: String, phoneNumber: String, password: String, completion:@escaping (_ result: Result<JTUser,Error>)->Void){
        API.emailSignUp(userId: userId, firstName: firstName, lastName: lastName, email: email, phoneNumber: phoneNumber, password: password, fcmToken: MessagesRepository.shared.fcmToken) { (result:APIResult<SignUpResponse>) in
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
                print("📧 Password reset email requested for: \(email)")
                print("   Reset method: \(response.resetMethod ?? "legacy")")
                if let linkSent = response.resetLinkSent {
                    print("   Reset link sent: \(linkSent)")
                }
                DispatchQueue.main.async {
                    completion(.success(response))
                }
            case .failure(let error):
                print("❌ Password reset request failed: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }

    func confirmResetPassword(token: String, newPassword: String, completion:@escaping (_ result: Result<ResetPasswordResponse,JTError>)->Void){
        API.confirmResetPassword(token: token, newPassword: newPassword) { (result:APIResult<ResetPasswordResponse>) in
            switch result {
            case .success(let response):
                print("✅ Password reset confirmed successfully")
                if let email = response.userEmail {
                    print("   User email: \(email)")
                }
                DispatchQueue.main.async {
                    completion(.success(response))
                }
            case .failure(let error):
                print("❌ Password reset confirmation failed: \(error.localizedDescription)")
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
