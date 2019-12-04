//
//  ForgotPasswordResponse.swift
//  Jabrutouch
//
//  Created by Shlomo Carmen on 03/12/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import Foundation

struct ForgotPasswordResponse: APIResponseModel {
    
    let message: String
    
    init?(values: [String : Any]) {
        if let message = values["message"] as? String {
            self.message = message
        } else { return nil }
    }
}
