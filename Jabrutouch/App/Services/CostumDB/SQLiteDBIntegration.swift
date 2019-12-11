//
//  SQLiteDBIntegration.swift
//  Jabrutouch
//
//  Created by Shlomo Carmen on 11/12/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import Foundation
import UIKit
import SQLite3

class SQLiteDBIntegration{
    
    //==================================
    //MARK :  struct StatmentString
    //==================================
    
    struct SQLiteStatmentString {
        static let createTable = """
                                  CREATE TABLE Contact(
                                  Id INT PRIMARY KEY NOT NULL,
                                  Name CHAR(255));
                                  """
         static let insertStatement = "INSERT INTO Contact (MessageId,UserName ,UserImage,Massage,MUserId,SendAtDate,MessageType,ChatType,FileLink,GroupName, MessageRead, MessageSent, MessageReceived, Status)  VALUES (?, ?, ?, ?, ?, ?, ?, ?,?, ?, ?, ?, ?, ?);"

        static let queryStatement = "SELECT * FROM Contact"
        static let updateStatement = "UPDATE Contact SET Name = 'Chris' WHERE Id = 1;"
        static let deleteStatement = "DELETE FROM Contact WHERE Id = 1;"

    }
    
    //==================================
    //MARK :  Class Initialize
    //==================================
    
    private static var manager:SQLiteDBIntegration?
    
    class var shared:SQLiteDBIntegration {
        if self.manager == nil {
            self.manager = SQLiteDBIntegration()
        }
        return self.manager!
    }
    
    var db: SQLiteDatabase?
    var messagedb: SQLiteDatabase?
    
    private init() {
    }
    
    func openDB(){
        do {
            self.db = try SQLiteDatabase.open(path: dynamicMessageTablesDB)
            print("Successfully opened connection to database.")
        } catch SQLiteError.OpenDatabase(let message) {
            print("Unable to open database. Verify that you created the directory described in the Getting Started section. ------\(message)")
            db = nil
        }catch {
            db = nil
        }
    }
    
    func closeDB(){
        self.db = nil
    }
    
    func openMessageDB(){
        do {
            self.messagedb = try SQLiteDatabase.open(path: dynamicMessageIdTablesDB)
//            UserDefaultsManager.shared.isMessageIdLogin = true
            
            print("Successfully opened connection to messageId database.")
        } catch SQLiteError.OpenDatabase(let message) {
            print("Unable to open database. Verify that you created the directory described in the Getting Started section. ------\(message)")
            messagedb = nil
        }catch {
            messagedb = nil
        }
    }
    
    func closeMessageDB(){
        self.messagedb = nil
//        UserDefaultsManager.shared.isMessageIdLogin = false
    }
    
    //==================================
    //MARK:  Database Create Table
    //==================================
    
    func createTable(table: SQLTable.Type) throws {
        // 1
        let createTableStatement = try db?.prepareStatement(sql: table.createStatement)
        // 2
        defer {
            sqlite3_finalize(createTableStatement)
        }
        // 3
        guard sqlite3_step(createTableStatement) == SQLITE_DONE else {
            throw SQLiteError.Step(message: (db?.errorMessage) ?? "Error")
        }
        print("\(table) table created.")
    }
    
    func createMessageTable(table: SQLTable.Type) throws {
        // 1
        let createTableStatement = try messagedb?.prepareStatement(sql: table.createStatement)
        // 2
        defer {
            sqlite3_finalize(createTableStatement)
        }
        // 3
        guard sqlite3_step(createTableStatement) == SQLITE_DONE else {
            throw SQLiteError.Step(message: (messagedb?.errorMessage) ?? "Error")
        }
        print("\(table) table created.")
    }

    func createLastMessageTable(table: SQLTable.Type) throws {
        // 1
        let createTableStatement = try db?.prepareStatement(sql: table.createStatement)
        // 2
        defer {
            sqlite3_finalize(createTableStatement)
        }
        // 3
        guard sqlite3_step(createTableStatement) == SQLITE_DONE else {
            throw SQLiteError.Step(message: (db?.errorMessage) ?? "Error")
        }
        print("\(table) table created.")
    }
    
    func createGroupListTable(table: SQLTable.Type) throws {
        // 1
        let createTableStatement = try db?.prepareStatement(sql: table.createStatement)
        // 2
        defer {
            sqlite3_finalize(createTableStatement)
        }
        // 3
        guard sqlite3_step(createTableStatement) == SQLITE_DONE else {
            throw SQLiteError.Step(message: (db?.errorMessage) ?? "Error")
        }
        print("\(table) table created.")
    }
    
    //==================================
    //MARK:  Database Insert
    //==================================
    
