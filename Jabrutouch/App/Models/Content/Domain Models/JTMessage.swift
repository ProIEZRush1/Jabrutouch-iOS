//
//  JTMessage.swift
//  Jabrutouch
//
//  Created by Shlomo Carmen on 10/12/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import Foundation

class JTMessage {
    
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
    var image: String
    var currentTime: Float = 0
    var duration: Float = 0
    var isPlay: Bool = false
    var linkTo: Int
    var lessonId: Int?
    var gemara: Bool
   
    init?(values: [String:Any]) {
        if let messageId = values["message_id"] as? Int {
            self.messageId = messageId
        } else {  self.messageId = -1 }
        
        if let sentDate = values["sent_at"] as? TimeInterval {
            let date = Date(timeIntervalSince1970: sentDate/1000)
            self.sentDate = date
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
        
        if let image = values["image"] as? String {
            self.image = image
        } else { self.image = "" }
        
        if let linkTo = values["link_to"] as? Int{
            self.linkTo = linkTo
        } else { self.linkTo = 0 }
        
        if let lessonId = values["lesson_id"] as? Int{
                   self.lessonId = lessonId
        } else { self.lessonId = nil }
        
        if let gemara = values["gemara"] as? Bool{
                   self.gemara = gemara
               } else { self.gemara = false }
    }
    
    
    init?(values: NSManagedObject) {
        
        if let chatId = values.value(forKey: "chatId") as? Int {
            self.chatId = chatId
        } else { return nil }
        
        if let sentDate = values.value(forKey: "sendAtDate") as? Date {
            self.sentDate = sentDate
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
        
        if let messageType = values.value(forKey: "messageType") as? Int {
            self.messageType = messageType
        } else { return nil }
        
        if let message = values.value(forKey: "message")  as? String {
            self.message = message
        } else { return nil }
        
        if let messageId = values.value(forKey: "messageId") as? Int {
            self.messageId = messageId
        } else { return nil }
        
        if let image = values.value(forKey: "userImage") as? String {
            self.image = image
        } else { return nil }
        
        if let read = values.value(forKey: "read") as? Bool {
            self.read = read
        } else { return nil }
        
        if let isMine = values.value(forKey: "isMine") as? Bool {
            self.isMine = isMine
        } else { return nil }
        
        if let linkTo = values.value(forKey: "linkTo") as? Int {
            self.linkTo = linkTo
        } else { self.linkTo = 0 }

        if let lessonId = values.value(forKey: "lessonId") as? Int {
            self.lessonId = lessonId
        } else { self.lessonId = nil }
        
        if let gemara = values.value(forKey: "gemara") as? Bool {
            self.gemara = gemara
        } else { self.gemara = false }
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
        values["image"] = self.image
        values["link_to"] = self.linkTo
        values["lesson_id"] = self.lessonId
        values["gemara"] = self.gemara
        
        return values
    }
    
}
