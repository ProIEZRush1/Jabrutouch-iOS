//בעזרת ה׳ החונן לאדם דעת
//  ServerFieldError.swift
//  Jabrutouch
//
//  Created by Yoni Reiss on 14/08/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import Foundation

struct ServerFieldError {
    var field: String
    var message: String
    
    init?(values: [String: String]) {
        if let field = values["field"] {
            self.field = field
        } else { return nil }
        
        if let message = values["message"] {
            self.message = message
        } else { return nil }
    }
}