    func insertContact(contact: ContactChatMessage, insert:InsertStatement) throws {
        let insertStatement = try db?.prepareStatement(sql: insert.insertStatement)
        defer {
            sqlite3_finalize(insertStatement)
        }
        
        guard sqlite3_bind_text(insertStatement, 1, contact.messageId.utf8String, -1, nil) == SQLITE_OK  &&
            sqlite3_bind_text(insertStatement, 2, contact.userName.utf8String, -1, nil) == SQLITE_OK &&
            sqlite3_bind_text(insertStatement, 3, contact.userImage.utf8String, -1, nil) == SQLITE_OK  &&
            sqlite3_bind_text(insertStatement, 4, contact.massage.utf8String, -1, nil) == SQLITE_OK &&
            sqlite3_bind_int(insertStatement, 5, contact.mUserId) == SQLITE_OK  &&
            sqlite3_bind_text(insertStatement, 6, contact.sendAtDate.utf8String, -1, nil) == SQLITE_OK &&
            sqlite3_bind_int(insertStatement, 7, contact.messageType) == SQLITE_OK  &&
            sqlite3_bind_int(insertStatement, 8, contact.chatType) == SQLITE_OK &&
            sqlite3_bind_text(insertStatement, 9, contact.fileLink.utf8String, -1, nil) == SQLITE_OK  &&
            sqlite3_bind_text(insertStatement, 10, contact.groupName.utf8String, -1, nil) == SQLITE_OK &&
            sqlite3_bind_text(insertStatement, 11, contact.messageSent.utf8String, -1, nil) == SQLITE_OK &&
            sqlite3_bind_text(insertStatement, 12, contact.messageReceived.utf8String, -1, nil) == SQLITE_OK &&
            sqlite3_bind_text(insertStatement, 13, contact.messageRead.utf8String, -1, nil) == SQLITE_OK &&
            sqlite3_bind_int(insertStatement, 14, contact.status) == SQLITE_OK
        
            else {
                throw SQLiteError.Bind(message: (db?.errorMessage) ?? "Error")
        }
        
        guard sqlite3_step(insertStatement) == SQLITE_DONE else {
            throw SQLiteError.Step(message: (db?.errorMessage) ?? "Error")
        }
        
        print("Successfully inserted row.")
    }
    
    func insertContactLastMessage(contact: ContactLastChatMessage, insert:InsertLastMessageStatement) throws {
        let insertStatement = try db?.prepareStatement(sql: insert.insertStatement)
        
        try deleteRow(tableId: contact.tableId)
        
        defer {
            sqlite3_finalize(insertStatement)
        }
        guard sqlite3_bind_text(insertStatement, 1, contact.tableId.utf8String, -1, nil) == SQLITE_OK  &&
            sqlite3_bind_text(insertStatement, 2, contact.messageId.utf8String, -1, nil) == SQLITE_OK  &&
            sqlite3_bind_text(insertStatement, 3, contact.userName.utf8String, -1, nil) == SQLITE_OK &&
            sqlite3_bind_text(insertStatement, 4, contact.userImage.utf8String, -1, nil) == SQLITE_OK  &&
            sqlite3_bind_text(insertStatement, 5, contact.massage.utf8String, -1, nil) == SQLITE_OK &&
            sqlite3_bind_int(insertStatement, 6, contact.mUserId) == SQLITE_OK  &&
            sqlite3_bind_text(insertStatement, 7, contact.sendAtDate.utf8String, -1, nil) == SQLITE_OK &&
            sqlite3_bind_int(insertStatement, 8, contact.messageType) == SQLITE_OK  &&
            sqlite3_bind_int(insertStatement, 9, contact.chatType) == SQLITE_OK &&
            sqlite3_bind_text(insertStatement, 10, contact.fileLink.utf8String, -1, nil) == SQLITE_OK  &&
            sqlite3_bind_text(insertStatement, 11, contact.groupName.utf8String, -1, nil) == SQLITE_OK &&
            sqlite3_bind_text(insertStatement, 12, contact.messageSent.utf8String, -1, nil) == SQLITE_OK &&
            sqlite3_bind_text(insertStatement, 13, contact.messageReceived.utf8String, -1, nil) == SQLITE_OK &&
            sqlite3_bind_text(insertStatement, 14, contact.messageRead.utf8String, -1, nil) == SQLITE_OK &&
            sqlite3_bind_int(insertStatement, 15, contact.status) == SQLITE_OK
            
            else {
                throw SQLiteError.Bind(message: (self.db?.errorMessage) ?? "Error")
        }
        
        guard sqlite3_step(insertStatement) == SQLITE_DONE else {
            throw SQLiteError.Step(message: (self.db?.errorMessage) ?? "Error")
        }
        
        print("Successfully inserted row.")
        
        
    }
    
