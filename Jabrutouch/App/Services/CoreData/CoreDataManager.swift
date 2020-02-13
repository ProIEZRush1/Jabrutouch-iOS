//
//  CoreDataManager.swift
//  Jabrutouch
//
//  Created by Shlomo Carmen on 16/12/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import Foundation
import CoreData

protocol MessagesRepositoryDelegate: class {
    func didReciveNewMessage()
    func didSendMessage()
}

class CoreDataManager {
    
    private static var manager: CoreDataManager?
    
    private init() {
        
    }
    
    class var shared: CoreDataManager {
        if self.manager == nil {
            self.manager = CoreDataManager()
        }
        return self.manager!
    }
    weak var delegate: MessagesRepositoryDelegate?
    let managedContext = appDelegate.managedObjectContext!
    
    func rebootMessages(chats: [JTChatMessage]){
        
        for chat in chats{
            let newChat = NSEntityDescription.insertNewObject(forEntityName: "Chat", into: managedContext)
            newChat.setValue(chat.chatId, forKey: "chatId")
            newChat.setValue(chat.title, forKey: "title")
            newChat.setValue(chat.toUser, forKey: "toUser")
            newChat.setValue(chat.createdDate, forKey: "creatAtDate")
            newChat.setValue(chat.lastMessageTime, forKey: "lastMessageTime")
            newChat.setValue(chat.lastMessage, forKey: "lastMessage")
            newChat.setValue(chat.fromUser, forKey: "fromUser")
            newChat.setValue(chat.chatType, forKey: "chatType")
            newChat.setValue(chat.image, forKey: "userImage")
            newChat.setValue(true, forKey: "read")
            newChat.setValue(0, forKey: "unreadMessages")
            
            for message in chat.messages {
                let newMessage = NSEntityDescription.insertNewObject(forEntityName: "Message", into: managedContext)
                newMessage.setValue(message.chatId, forKey: "chatId")
                newMessage.setValue(message.image, forKey: "userImage")
                newMessage.setValue(message.toUser, forKey: "toUser")
                newMessage.setValue(message.title, forKey: "title")
                newMessage.setValue(message.sentDate, forKey: "sendAtDate")
                newMessage.setValue(message.messageType, forKey: "messageType")
                newMessage.setValue(message.messageId, forKey: "messageId")
                newMessage.setValue(message.message, forKey: "message")
                newMessage.setValue(message.fromUser, forKey: "fromUser")
                newMessage.setValue(message.read, forKey: "read")
                newMessage.setValue(message.isMine, forKey: "isMine")
                newMessage.setValue(message.linkTo, forKey: "linkTo")

            }
        }
        do{
            try managedContext.save()
            print("All messages imported and saved.")
            self.delegate?.didReciveNewMessage()
        }
        catch {
            print("failed")
        }
    }
    
    func seveChat(chat: JTChatMessage) {

        let chatEntity = NSEntityDescription.entity(forEntityName: "Chat", in: managedContext)
        let newChat = NSManagedObject(entity: chatEntity!, insertInto: managedContext)

        newChat.setValue(chat.chatId, forKey: "chatId")
        newChat.setValue(chat.title, forKey: "title")
        newChat.setValue(chat.toUser, forKey: "toUser")
        newChat.setValue(chat.createdDate, forKey: "creatAtDate")
        newChat.setValue(chat.lastMessageTime, forKey: "lastMessageTime")
        newChat.setValue(chat.lastMessage, forKey: "lastMessage")
        newChat.setValue(chat.fromUser, forKey: "fromUser")
        newChat.setValue(chat.chatType, forKey: "chatType")
        newChat.setValue(chat.image, forKey: "userImage")
        newChat.setValue(chat.read, forKey: "read")
        newChat.setValue(chat.unreadMessages, forKey: "unreadMessages")


        do{
            try managedContext.save()
        }
        catch {
            print("failed")
        }
        
    }
    
    func saveMessage(message: JTMessage) {
        let messageEntity = NSEntityDescription.entity(forEntityName: "Message", in: managedContext)
        let newMessage = NSManagedObject(entity: messageEntity!, insertInto: managedContext)
        
        newMessage.setValue(message.chatId, forKey: "chatId")
        newMessage.setValue(message.image, forKey: "userImage")
        newMessage.setValue(message.toUser, forKey: "toUser")
        newMessage.setValue(message.title, forKey: "title")
        newMessage.setValue(message.sentDate, forKey: "sendAtDate")
        newMessage.setValue(message.messageType, forKey: "messageType")
        newMessage.setValue(message.messageId, forKey: "messageId")
        newMessage.setValue(message.message, forKey: "message")
        newMessage.setValue(message.fromUser, forKey: "fromUser")
        newMessage.setValue(message.read, forKey: "read")
        newMessage.setValue(message.isMine, forKey: "isMine")
        newMessage.setValue(message.linkTo, forKey: "linkTo")
        
        do{
            try managedContext.save()
            if !self.chatIdIsExsist(chatId: message.chatId){
                self.seveChat(chat: self.createChatObject(message: message))
                
            }else{
                self.updateChatById(chat: self.createChatObject(message: message))
                self.delegate?.didSendMessage()
            }
            print("Message saved")
            self.delegate?.didReciveNewMessage()
        }
        catch {
            print("failed")
        }
    }
    
