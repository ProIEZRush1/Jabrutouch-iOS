//בעזרת ה׳ החונן לאדם דעת
//  ServerGenericResponse.swift
//  Jabrutouch
//
//  Created by Yoni Reiss on 30/07/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import Foundation

struct ServerGenericResponse {
    var success: Bool
    var errorCode: Int?
    var errors: String?
    var phone: [String]?
    var data: [String:Any]?
    
    init?(values: [String:Any]) {
        if let success = values["success"] as? Bool {
            self.success = success
        } else { return nil }
        
        self.errorCode = values["error_code"] as? Int
        self.errors = values["error_code"] as? String
        self.phone = values["error_code"] as? [String]
        self.data = values["error_code"] as? [String:Any]
    }
    
}