    func insertContactGroupList(contactGroup: ContactGroupList, insert:InsertGroupListStatement) throws {
        let insertStatement = try db?.prepareStatement(sql: insert.insertStatement)
        
        defer {
            sqlite3_finalize(insertStatement)
        }
        guard sqlite3_bind_text(insertStatement, 1, contactGroup.GroupTableId.utf8String, -1, nil) == SQLITE_OK  &&
            sqlite3_bind_text(insertStatement, 2, contactGroup.name.utf8String, -1, nil) == SQLITE_OK  &&
            sqlite3_bind_text(insertStatement, 3, contactGroup.description.utf8String, -1, nil) == SQLITE_OK &&
            sqlite3_bind_int(insertStatement, 4, contactGroup.isKickedOff) == SQLITE_OK
            else {
                throw SQLiteError.Bind(message: (self.db?.errorMessage) ?? "Error")
        }
        
        guard sqlite3_step(insertStatement) == SQLITE_DONE else {
            throw SQLiteError.Step(message: (self.db?.errorMessage) ?? "Error")
        }
        print("Successfully inserted row.")
    }
   
    /**
     *   # message sent -> received -> read modul Shlomo
     *    create table in DB for message receivd & read by group
     **/
    func insertGroupMessageInfo(groupMessageInfo: GroupMessageInfo, insert:InsertGroupMessageInfo) throws {
        let insertStatement = try db?.prepareStatement(sql: insert.insertStatement)
        
        defer {
            sqlite3_finalize(insertStatement)
        }
        guard sqlite3_bind_text(insertStatement, 1, groupMessageInfo.GroupTableId.utf8String, -1, nil) == SQLITE_OK  &&
            sqlite3_bind_text(insertStatement, 2, groupMessageInfo.messageId.utf8String, -1, nil) == SQLITE_OK  &&
            sqlite3_bind_text(insertStatement, 3, groupMessageInfo.userId.utf8String, -1, nil) == SQLITE_OK &&
            sqlite3_bind_text(insertStatement, 4, groupMessageInfo.receivedDate.utf8String, -1, nil) == SQLITE_OK &&
            sqlite3_bind_text(insertStatement, 5, groupMessageInfo.readDate.utf8String, -1, nil) == SQLITE_OK
            else {
                throw SQLiteError.Bind(message: (self.db?.errorMessage) ?? "Error")
        }
        
        guard sqlite3_step(insertStatement) == SQLITE_DONE else {
            throw SQLiteError.Step(message: (self.db?.errorMessage) ?? "Error")
        }
        print("Successfully inserted row.")
    }
    /* END */
    
    func insertContactOpportunityList(contactGroup: ContactOpportunityList, insert:InsertOpportunityListStatement) throws {
        let insertStatement = try db?.prepareStatement(sql: insert.insertStatement)
        
        defer {
            sqlite3_finalize(insertStatement)
        }
        guard sqlite3_bind_text(insertStatement, 1, contactGroup.GroupTableId.utf8String, -1, nil) == SQLITE_OK  &&
            sqlite3_bind_text(insertStatement, 2, contactGroup.name.utf8String, -1, nil) == SQLITE_OK  &&
            sqlite3_bind_text(insertStatement, 3, contactGroup.description.utf8String, -1, nil) == SQLITE_OK &&
            sqlite3_bind_text(insertStatement, 4, contactGroup.created.utf8String, -1, nil) == SQLITE_OK &&
            sqlite3_bind_int(insertStatement, 5, contactGroup.manegerId) == SQLITE_OK
            else {
                throw SQLiteError.Bind(message: (self.db?.errorMessage) ?? "Error")
        }
        
        guard sqlite3_step(insertStatement) == SQLITE_DONE else {
            throw SQLiteError.Step(message: (self.db?.errorMessage) ?? "Error")
        }
        print("Successfully inserted row.")
    }
    
    func insertMessageIdList(messageIdList: MessageIdList, insert:InsertMessageId) throws {
        let insertStatement = try messagedb?.prepareStatement(sql: insert.insertStatement)
        
        defer {
            sqlite3_finalize(insertStatement)
        }
        guard sqlite3_bind_text(insertStatement, 1, messageIdList.messageId.utf8String, -1, nil) == SQLITE_OK &&
            sqlite3_bind_int64(insertStatement, 2, messageIdList.created) == SQLITE_OK

            else {
                throw SQLiteError.Bind(message: (self.messagedb?.errorMessage) ?? "Error")
        }
        
        guard sqlite3_step(insertStatement) == SQLITE_DONE else {
            throw SQLiteError.Step(message: (self.messagedb?.errorMessage) ?? "Error")
        }
        print("Successfully inserted row.")
    }


