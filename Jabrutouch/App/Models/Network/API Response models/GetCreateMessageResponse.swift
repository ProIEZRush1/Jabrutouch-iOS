//
//  GetCreateMessageResponse.swift
//  Jabrutouch
//
//  Created by Shlomo Carmen on 11/12/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import Foundation

struct GetCreateMessageResponse: APIResponseModel {
    
    var message: JTMessage
    
    init?(values: [String : Any]) {
        
        if let message = JTMessage(values: values) {
            self.message = message
        } else {
            return nil
        }
    }
    
}
