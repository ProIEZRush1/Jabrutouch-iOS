//
//  ValidateCodeResponse.swift
//  Jabrutouch
//
//  Created by Yoni Reiss on 29/07/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import Foundation

struct ValidateCodeResponse: APIResponseModel {
    
    var id: Int
    var phoneNumber: String
    
    init?(values: [String:Any]) {
        if let id = values["id"] as? Int {
            self.id = id
        } else { return nil }
        
        if let phoneNumber = values["phone"] as? String {
            self.phoneNumber = phoneNumber
        } else { return nil }
    }
}
