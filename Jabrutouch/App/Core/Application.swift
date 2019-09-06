//
//  Application.swift
//  Jabrutouch
//
//  Created by Yoni Reiss on 05/09/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import Foundation

@objc(Application) class Application:UIApplication {
    
    override init() {
        print("AppInit")
        UserDefaultsProvider.shared.appLanguageCode = "es"
        
    }
}
