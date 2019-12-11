//
//  GetMessagesResponse.swift
//  Jabrutouch
//
//  Created by Shlomo Carmen on 10/12/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import Foundation

struct GetMessagesResponse: APIResponseModel {
    
    var chats: [JTChatMessage]
    
    init?(values: [String : Any]) {
        
        if let chats = values["chats"] as? [[String:Any]] {
            self.chats = chats.compactMap{JTChatMessage(values: $0)}
        } else {
            return nil
        }
    }
}