    func insertCollection() {
        
        var insertStatement: OpaquePointer? = nil
        let names: [NSString] = ["Ray", "Chris", "Martha", "Danielle"]
        if sqlite3_prepare_v2(db?.dbPointer, SQLiteStatmentString.insertStatement, -1, &insertStatement, nil) == SQLITE_OK {
            for (index, name) in names.enumerated() {
                let id = Int32(index + 1)
                sqlite3_bind_int(insertStatement, 1, id)
                sqlite3_bind_text(insertStatement, 2, name.utf8String, -1, nil)
                
                if sqlite3_step(insertStatement) == SQLITE_DONE {
                    print("Successfully inserted row.")
                } else {
                    print("Could not insert row.")
                }
                // 4
                sqlite3_reset(insertStatement)
            }
            
            sqlite3_finalize(insertStatement)
        } else {
            print("INSERT statement could not be prepared.")
        }
    }
    
    //==================================
    //MARK:  Database Query
    //==================================
    
    func queryTablesName() ->[String] {
        var queryStatement: OpaquePointer? = nil
        var tablesName:[String] = []
        if sqlite3_prepare_v2(db?.dbPointer,"SELECT name FROM sqlite_master WHERE type='table';", -1, &queryStatement, nil) == SQLITE_OK {
            while (sqlite3_step(queryStatement) == SQLITE_ROW) {
                let queryResultCol = sqlite3_column_text(queryStatement, 0)
                print(String(cString: queryResultCol!))
                tablesName.append(String(cString: queryResultCol!))
            }
            return tablesName
        } else {
            print("SELECT statement could not be prepared")
            sqlite3_finalize(queryStatement)
            return tablesName
        }
    }
    
    var isMessgeTableExist: Bool {
        var queryStatement: OpaquePointer? = nil
        var tablesName:[String] = []
        if sqlite3_prepare_v2(messagedb?.dbPointer,"SELECT name FROM sqlite_master WHERE type='table' AND name='\(messagesIdListTableName)';", -1, &queryStatement, nil) == SQLITE_OK {
            while (sqlite3_step(queryStatement) == SQLITE_ROW) {
                let queryResultCol = sqlite3_column_text(queryStatement, 0)
                print(String(cString: queryResultCol!))
                tablesName.append(String(cString: queryResultCol!))
            }
            return tablesName.count > 0
        } else {
            print("SELECT statement could not be prepared")
            sqlite3_finalize(queryStatement)
            return tablesName.count > 0
        }

    }
    
    func queryMessageIdExist(message: String) -> Bool {
        var queryStatement: OpaquePointer? = nil
        var messagesId:[String] = []
        // 1
        if sqlite3_prepare_v2(messagedb?.dbPointer,"SELECT messageId FROM MessageIdList WHERE messageId='\(message)';", -1, &queryStatement, nil) == SQLITE_OK {
            // 2
            while (sqlite3_step(queryStatement) == SQLITE_ROW) {
                // 3
                let queryResultCol = sqlite3_column_text(queryStatement, 0)
                // 4
                print(String(cString: queryResultCol!))
                messagesId.append(String(cString: queryResultCol!))
                
            }
            return messagesId.count > 0
        } else {
            print("SELECT statement could not be prepared")
            sqlite3_finalize(queryStatement)
            return messagesId.count > 0
        }
        // 6
    }

    func queryMessageId() -> [String] {
        var queryStatement: OpaquePointer? = nil
        var messagesId:[String] = []
        // 1
        if sqlite3_prepare_v2(messagedb?.dbPointer,"SELECT * FROM MessageIdList;", -1, &queryStatement, nil) == SQLITE_OK {
            // 2
            while (sqlite3_step(queryStatement) == SQLITE_ROW) {
                // 3
                let queryResultCol = sqlite3_column_text(queryStatement, 0)
                // 4
                print(String(cString: queryResultCol!))
                messagesId.append(String(cString: queryResultCol!))
                
            }
            return messagesId
        } else {
            print("SELECT statement could not be prepared")
            sqlite3_finalize(queryStatement)
            return messagesId
        }
        // 6
    }
    
    func queryMessageId(oldTime:Int64) -> [String] {
        var queryStatement: OpaquePointer? = nil
        var messagesId:[String] = []
        // 1
        if sqlite3_prepare_v2(messagedb?.dbPointer,"SELECT * FROM MessageIdList WHERE created<\(oldTime);", -1, &queryStatement, nil) == SQLITE_OK {
            // 2
            while (sqlite3_step(queryStatement) == SQLITE_ROW) {
                // 3
                let queryResultCol = sqlite3_column_text(queryStatement, 0)
                // 4
                print(String(cString: queryResultCol!))
                messagesId.append(String(cString: queryResultCol!))
                
            }
            return messagesId
        } else {
            print("SELECT statement could not be prepared")
            sqlite3_finalize(queryStatement)
            return messagesId
        }
        // 6
    }
    
