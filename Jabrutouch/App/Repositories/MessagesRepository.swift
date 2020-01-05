//
//  MessagesRepository.swift
//  Jabrutouch
//
//  Created by Shlomo Carmen on 10/12/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import Foundation
import Firebase
import FirebaseMessaging

protocol MessagesRepositoryDelegate: class {
    func didReciveNewMessage(allChats: [JTChatMessage])
}

class MessagesRepository: NSObject, MessagingDelegate {
    
    var fcmToken = ""
    var allChats: [JTChatMessage] = []
    var messages: [JTMessage] = []
    
    weak var delegate: MessagesRepositoryDelegate?
    
    static private var manager: MessagesRepository?
    
    class var shared: MessagesRepository {
        if self.manager == nil {
            self.manager = MessagesRepository()
        }
        return self.manager!
    }
    
    private override init() {
        super.init()
        if self.isEmpty{
            self.getAllMessages { (result: Result<[JTChatMessage], JTError>) in
                switch result {
                case .success(let response):
                    self.getAllChatsFromDB()
                    print(response)
                case .failure(let error):
                    print(error)
                }
            }
        }
        else {
            self.getAllChatsFromDB()
        }
    }
    
    var isEmpty: Bool {
        do {
            let managedContext = CoreDataManager.shared.managedContext
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Chat")
            let count  = try managedContext.count(for: request)
            return count == 0
        } catch {
            return true
        }
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("fcmToken: \(fcmToken)")
        self.fcmToken = fcmToken
    }
    
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("Message ==> ")
        
        // pars message and save in DB
    }
    
    func didReciveMessage(message: JTMessage){
        self.displayNewMessageAndChat(message: message)
        self.delegate?.didReciveNewMessage(allChats: self.allChats)
        self.saveMessageInDB(message: message)
    }
    
    func displayNewMessageAndChat(message: JTMessage){
        var chatExist = false
        for (i, chat) in allChats.enumerated() {
            if chat.chatId == message.chatId{
                chatExist = true
                self.allChats[i].messages.append(message)
                self.allChats[i].lastMessageTime = message.sentDate
            }
        }
        
        if !chatExist{
            self.allChats.append(JTChatMessage(
                chatId: message.chatId,
                createdDate: message.sentDate,
                title: message.title,
                fromUser: message.fromUser,
                toUser: message.toUser,
                chatType: 1,
                lastMessage: message.message,
                lastMessageTime: message.sentDate,
                image: message.image,
                read: message.read))
        }
        
    }
    
    func saveMessageInDB(message: JTMessage){
        CoreDataManager.shared.saveMessage(message: message)
    }
    
    
    func saveChatInDB(chat: JTChatMessage){
        CoreDataManager.shared.seveChat(chat: chat)
    }
    
    func sendMessage(message: String, sentAt:Date, title: String, messageType: Int, toUser: Int, chatId: Int, completion: @escaping (_ result: Result<[GetCreateMessageResponse],JTError>)->Void) {
        guard let authToken = UserDefaultsProvider.shared.currentUser?.token else {
            completion(.failure(.authTokenMissing))
            return
        }
        API.createMessage(message: message, sentAt: sentAt, title: title, messageType: messageType, toUser: toUser, chatId: chatId, token: authToken) { (result: APIResult<GetCreateMessageResponse>) in
            switch result {
            case .success(let response):
                self.saveMessageInDB(message: response.message)
            case .failure(let error):
                completion(.failure(error))
            }

        }
    }
    
    func getAllMessages(completion: @escaping (_ result: Result<[JTChatMessage],JTError>)->Void) {
        guard let authToken = UserDefaultsProvider.shared.currentUser?.token else {
            completion(.failure(.authTokenMissing))
            return
        }
        API.getMessages(authToken: authToken) { (resolt: APIResult<GetMessagesResponse>) in
            switch resolt {
            case .success(let response):
                for chat in response.chats {
                    self.saveChatInDB(chat: chat)
                    for message in chat.messages{
                        self.saveMessageInDB(message: message)
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func getAllChatsFromDB() {
        self.allChats = CoreDataManager.shared.getAllChats()
        
    }
    
    func getAllMessagesFromDB(chatId: Int) {
        self.messages = CoreDataManager.shared.getMessagesByChatId(chatId: chatId)
    }
    
}

