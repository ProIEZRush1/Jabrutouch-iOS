//
//  GetMessagesResponse.swift
//  Jabrutouch
//
//  Created by Shlomo Carmen on 10/12/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import Foundation

struct GetMessagesResponse: APIResponseModel {
    
    var messages: [JTMessage]
    
    init?(values: [String : Any]) {
        
        if let messages = values["messages"] as? [[String:Any]] {
            self.messages = messages.compactMap{JTMessage(values: $0)}
        } else {
            return nil
        }
    }
}
