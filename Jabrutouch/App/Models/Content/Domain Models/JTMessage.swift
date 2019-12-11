//
//  JTMessage.swift
//  Jabrutouch
//
//  Created by Shlomo Carmen on 10/12/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import Foundation

struct JTMessage {
    
    var messageId: Int
    var sentDate: Date
    var message: String
    var read: Bool
    var title: String
    var messageType : Int
    var fromUser: Int
    var toUser: Int
    var chatId: Int
    var isMine: Bool
   
    init?(values: [String:Any]) {
        if let messageId = values["message_id"] as? Int {
            self.messageId = messageId
        } else { return nil }
        
        if let sentDate = values["sent_at"] as? Date {
            self.sentDate = sentDate
        } else { return nil }
        
        if let message = values["message"] as? String {
            self.message = message
        } else { return nil }
        
        if let read = values["read"] as? Bool {
            self.read = read
        } else { return nil }
        
        if let title = values["title"] as? String {
            self.title = title
        } else { return nil }
        
        if let messageType = values["message_type"] as? Int {
            self.messageType = messageType
        } else { return nil }
        
        if let fromUser = values["from_user"] as? Int {
            self.fromUser = fromUser
        } else { return nil }
        
        if let toUser = values["to_user"] as? Int {
            self.toUser = toUser
        } else { return nil }
        
        if let chatId = values["chat_id"] as? Int {
            self.chatId = chatId
        } else { return nil }
        
        if let isMine = values["is_mine"] as? Bool {
            self.isMine = isMine
        } else { return nil }
        
    }
    
    var values: [String:Any] {
        var values: [String:Any] = [:]
        values["message_id"] = self.messageId
        values["sent_at"] = self.sentDate
        values["message"] = self.message
        values["read"] = self.read
        values["title"] = self.title
        values["message_type"] = self.messageType
        values["from_user"] = self.fromUser
        values["to_user"] = self.toUser
        values["chat_id"] = self.chatId
        values["is_mine"] = self.isMine
        
        return values
    }

}