    func query() {
        var queryStatement: OpaquePointer? = nil
        // 1
        if sqlite3_prepare_v2(db?.dbPointer, SQLiteStatmentString.queryStatement, -1, &queryStatement, nil) == SQLITE_OK {
            // 2
            if sqlite3_step(queryStatement) == SQLITE_ROW {
                // 3
                let id = sqlite3_column_int(queryStatement, 0)
                
                // 4
                let queryResultCol1 = sqlite3_column_text(queryStatement, 1)
                let name = String(cString: queryResultCol1!)
                
                // 5
//                print("Query Result:")
                print("\(id) | \(name)")
                
            } else {
                print("Query returned no results")
            }
        } else {
            print("SELECT statement could not be prepared")
        }
        
        // 6
        sqlite3_finalize(queryStatement)
    }
    
    func queryCollection(queryStatementStr:QueryStatement) -> [ContactChatMessage]{
        var queryStatement: OpaquePointer? = nil
        var messages : [ContactChatMessage] = []
        if sqlite3_prepare_v2(db?.dbPointer, queryStatementStr.queryStatement, -1, &queryStatement, nil) == SQLITE_OK {
            
            while (sqlite3_step(queryStatement) == SQLITE_ROW) {
                let messageId = sqlite3_column_text(queryStatement, 0)
                let userName = sqlite3_column_text(queryStatement, 1)
                let userImage = sqlite3_column_text(queryStatement, 2)
                let massage = sqlite3_column_text(queryStatement, 3)
                let nUserId = sqlite3_column_int(queryStatement, 4)
                let sendAtDate = sqlite3_column_text(queryStatement, 5)
                let messageType = sqlite3_column_int(queryStatement, 6)
                let chatType = sqlite3_column_int(queryStatement, 7)
                let fileLink = sqlite3_column_text(queryStatement, 8)
                let groupName = sqlite3_column_text(queryStatement, 9)
                let messageSent = sqlite3_column_text(queryStatement, 10)
                let messageReceived = sqlite3_column_text(queryStatement, 11)
                let messageRead = sqlite3_column_text(queryStatement, 12)
                let status = sqlite3_column_int(queryStatement, 13)
                
                let message = ContactChatMessage(messageId: String(cString: messageId!) as NSString, userName: String(cString: userName!) as NSString, userImage: String(cString: userImage!) as NSString, massage: String(cString: massage!) as NSString, mUserId: nUserId, sendAtDate: String(cString: sendAtDate!) as NSString, messageType: messageType, chatType: chatType, fileLink:  String(cString: fileLink!) as NSString, groupName: String(cString: groupName!) as NSString, messageSent: String(cString: messageSent!) as NSString, messageReceived: String(cString: messageReceived!) as NSString, messageRead: String(cString: messageRead!) as NSString, status: status)
                messages.append(message)
//                let id = sqlite3_column_int(queryStatement, 0)
//                let queryResultCol1 = sqlite3_column_text(queryStatement, 1)
//                let name = String(cString: queryResultCol1!)
                print("Query Result: \(message)" )
            }
         sqlite3_finalize(queryStatement)
         return messages
            
        }
        else {
            sqlite3_finalize(queryStatement)
            print("SELECT statement could not be prepared")
            return messages
        }
    }
    
    func queryCollectionLastMessage() -> [ContactLastChatMessage]{
        let statment:String = "SELECT * FROM ContactChatMessage\(lastMessageTableName)"
        var queryStatement: OpaquePointer? = nil
        var messages : [ContactLastChatMessage] = []
        if sqlite3_prepare_v2(db?.dbPointer, statment, -1, &queryStatement, nil) == SQLITE_OK {
            
            while (sqlite3_step(queryStatement) == SQLITE_ROW) {
                
                let tableId = sqlite3_column_text(queryStatement, 0)
                let messageId = sqlite3_column_text(queryStatement, 1)
                let userName = sqlite3_column_text(queryStatement, 2)
                let userImage = sqlite3_column_text(queryStatement, 3)
                let massage = sqlite3_column_text(queryStatement, 4)
                let nUserId = sqlite3_column_int(queryStatement, 5)
                let sendAtDate = sqlite3_column_text(queryStatement, 6)
                let messageType = sqlite3_column_int(queryStatement, 7)
                let chatType = sqlite3_column_int(queryStatement, 8)
                let fileLink = sqlite3_column_text(queryStatement, 9)
                let groupName = sqlite3_column_text(queryStatement, 10)
                let messageSent = sqlite3_column_text(queryStatement, 11)
                let messageReceived = sqlite3_column_text(queryStatement, 12)
                let messageRead = sqlite3_column_text(queryStatement, 13)
                let status = sqlite3_column_int(queryStatement, 14)
                
                let message = ContactLastChatMessage(tableId:String(cString:tableId!) as NSString, messageId: String(cString: messageId!) as NSString, userName: String(cString: userName!) as NSString, userImage: String(cString: userImage!) as NSString, massage: String(cString: massage!) as NSString, mUserId: nUserId, sendAtDate: String(cString: sendAtDate!) as NSString, messageType: messageType, chatType: chatType, fileLink: String(cString: fileLink!) as NSString, groupName: String(cString: groupName!) as NSString,  messageSent: String(cString: messageSent!) as NSString, messageReceived: String(cString: messageReceived!) as NSString, messageRead: String(cString: messageRead!) as NSString, status: status)
                
                messages.append(message)
                
                print("Query Result:")
            }
            sqlite3_finalize(queryStatement)
            return messages
        }
        else {
            sqlite3_finalize(queryStatement)
            print("SELECT statement could not be prepared")
            return messages
        }
    }
    
