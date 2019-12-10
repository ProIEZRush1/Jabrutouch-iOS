//
//  JTMessage.swift
//  Jabrutouch
//
//  Created by Shlomo Carmen on 10/12/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import Foundation

struct JTMessage {
    
    var id: Int
    var created: Date
    var updated: Date
    var subject: String
    var imageLink: String
    var text: String
    var read: Bool
    var chatType : Int
    var parentId : Int
    var fromUser : Int
    var toUser : Int
    
    init?(values: [String:Any]) {
        if let id = values["id"] as? Int {
            self.id = id
        } else { return nil }
        
        if let created = values["created"] as? Date {
            self.created = created
        } else { return nil }
        
        if let updated = values["updated"] as? Date {
            self.updated = updated
        } else { return nil }
        
        if let subject = values["subject"] as? String {
            self.subject = subject
        } else { return nil }
        
        if let image = values["image"] as? String {
            self.imageLink = image
        } else { return nil }
        
        if let text = values["text"] as? String {
            self.text = text
        } else { return nil }
        
        if let read = values["read"] as? Bool {
            self.read = read
        } else { return nil }
        
        if let chatType = values["chat_type"] as? Int {
            self.chatType = chatType
        } else { return nil }
        
        if let parentId = values["parent_id"] as? Int {
            self.parentId = parentId
        } else { return nil }
        
        if let fromUser = values["from_user"] as? Int {
            self.fromUser = fromUser
        } else { return nil }
        
        if let toUser = values["to_user"] as? Int {
            self.toUser = toUser
        } else { return nil }
        
    }
    
    var values: [String:Any] {
        var values: [String:Any] = [:]
        values["id"] = self.id
        values["created"] = self.created
        values["updated"] = self.updated
        values["subject"] = self.subject
        values["imageLink"] = self.imageLink
        values["text"] = self.text
        values["read"] = self.read
        values["chat_type"] = self.chatType
        values["parent_id"] = self.parentId
        values["from_user"] = self.fromUser
        values["to_user"] = self.toUser
        
        return values
    }

}
