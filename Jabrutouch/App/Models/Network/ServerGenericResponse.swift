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
    var errors: [ServerFieldError] = []
    var data: [String:Any]?
    
    init?(values: [String:Any]) {
        if let success = values["success"] as? Bool {
            self.success = success
        } else { return nil }
        
        self.errorCode = values["error_code"] as? Int
        
        if let errorsValues = values["errors"] as? [[String:String]] {
            self.errors = errorsValues.compactMap{ServerFieldError(values: $0)}
        }        
        self.data = values["data"] as? [String:Any]
    }
    
}