    func queryCollectionGroupList() -> [ContactGroupList]{
        let statment:String = "SELECT * FROM ContactChatMessage\(contactGroupListTableName);"
        var queryStatement: OpaquePointer? = nil
        var groupList : [ContactGroupList] = []
        if sqlite3_prepare_v2(db?.dbPointer, statment, -1, &queryStatement, nil) == SQLITE_OK {
            
            while (sqlite3_step(queryStatement) == SQLITE_ROW) {
                
                let groupTableId = sqlite3_column_text(queryStatement, 0)
                let name = sqlite3_column_text(queryStatement, 1)
                let description = sqlite3_column_text(queryStatement, 2)
                let isKickedOff = sqlite3_column_int(queryStatement, 3)
                
                
                let group = ContactGroupList(GroupTableId: String(cString:groupTableId!) as NSString, name: String(cString:name!) as NSString, description: String(cString:description!) as NSString, isKickedOff: isKickedOff)
                
                groupList.append(group)
                
                print("Query Result: \(group)")
            }
            sqlite3_finalize(queryStatement)
            return groupList
        }
        else {
            sqlite3_finalize(queryStatement)
            print("SELECT statement could not be prepared")
            return groupList
        }
    }
    
    func queryCollectionOpportunityList() -> [ContactOpportunityList]{
        let statment:String = "SELECT * FROM ContactChatMessage\(contactOpportunityListTableName);"
        var queryStatement: OpaquePointer? = nil
        var groupList : [ContactOpportunityList] = []
        if sqlite3_prepare_v2(db?.dbPointer, statment, -1, &queryStatement, nil) == SQLITE_OK {

            while (sqlite3_step(queryStatement) == SQLITE_ROW) {
                
                let groupTableId = sqlite3_column_text(queryStatement, 0)
                let name = sqlite3_column_text(queryStatement, 1)
                let description = sqlite3_column_text(queryStatement, 2)
                let created = sqlite3_column_text(queryStatement, 3)
                let manegerId = sqlite3_column_int(queryStatement, 4)
                
                
                let group = ContactOpportunityList(GroupTableId: String(cString:groupTableId!) as NSString, name: String(cString:name!) as NSString, description: String(cString:description!) as NSString, created: String(cString:created!) as NSString, manegerId: manegerId)
                
                groupList.append(group)
                
                print("Query Result:")
            }
            sqlite3_finalize(queryStatement)
            return groupList
        }
        else {
            sqlite3_finalize(queryStatement)
            print("SELECT statement could not be prepared")
            return groupList
        }
    }
    
    /**
     *   # message sent -> received -> read modul Shlomo
     *    gets table name my messageId
     **/
    func queryTableName(message: String) -> String{
        let statment:String = "SELECT Tableid FROM ContactChatMessage\(lastMessageTableName) WHERE messageId='\(message)';"
        var queryStatement: OpaquePointer? = nil
        var tableId : String = ""
        if sqlite3_prepare_v2(db?.dbPointer, statment, -1, &queryStatement, nil) == SQLITE_OK {
            
            while (sqlite3_step(queryStatement) == SQLITE_ROW) {
                
               let tableIdFromDB = sqlite3_column_text(queryStatement, 0)
                
                tableId = String(cString: tableIdFromDB!)
                
                print("Query Result:")
            }
            sqlite3_finalize(queryStatement)
            return tableId
        }
        else {
            sqlite3_finalize(queryStatement)
            print("SELECT- GET statement could not be prepared")
            return tableId
        }
    }
    /* END */
    