    func createChatObject(message: JTMessage)->JTChatMessage{

        return JTChatMessage(
            chatId:  message.chatId,
            createdDate: message.sentDate,
            title: message.title,
            fromUser: message.fromUser,
            toUser: message.toUser,
            chatType: 1,
            lastMessage: message.message,
            lastMessageTime: message.sentDate,
            image: message.image,
            read: message.read,
            unreadMessages: 1
            
        )
    }
    
    func chatIdIsExsist(chatId:Int)->Bool{
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Chat")
        let predicate = NSPredicate(format: "chatId = %i", chatId)
        request.predicate = predicate
        request.returnsObjectsAsFaults = false
        do {
            
            let result = try managedContext.fetch(request)
            if result.isEmpty {
                return false
            }else{
                return true
            }
        } catch {
            print("Failed")
            return false
        }
    }
    
    func getAllChats() ->[JTChatMessage] {
        
        var allChats: [JTChatMessage] = []
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Chat")
        let sort = NSSortDescriptor(key: "lastMessageTime", ascending: false)
        request.sortDescriptors = [sort]
        request.returnsObjectsAsFaults = false
        do {
            let result = try managedContext.fetch(request)
            allChats = (result as! [NSManagedObject]).compactMap{JTChatMessage(values: $0)}
            return allChats
            
        } catch {
            print("Failed")
            return []
        }
    }
    

    
    func getUnReadedChats() ->Int {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Chat")
        let predicate = NSPredicate(format: "unreadMessages > %i",0)
        request.predicate = predicate
        request.returnsObjectsAsFaults = false
        do {
            let result = try managedContext.fetch(request)
            return (result as! [NSManagedObject]).count
        } catch {
            print("Failed")
        }
        return 0
    }

    
    func getMessagesByChatId(chatId: Int) -> [JTMessage] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Message")
        let predicate = NSPredicate(format: "chatId = %i", chatId)
        let sort = NSSortDescriptor(key: "sendAtDate", ascending: true)
        request.sortDescriptors = [sort]
        request.predicate = predicate
        request.returnsObjectsAsFaults = false
        do {
            
            let result = try managedContext.fetch(request)
            
            return (result as! [NSManagedObject]).compactMap{JTMessage(values: $0)}
            
        } catch {
            print("Failed")
            return []
        }
    }
    
    func getAllMessages() -> [JTMessage] {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Message")
        request.returnsObjectsAsFaults = false
        do {
            
            let result = try managedContext.fetch(request)
            
            return (result as! [NSManagedObject]).compactMap{JTMessage(values: $0)}
            
        } catch {
            print("Failed")
            return []
        }
    }
    
    func updateMessageById(message: JTMessage) {
        let predicate = NSPredicate(format: "messageId = %i", message.messageId as? Int ?? 0)
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Message")
        request.predicate = predicate
        request.returnsObjectsAsFaults = false
        do {
            
            let result = try managedContext.fetch(request)
            (result as! [NSManagedObject]).first?.setValue(message.read, forKey: "read")
            do{
                try managedContext.save()
            }
            catch {
                print("failed")
            }
            
        } catch {
            print("Failed")
            
        }
    }
    
    
    func updateChatById(chat: JTChatMessage) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Chat")
        let predicate = NSPredicate(format: "chatId = %i", chat.chatId)
        request.predicate = predicate
        request.returnsObjectsAsFaults = false
        do {
            
            let result = try managedContext.fetch(request)
            if let unReaded = (result as! [NSManagedObject]).first?.value(forKey: "unreadMessages") as? Int{
                (result as! [NSManagedObject]).first?.setValue(Int(unReaded) + 1, forKey: "unreadMessages")
            }
            (result as! [NSManagedObject]).first?.setValue(chat.lastMessage, forKey: "lastMessage")
            (result as! [NSManagedObject]).first?.setValue(chat.lastMessageTime, forKey: "lastMessageTime")
            (result as! [NSManagedObject]).first?.setValue(chat.read, forKey: "read")
            
            do{
                try managedContext.save()
            }
            catch {
                print("failed")
            }
            
        } catch {
            print("Failed")
            
        }
    }
    
    func setChatReadById(chatId: Int, status: Bool) {
        self.delegate?.didReciveNewMessage()
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Chat")
        let predicate = NSPredicate(format: "chatId = %i",chatId)
        request.predicate = predicate
        request.returnsObjectsAsFaults = false
        do {
            let result = try managedContext.fetch(request)
            (result as! [NSManagedObject]).first?.setValue(status, forKey: "read")
            if status{(result as! [NSManagedObject]).first?.setValue(0, forKey: "unreadMessages")}

            do{
                try managedContext.save()
            }
            catch {
                print("failed")
            }
        } catch {
            print("Failed")
        }
    }
    
 
}
