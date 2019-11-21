//בעזרת ה׳ החונן לאדם דעת
//  LoginManager.swift
//  Jabrutouch
//
//  Created by Yoni Reiss on 31/07/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import Foundation

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
        API.signIn(phoneNumber: phoneNumber, email: email, password: password, fcmToken: "1234") { (result:APIResult<LoginResponse>) in
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
        API.signUp(userId: userId, firstName: firstName, lastName: lastName, phoneNumber: phoneNumber, email: email, password: password, fcmToken: "1234") { (result:APIResult<SignUpResponse>) in
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
    // MARK: - Private methods
    //==========================================
    
    private func userDidSignUp(user: JTUser, password: String) {
        UserRepository.shared.setCurrentUser(user, password: password)
    }
    
    private func userDidSignIn(user: JTUser, password: String) {
        UserRepository.shared.setCurrentUser(user, password: password)
    }
    
    private func userDidSignOut() {
        UserRepository.shared.clearCurrentUser()
    }
}