    //==================================
    //MARK:  Database Update
    //==================================
    
//    func updateAllMessages(messageId: NSString, tableId: NSString) throws {
//        var updateStatement: OpaquePointer? = nil
//        let statment = "UPDATE ContactChatMessage\(tableId) SET MessageReceived = 1 WHERE messageId='\(messageId)'"
//        if sqlite3_prepare_v2(db?.dbPointer, statment, -1, &updateStatement, nil) == SQLITE_OK {
//            if sqlite3_step(updateStatement) == SQLITE_DONE {
//                print("Successfully updated row.")
//            } else {
//                print("Could not update row.")
//                throw SQLiteError.Step(message: (self.db?.errorMessage) ?? "Error")
//            }
//        } else {
//            print("UPDATE statement could not be prepared")
//        }
//        sqlite3_finalize(updateStatement)
//    }
   
    /**
     *   # message sent -> received -> read modul Shlomo
     *    updating DB column when message sent / received / read
     **/
    func update(messageId: NSString, tableId: NSString, columnToUpdate: NSString, date: String) throws{
        var updateStatement: OpaquePointer? = nil
        try insertIfNotExists(tableId: tableId, columnToAdd: columnToUpdate)
        let statment = "UPDATE ContactChatMessage\(tableId) SET \(columnToUpdate) = \(date) WHERE messageId='\(messageId)'"
        if sqlite3_prepare_v2(db?.dbPointer, statment, -1, &updateStatement, nil) == SQLITE_OK {
            if sqlite3_step(updateStatement) == SQLITE_DONE {
                print("Successfully updated row.")
            } else {
                print("Could not update row.")
                throw SQLiteError.Step(message: (self.db?.errorMessage) ?? "Error")
            }
        } else {
            print("UPDATE statement could not be prepared")
            
        }
        sqlite3_finalize(updateStatement)
    }
    
    /**
     *   # message sent -> received -> read modul Shlomo
     *    updating DB status column when message sent / received / read
     **/
    func updateStatus(messageId: NSString, tableId: NSString, status: Int32) throws{
        var updateStatement: OpaquePointer? = nil
        let statment = "UPDATE ContactChatMessage\(tableId) SET Status = \(status) WHERE messageId='\(messageId)'"
        if sqlite3_prepare_v2(db?.dbPointer, statment, -1, &updateStatement, nil) == SQLITE_OK {
            if sqlite3_step(updateStatement) == SQLITE_DONE {
                print("Successfully updated row.")
            } else {
                print("Could not update row.")
                throw SQLiteError.Step(message: (self.db?.errorMessage) ?? "Error")
            }
        } else {
            print("UPDATE statement could not be prepared")
            
        }
        sqlite3_finalize(updateStatement)
    }
    
    /**
     *   # message sent -> received -> read modul Shlomo
     *    updating DB column when message received / read by group chat
     **/
    func updateMessageInfoTable(userId: NSString, tableId: NSString, date: NSString) throws{
        var updateStatement: OpaquePointer? = nil
        let statment = "UPDATE ContactChatMessage\(tableId) SET MessageRead = \(date) WHERE userId='\(userId)'"
        if sqlite3_prepare_v2(db?.dbPointer, statment, -1, &updateStatement, nil) == SQLITE_OK {
            if sqlite3_step(updateStatement) == SQLITE_DONE {
                print("Successfully updated row.")
            } else {
                print("Could not update row.")
                throw SQLiteError.Step(message: (self.db?.errorMessage) ?? "Error")
            }
        } else {
            print("UPDATE statement could not be prepared")
            
        }
        sqlite3_finalize(updateStatement)
    }
    
    /**
     *   # message sent -> received -> read modul Shlomo
     *    addeing to DB missing fields if not exists
     **/
    func insertIfNotExists(tableId: NSString, columnToAdd: NSString) throws {
        var updateStatement: OpaquePointer? = nil
        
        let insetStatment = "ALTER TABLE ContactChatMessage\(tableId) ADD COLUMN \(columnToAdd) CHAR(55)"
        if sqlite3_prepare_v2(db?.dbPointer, insetStatment, -1, &updateStatement, nil) == SQLITE_OK {
            if sqlite3_step(updateStatement) == SQLITE_DONE {
                print("Successfully added row.")
            } else {
                print("Could not add row.")
                throw SQLiteError.Step(message: (self.db?.errorMessage) ?? "Error")
            }
        } else {
            print("INSERT statement could not be prepared")
            
        }
        sqlite3_finalize(updateStatement)

    }
    
    //==================================
    //MARK:  Database Delete
    //==================================
    
    func deleteRow(tableId:NSString) throws{
        var deleteStatement: OpaquePointer? = nil
        let statment = "DELETE FROM ContactChatMessage\(lastMessageTableName) WHERE TableId='\(tableId)'"
        print(statment)
        if sqlite3_prepare_v2(db?.dbPointer, statment, -1, &deleteStatement, nil) == SQLITE_OK {
            if sqlite3_step(deleteStatement) == SQLITE_DONE {
                print("Successfully deleted row.")
            } else {
                print("Could not delete row.")
                throw SQLiteError.Step(message: (self.db?.errorMessage) ?? "Error")
            }
        } else {
            print("DELETE statement could not be prepared")
            throw SQLiteError.Step(message: (self.db?.errorMessage) ?? "Error")
        }
        
        sqlite3_finalize(deleteStatement)
    }
    
