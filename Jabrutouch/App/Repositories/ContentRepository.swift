//בעזרת ה׳ החונן לאדם דעת
//  ContentRepository.swift
//  Jabrutouch
//
//  Created by Yoni Reiss on 14/08/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import Foundation

class ContentRepository {
    
    //========================================
    // MARK: - Properties
    //========================================
    var shas: [JTSeder] = []
    
    private static var repository: ContentRepository?
    
    class var shared: ContentRepository {
        if self.repository == nil {
            self.repository = ContentRepository()
        }
        return self.repository!
    }
    
    //========================================
    // MARK: - Initializer
    //========================================
    
    private init() {
        self.loadShas()
    }
    
    //========================================
    // MARK: - Loading methods
    //========================================
    
    private func loadShas() {
        API.getMasechtot { (result: APIResult<GetMasechtotResponse>) in
            switch result {
            case .success(let response):
                self.shas = response.shas
                NotificationCenter.default.post(name: .shasLoaded, object: nil, userInfo: nil)
            case .failure(let error):
                let userInfo: [String:Any] = ["errorMessage": error.message]
                NotificationCenter.default.post(name: .failedLoadingShas, object: nil, userInfo: userInfo)
                break
            }
        }
    }
}
