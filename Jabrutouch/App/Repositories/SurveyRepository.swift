//
//  SurveyRepository.swift
//  Jabrutouch
//
//  Created by Avraham Kirsch on 31/10/2021.
//  Copyright © 2021 Ravtech. All rights reserved.
//

import Foundation

class SurveyRepository{
    
    //========================================
    // MARK: - Properties
    //========================================
    

    private static var repository: SurveyRepository?
    
    class var shared: SurveyRepository {
        if self.repository == nil {
            self.repository = SurveyRepository()
        }
        return self.repository!
    }
    
    //========================================
    // MARK: - Initializer
    //========================================
    
    private init() {
    }

    func getSurveyUserStatus(completionHandler: @escaping(_ response: GetSurveyUserStatusResponse )->Void ){

        guard let authToken = UserDefaultsProvider.shared.currentUser?.token else { return }
        guard let user_id = UserDefaultsProvider.shared.currentUser?.id else { return }
        
        API.getSurveyUserStatus(userID: user_id, authToken: authToken) { (result) in
            
            switch result {
            case .success(let response):
                completionHandler(response)
            case .failure(let error):
                print("survey get user status error", error)
            }
        }

    }
    

    func postSurveyUserAnswers(answers: [[String:Any?]] ,completionHandler: @escaping(_ response: PostSurveyUserAnswersResponse )->Void ){

        guard let authToken = UserDefaultsProvider.shared.currentUser?.token else { return }
        
        API.postSurveyUserAnswers(authToken: authToken, body: answers) { (result) in
            
            switch result {
            case .success(let response):
                completionHandler(response)
            case .failure(let error):
                print("******** postSurveyUserAnswers() error", error)
            }
        }

    }
}