    func deleteRowOpportunityList(tableId:NSString) throws{
        var deleteStatement: OpaquePointer? = nil
        let statment = "DELETE FROM ContactChatMessage\(contactOpportunityListTableName) WHERE groupTableId='\(tableId)'"
        print(statment)
        if sqlite3_prepare_v2(db?.dbPointer, statment, -1, &deleteStatement, nil) == SQLITE_OK {
            if sqlite3_step(deleteStatement) == SQLITE_DONE {
                print("Successfully deleted row.")
            } else {
                print("Could not delete row.")
                throw SQLiteError.Step(message: (self.db?.errorMessage) ?? "Error")
            }
        } else {
            print("DELETE statement could not be prepared")
            throw SQLiteError.Step(message: (self.db?.errorMessage) ?? "Error")
        }
        
        sqlite3_finalize(deleteStatement)
    }

    
    func deleteRowGroupList(tableId:NSString) throws{
        var deleteStatement: OpaquePointer? = nil
        let statment = "DELETE FROM ContactChatMessage\(contactGroupListTableName) WHERE groupTableId='\(tableId)'"
        print(statment)
        if sqlite3_prepare_v2(db?.dbPointer, statment, -1, &deleteStatement, nil) == SQLITE_OK {
            if sqlite3_step(deleteStatement) == SQLITE_DONE {
                print("Successfully deleted row.")
            } else {
                print("Could not delete row.")
                throw SQLiteError.Step(message: (self.db?.errorMessage) ?? "Error")
            }
        } else {
            print("DELETE statement could not be prepared")
            throw SQLiteError.Step(message: (self.db?.errorMessage) ?? "Error")
        }
        
        sqlite3_finalize(deleteStatement)
    }
    
    func deleteRowsMessageId(oldTime:Int64) throws{
        var deleteStatement: OpaquePointer? = nil
        let statment = "DELETE FROM MessageIdList WHERE created<\(oldTime)"
        print(statment)
        if sqlite3_prepare_v2(messagedb?.dbPointer, statment, -1, &deleteStatement, nil) == SQLITE_OK {
            if sqlite3_step(deleteStatement) == SQLITE_DONE {
                print("Successfully deleted row.")
            } else {
                print("Could not delete row.")
                throw SQLiteError.Step(message: (self.messagedb?.errorMessage) ?? "Error")
            }
        } else {
            print("DELETE statement could not be prepared")
            throw SQLiteError.Step(message: (self.messagedb?.errorMessage) ?? "Error")
        }
        
        sqlite3_finalize(deleteStatement)
    }
    
    func deleteRowsMessageId(messageId: String) throws{
//        var deleteStatement: OpaquePointer? = nil
//        let statment = "DELETE FROM MessageIdList WHERE messageId='\(messageId)'"
//        print(statment)
//        if sqlite3_prepare_v2(messagedb?.dbPointer, statment, -1, &deleteStatement, nil) == SQLITE_OK {
//            if sqlite3_step(deleteStatement) == SQLITE_DONE {
//                print("Successfully deleted row.")
//            } else {
//                print("Could not delete row.")
//                throw SQLiteError.Step(message: (self.messagedb?.errorMessage) ?? "Error")
//            }
//        } else {
//            print("DELETE statement could not be prepared")
//            throw SQLiteError.Step(message: (self.messagedb?.errorMessage) ?? "Error")
//        }
//
//        sqlite3_finalize(deleteStatement)
    }
    
    func dropTable(tableName:NSString ,isGroup:Bool) throws{
        var deleteStatement: OpaquePointer? = nil
        var statment = ""
        if isGroup{
            statment = "DROP TABLE \(tableName)Table;"
        }
        else{
            statment = "DROP TABLE \(tableName);"
        }
        
        print(statment)
        if sqlite3_prepare_v2(db?.dbPointer, statment, -1, &deleteStatement, nil) == SQLITE_OK {
            if sqlite3_step(deleteStatement) == SQLITE_DONE {
                print("Successfully deleted table.")
//                ChimuAllUsers.tbalesDBStringName = queryTablesName()
            } else {
                print("Could not delete table.")
                throw SQLiteError.Step(message: (self.db?.errorMessage) ?? "Error")
            }
        } else {
            print("DELETE statement could not be prepared")
            throw SQLiteError.Step(message: (self.db?.errorMessage) ?? "Error")
        }
        
        sqlite3_finalize(deleteStatement)
    }
    
   
}


