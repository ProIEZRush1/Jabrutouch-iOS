//
//  ChatMessage.swift
//  Jabrutouch
//
//  Created by Shlomo Carmen on 11/12/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import Foundation

let lastMessageTableName = "LastMessageAllRecipient"
let contactGroupListTableName = "GroupList"
let contactGroupMessageInfo = "MessageInfo"
let contactOpportunityListTableName = "OpprtunityList"
let messagesIdListTableName = "MessageIdList"

struct InsertGroupListStatement {
    var insartGroupListTableStatement = ""
    var insertStatement: String {
        return "INSERT INTO ContactChatMessage\(insartGroupListTableStatement) (GroupTableId, Name, Description, isKickedOff) VALUES (?, ?, ?, ?);"
    }
}

struct InsertGroupMessageInfo {
    var insertGroupMessageInfo = ""
    var insertStatement: String {
        return "INSERT INTO ContactChatMessage\(insertGroupMessageInfo) (GroupTableId, MessageId, UserId, ReceivedDate, ReadDate) VALUES (?, ?, ?, ?, ?);"
    }
}

struct InsertOpportunityListStatement {
    var insartOpportunityListTableStatement = ""
    var insertStatement: String {
        return "INSERT INTO ContactChatMessage\(insartOpportunityListTableStatement) (GroupTableId, Name, Description, created, manegerId)  VALUES  (?, ?, ?, ?, ?);"
    }
}

struct InsertLastMessageStatement {
    var insartContactTableStatement = ""
    var insertStatement: String {
        return "INSERT INTO ContactChatMessage\(insartContactTableStatement) (TableId, MessageId, UserName ,UserImage, Massage, MUserId, SendAtDate, MessageType, ChatType, FileLink, GroupName, MessageSent, MessageReceived, MessageRead, Status)  VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);"
    }
}

struct InsertMessageId {
    var insertStatement: String {
        return "INSERT INTO MessageIdList ( messageId, created)  VALUES (?, ?);"
    }
}

struct InsertStatement {
    var insartContactTableStatement = ""
     var insertStatement: String {
        return "INSERT INTO ContactChatMessage\(insartContactTableStatement) (MessageId, UserName ,UserImage, Massage, MUserId, SendAtDate, MessageType, ChatType, FileLink, GroupName, MessageSent, MessageReceived, MessageRead, Status)  VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);"
    }
}

struct QueryStatement {
    var queryContactTableStatement = ""
    var queryStatement: String {
        return "SELECT * FROM ContactChatMessage\(queryContactTableStatement);"
    }
}

protocol SQLTable {
    static var createStatement: String { get }
}

struct ContactGroupList :SQLTable{
    
    static var creatContactGroupListTableStatement = ""
    
    static var createStatement: String {
        return """
        CREATE TABLE ContactChatMessage\(creatContactGroupListTableStatement)
        (
        groupTableId CHAR(100) NOT NULL UNIQUE,
        name CHAR(100) NOT NULL,
        description CHAR(100) NOT NULL,
        isKickedOff INT
        );
        """
    }
    
    let GroupTableId: NSString
    let name: NSString
    let description: NSString
    let isKickedOff: Int32

}

/**
 *   # message sent -> received -> read modul Shlomo
 *    creating table with all the dates of message received and read for a group chat
 **/
struct GroupMessageInfo :SQLTable{
    
    static var creatGroupMessageInfoTableStatement = ""
    
    static var createStatement: String {
        return """
        CREATE TABLE ContactChatMessage\(creatGroupMessageInfoTableStatement)
        (
        groupTableId CHAR(100) NOT NULL UNIQUE,
        messageId CHAR(100) NOT NULL,
        userId CHAR(100) NOT NULL,
        receivedDate CARE(100),
        readDate CARE(100)
        );
        """
    }
    
    let GroupTableId: NSString
    let messageId: NSString
    let userId: NSString
    let receivedDate: NSString
    let readDate: NSString
    
}
/* END */

struct ContactOpportunityList :SQLTable{
    
    static var creatContactOpportunityListTableStatement = ""
    
    static var createStatement: String {
        return """
        CREATE TABLE ContactChatMessage\(creatContactOpportunityListTableStatement)
        (
        groupTableId CHAR(100) NOT NULL UNIQUE,
        name CHAR(100) NOT NULL,
        description CHAR(100) NOT NULL,
        created CHAR(20),
        manegerId INT
        );
        """
    }
    
    let GroupTableId: NSString
    let name: NSString
    let description: NSString
    let created: NSString
    let manegerId: Int32

}

struct ContactChatMessage :SQLTable{
   
    static var creatContactTableStatement = ""
    
