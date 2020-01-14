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
    var image: String = ""
    var read: Bool = false
    var messages: [JTMessage] = []
    var unreadMessages: Int?
   
    init(chatId: Int, createdDate: Date, title: String, fromUser: Int, toUser: Int, chatType: Int, lastMessage: String, lastMessageTime: Date, image: String, read: Bool, unreadMessages: Int) {
        self.chatId = chatId
        self.createdDate = createdDate
        self.title = title
        self.fromUser = fromUser
        self.toUser = toUser
        self.chatType = chatType
        self.lastMessage = lastMessage
        self.lastMessageTime = lastMessageTime
        self.image = image
        self.read = read
        self.unreadMessages = unreadMessages
        
    }
    
    init?(values: [String:Any]) {
       
        if let chatId = values["chat_id"] as? Int {
            self.chatId = chatId
        } else { return nil }
                
        if let createdDate = values["created_at"] as? TimeInterval {
            let date = Date(timeIntervalSince1970: createdDate/1000)
            self.createdDate = date
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
        
        if let lastMessageTime = values["last_message_time"] as? TimeInterval {
            let date = Date(timeIntervalSince1970: lastMessageTime/1000)
            self.lastMessageTime = date
        } else { return nil }
        
        if let image = values["image"] as? String {
            self.image = image
        } else {
            self.image = ""
        }
        
        if let read = values["read"] as? Bool {
            self.read = read
        } else {
            self.read = false
        }
        
        if let messagesValues = values["messages"] as? [[String: Any]] {
            self.messages = messagesValues.compactMap{JTMessage(values: $0)}
        } else { return nil }
       
        if let unreadMessages = values["unreadMessages"] as? Int {
            self.unreadMessages = unreadMessages
        } else {
            self.unreadMessages = 0
        }
    }
    
    init?(values: NSManagedObject) {
          
        if let chatId = values.value(forKey: "chatId") as? Int {
               self.chatId = chatId
           } else { return nil }
                   
        if let createdDate = values.value(forKey: "creatAtDate") as? Date {
               self.createdDate = createdDate
           } else { return nil }
           
        if let title = values.value(forKey: "title") as? String {
               self.title = title
           } else { return nil }
                 
        if let fromUser = values.value(forKey: "fromUser") as? Int {
               self.fromUser = fromUser
           } else { return nil }
           
        if let toUser = values.value(forKey: "toUser") as? Int {
               self.toUser = toUser
           } else { return nil }
           
        if let chatType = values.value(forKey: "chatType") as? Int {
               self.chatType = chatType
           } else { return nil }
           
        if let lastMessage = values.value(forKey: "lastMessage")  as? String {
               self.lastMessage = lastMessage
           } else { return nil }
           
        if let lastMessageTime = values.value(forKey: "lastMessageTime") as? Date {
               self.lastMessageTime = lastMessageTime
           } else { return nil }
           
        if let image = values.value(forKey: "userImage") as? String {
               self.image = image
           } else { return nil }
           
        if let read = values.value(forKey: "read") as? Bool {
               self.read = read
           } else { return nil }
           
        if let unreadMessages = values.value(forKey: "read") as? Int {
            self.unreadMessages = unreadMessages
        } else {
            self.unreadMessages = 0
        }
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
        values["image"] = self.image
        values["messages"] = self.messages.map{$0.values}
        values["read"] = self.read
        values["unreadMessages"] = self.unreadMessages
        
        return values
    }

}
