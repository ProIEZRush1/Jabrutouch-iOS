//
//  JTChatMessage.swift
//  Jabrutouch
//
//  Created by Shlomo Carmen on 11/12/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import Foundation


struct JTChatMessage {
    
    var chatId: Int
    var createdDate: Date
    var title: String
    var fromUser: Int
    var toUser: Int
    var chatType : Int
    var lastMessage: String
    var lastMessageTime: Date
    var messages: [JTMessage]
   
    init?(values: [String:Any]) {
       
        if let chatId = values["chat_id"] as? Int {
            self.chatId = chatId
        } else { return nil }
                
        if let createdDate = values["created_at"] as? Date {
            self.createdDate = createdDate
        } else { return nil }
        
        if let title = values["title"] as? String {
            self.title = title
        } else { return nil }
              
        if let fromUser = values["from_user"] as? Int {
            self.fromUser = fromUser
        } else { return nil }
        
        if let toUser = values["to_user"] as? Int {
            self.toUser = toUser
        } else { return nil }
        
        if let chatType = values["chat_type"] as? Int {
            self.chatType = chatType
        } else { return nil }
        
        if let lastMessage = values["last_message"] as? String {
            self.lastMessage = lastMessage
        } else { return nil }
        
        if let lastMessageTime = values["last_message_time"] as? Date {
            self.lastMessageTime = lastMessageTime
        } else { return nil }
        
        if let messagesValues = values["messages"] as? [[String: Any]] {
            self.messages = messagesValues.compactMap{JTMessage(values: $0)}
        } else { return nil }
        
    }
    
    var values: [String:Any] {
        var values: [String:Any] = [:]
        
        values["chat_id"] = self.chatId
        values["created_at"] = self.createdDate
        values["title"] = self.title
        values["from_user"] = self.fromUser
        values["to_user"] = self.toUser
        values["chat_type"] = self.chatType
        values["last_message"] = self.lastMessage
        values["last_message_time"] = self.lastMessageTime
        values["messages"] = self.messages.map{$0.values}
        
        return values
    }

}
