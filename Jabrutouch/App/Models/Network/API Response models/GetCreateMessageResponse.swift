//
//  GetCreateMessageResponse.swift
//  Jabrutouch
//
//  Created by Shlomo Carmen on 11/12/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import Foundation

struct GetCreateMessageResponse: APIResponseModel {
    
    var chat: JTChatMessage
    
    init?(values: [String : Any]) {
        
        if let chat = JTChatMessage(values: values) {
            self.chat = chat
        } else {
            return nil
        }
    }
    
}