    static var createStatement: String {
        return """
        CREATE TABLE ContactChatMessage\(creatContactTableStatement)
        (MessageId CHAR(100) NOT NULL UNIQUE,
        UserName CHAR(100) NOT NULL,
        UserImage CHAR(100) NOT NULL,
        Massage CHAR(255) NOT NULL,
        MUserId INT,
        SendAtDate CHAR(55) NOT NULL,
        MessageType INT,
        ChatType INT,
        FileLink INT,
        GroupName CHAR(100) NOT NULL,
        MessageSent CHAR(55),
        MessageReceived CHAR(55),
        MessageRead CHAR(55),
        Status INT
        );
        """
    }
    
    let messageId: NSString
    let userName: NSString
    let userImage: NSString
    let massage: NSString
    let mUserId: Int32
    let sendAtDate: NSString
    let messageType: Int32
    let chatType: Int32
    let fileLink: NSString
    let groupName: NSString
    let messageSent: NSString
    let messageReceived: NSString
    let messageRead: NSString
    let status: Int32
    
    init(messageId: NSString, userName: NSString, userImage: NSString, massage: NSString ,mUserId: Int32, sendAtDate: NSString, messageType: Int32, chatType: Int32, fileLink: NSString, groupName: NSString, messageSent: NSString, messageReceived: NSString,  messageRead: NSString, status: Int32) {
        self.messageId = messageId
        self.userName = userName
        self.userImage = userImage
        self.massage = massage
        self.mUserId = mUserId
        self.sendAtDate = sendAtDate
        self.messageType = messageType
        self.chatType = chatType
        self.fileLink = fileLink
        self.groupName = groupName
        self.messageSent = messageSent
        self.messageReceived = messageReceived
        self.messageRead = messageRead
        self.status = status
        
    }
    
//    init(messageObject: MessageObject, hasGroupName: Bool){
//        self.messageId = messageObject.messageId! as NSString
//        self.userName = messageObject.userName! as NSString
//        self.userImage = messageObject.userImage! as NSString
//        self.massage = (messageObject.message ?? "") as NSString
//        self.mUserId = Int32(messageObject.mUserId!)
//        self.sendAtDate = messageObject.sentAtDate! as NSString
//        self.messageType = Int32(messageObject.messageType!)
//        self.chatType = Int32(messageObject.chatType!)
//        self.fileLink = (messageObject.fileLink ?? "") as NSString
//
//        self.messageSent = messageObject.messageSent! as NSString
//        self.messageReceived = messageObject.messageReceived! as NSString
//        self.messageRead = messageObject.messageRead! as NSString
//        self.status = Int32(messageObject.status!)
//
//
//        if hasGroupName {
//            self.groupName = messageObject.groupName! as NSString
//        } else {
//            self.groupName = ""
//        }
//    }

}

struct ContactLastChatMessage :SQLTable{
    
    static var creatContactLastChatMessageTableStatement = ""
    
    static var createStatement: String {
        return """
        CREATE TABLE ContactChatMessage\(creatContactLastChatMessageTableStatement)
        (
        TableId CHAR(100) NOT NULL UNIQUE,
        MessageId CHAR(100) NOT NULL UNIQUE,
        UserName CHAR(100) NOT NULL,
        UserImage CHAR(100) NOT NULL,
        Massage CHAR(255) NOT NULL,
        MUserId INT,
        SendAtDate CHAR(55) NOT NULL,
        MessageType INT,
        ChatType INT,
        FileLink INT,
        GroupName CHAR(100) NOT NULL,
        MessageRead CHAR(55),
        MessageSent CHAR(55),
        MessageReceived CHAR(55),
        Status INT
        );
        """
    }
    let tableId: NSString
    let messageId: NSString
    let userName: NSString
    let userImage: NSString
    let massage: NSString
    let mUserId: Int32
    let sendAtDate: NSString
    let messageType: Int32
    let chatType: Int32
    let fileLink: NSString
    let groupName: NSString
    let messageRead: NSString
    let messageSent: NSString
    let messageReceived: NSString
    let status: Int32
    
    init(tableId: NSString, messageId: NSString, userName: NSString, userImage: NSString, massage: NSString ,mUserId: Int32, sendAtDate: NSString, messageType: Int32, chatType: Int32, fileLink: NSString, groupName: NSString, messageSent: NSString, messageReceived: NSString, messageRead: NSString, status: Int32) {
        
        self.tableId = tableId
        self.messageId = messageId
        self.userName = userName
        self.userImage = userImage
        self.massage = massage
        self.mUserId = mUserId
        self.sendAtDate = sendAtDate
        self.messageType = messageType
        self.chatType = chatType
        self.fileLink = fileLink
        self.groupName = groupName
        self.messageSent = messageSent
        self.messageReceived = messageReceived
        self.messageRead = messageRead
        self.status = status
    }
    
//    init(tableId: NSString, messageObject: MessageObject, hasGroupName: Bool){
//        
//        self.tableId = tableId
//        self.messageId = messageObject.messageId! as NSString
//        self.userName = messageObject.userName! as NSString
//        self.userImage = messageObject.userImage! as NSString
//        self.massage = (messageObject.message ?? "") as NSString
//        self.mUserId = Int32(messageObject.mUserId!)
//        self.sendAtDate = messageObject.sentAtDate! as NSString
//        self.messageType = Int32(messageObject.messageType!)
//        self.chatType = Int32(messageObject.chatType!)
//        self.fileLink = (messageObject.fileLink ?? "") as NSString
//        
//        self.messageSent = messageObject.messageSent! as NSString
//        self.messageReceived = messageObject.messageReceived! as NSString
//        self.messageRead = messageObject.messageRead! as NSString
//        self.status = Int32(messageObject.status!)
//        
//        
//        if hasGroupName {
//            self.groupName = messageObject.groupName! as NSString
//        } else {
//            self.groupName = ""
//        }
//    }
}

struct MessageIdList :SQLTable{
    
    static var createStatement: String {
        return """
        CREATE TABLE MessageIdList
        (
        messageId CHAR(100) NOT NULL UNIQUE,
        created INTEGER NOT NULL
        );
        """
    }
    
    let messageId: NSString
    let created: Int64
}

/////////////////////////////////////////////////////////////////////////////////////

struct ChatMessage :SQLTable{
    
    static var createChatTableStatement = ""
    
    static var createStatement: String {
        return """
        CREATE TABLE ChatMessage\(createChatTableStatement)
        (
        ChatId CHAR(100) NOT NULL UNIQUE,
        CreateAtDate INT NOT NULL,
        Title CHAR(255) NOT NULL,
        FromUserId INT,
        ToUserId INT,
        ChatType INT,
        LastMessage CHAR(255) NOT NULL,
        LastMessageTime CHAR(55) NOT NULL,
        UserImage CHAR(100) NOT NULL
        
        );
        """
    }
    
    let chatId: NSString
    let creatAtDate: Int32
    let title: NSString
    let fromUser: Int32
    let toUser: Int32
    let chatType: Int32
    let lastMessage: NSString
    let lastMessageTime: Int32
    let userImage: NSString
    
    init(chatId: NSString, creatAtDate: Int32, title: NSString, fromUser: Int32, toUser: Int32, chatType: Int32, lastMessage: NSString, lastMessageTime: Int32, userImage: NSString) {
        
        self.chatId = chatId
        self.creatAtDate = creatAtDate
        self.title = title
        self.fromUser = fromUser
        self.toUser = toUser
        self.chatType = chatType
        self.lastMessage = lastMessage
        self.lastMessageTime = lastMessageTime
        self.userImage = userImage
        
    }
    
    init(chatId: NSString, chatMessage: JTChatMessage){

        self.chatId = chatId
        self.creatAtDate = Int32(chatMessage.createdDate)
        self.title = chatMessage.title as NSString
        self.fromUser = Int32(chatMessage.fromUser)
        self.toUser = Int32(chatMessage.toUser)
        self.chatType = Int32(chatMessage.chatType)
        self.lastMessage = chatMessage.lastMessage as NSString
        self.lastMessageTime = Int32(chatMessage.lastMessageTime)
        self.userImage = chatMessage.image as NSString

    }
}


struct Message :SQLTable{
    
    static var createMessageTableStatement = ""
    
    static var createStatement: String {
        return """
        CREATE TABLE ChatMessage\(createMessageTableStatement)
        (
        MessageId CHAR(100) NOT NULL UNIQUE,
        SendAtDate INT NOT NULL,
        Message CHAR(255) NOT NULL,
        Title CHAR(255) NOT NULL,
        MessageType INT,
        FromUserId INT,
        ToUserId INT,
        ChatId INT,
        UserImage CHAR(100) NOT NULL
        
        );
        """
    }
    
    let messageId: NSString
    let sendAtDate: Int32
    let message: NSString
    let title: NSString
    let messageType: Int32
    let fromUser: Int32
    let toUser: Int32
    let userImage: NSString
    
    init(messageId: NSString, sendAtDate: Int32, message: NSString, title: NSString, messageType: Int32, fromUser: Int32, toUser: Int32, userImage: NSString) {
        
        self.messageId = messageId
        self.sendAtDate = sendAtDate
        self.message = message
        self.title = title
        self.messageType = messageType
        self.fromUser = fromUser
        self.toUser = toUser
        self.userImage = userImage
        
    }
    
    init(messageId: NSString, chatMessage: JTMessage){

        self.messageId = messageId
        self.sendAtDate = Int32(chatMessage.sentDate)
        self.message = chatMessage.message as NSString
        self.title = chatMessage.title as NSString
        self.messageType = Int32(chatMessage.messageType)
        self.fromUser = Int32(chatMessage.fromUser)
        self.toUser = Int32(chatMessage.toUser)
        self.userImage = chatMessage.image as NSString

    }
}


