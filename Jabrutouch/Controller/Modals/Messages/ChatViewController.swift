//
//  ChatViewController.swift
//  Jabrutouch
//
//  Created by Shlomo Carmen on 10/12/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import UIKit
import AVFoundation

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //========================================
    // MARK: - Properties
    //========================================
    
    var messagesArray: [JTMessage] = []
    var user: JTUser?
    var currentChat: JTChatMessage?
    
    private lazy var chatControlsView: ChatControlsView = {
        var view = ChatControlsView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 70))
        
        return view
    }()
    
    //========================================
    // MARK: - @IBOutlets
    //========================================
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    //========================================
    // MARK: - LifeCycle
    //========================================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CoreDataManager.shared.delegate = self
        self.chatControlsView.delegate = self
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.titleLabel.text = currentChat?.title
        self.roundCorners()
        self.user = UserRepository.shared.getCurrentUser()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
      //        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
//
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override var inputAccessoryView: UIView?{
        return self.chatControlsView
    }
    
//    @objc func keyboardWillShow(_ notification: NSNotification) {
//        if let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
//
//        }
//    }
    
    //========================================
    // MARK: - Setup
    //========================================
    
    
    private func roundCorners() {
        
    }
    
    private func getViewHeight(_ text: String) -> CGFloat {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.numberOfLines = 0
        label.text = text
        
        let height = label.sizeThatFits(CGSize(width: 300, height: 600)).height
        return height

    }
    
    private func getViewWidth(_ text: String) -> CGFloat {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.numberOfLines = 0
        label.text = text
        
        let width = label.sizeThatFits(CGSize(width: 300, height: 600)).width
        return width

    }
    
    func getTime(lastMessageTime: Date)-> String {
        
        let timeStemp = lastMessageTime.timeIntervalSince1970
        let toDayAgain = Date(timeIntervalSince1970: timeStemp)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        let string = dateFormatter.string(from: toDayAgain)
        
        return string
        
    }
    
    func getImageFromURL(imageLink: String) {
        
    }
    
    //========================================
    // MARK: - table View
    //========================================

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messagesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.messagesArray[indexPath.row].isMine{
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "userMessageCell", for: indexPath) as? UserMessageCell else { return UITableViewCell() }
            let text = self.messagesArray[indexPath.row].message
            let height = self.getViewHeight(text)
            cell.messageViewHeightConstraint.constant = height + 32
            cell.message.text = text
            cell.timeLabel.text = self.getTime(lastMessageTime: messagesArray[indexPath.row].sentDate)
            cell.userImage.image = user?.profileImage ?? #imageLiteral(resourceName: "Avatar")
            
            return cell
        }else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "incomingMessageCell", for: indexPath) as? IncomingMessageCell else { return UITableViewCell() }
            let text = self.messagesArray[indexPath.row].message
            let height = self.getViewHeight(text)
            cell.messageViewHeightConstraint.constant = height + 32
            cell.message.text = text
            cell.timeLabel.text = self.getTime(lastMessageTime: messagesArray[indexPath.row].sentDate)
            cell.userImage.image = #imageLiteral(resourceName: "incomingUserImege")
            
            return cell
        }
    }
    
   
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let text = self.messagesArray[indexPath.row].message
        let height = self.getViewHeight(text)
        return height + 90    }
    
    
    //========================================
    // MARK: - @IBActions
    //========================================
    
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        
    }
    
//    func sendMessage(message: String, sentAt:Date, title: String, messageType: Int, toUser: Int, chatId: Int){
//        MessagesRepository.shared.sendMessage(message: message, sentAt:sentAt, title: title, messageType: messageType, toUser: toUser, chatId: chatId, completion:  { (resulte) in
//            print(resulte)
//        })
//    }
}

extension ChatViewController: ChatControlsViewDelegate, MessagesRepositoryDelegate {
    func didSendMessage() {
        guard let chat = self.currentChat else{return}
        self.messagesArray = CoreDataManager.shared.getMessagesByChatId(chatId: chat.chatId)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func didReciveNewMessage() {
        
        
    }
    
    func sendMessageButtonPressed() {
        guard let chat = self.currentChat else{return}
        if let text = self.chatControlsView.inputTextView.text {
            #warning("change the message type to Enum. and check the type of the message!!!")
            MessagesRepository.shared.sendMessage(message: text,
                                                  sentAt: Date(),
                                                  title: chat.title,
                                                  messageType: 1,
                                                  toUser: chat.fromUser,
                                                  chatId: chat.chatId, completion:  { (resulte) in
                                                    print(resulte)
            })
            
            if let createMessage = JTMessage(values: [
                "message": text,
                "sent_at": Date().timeIntervalSince1970 * 1000 ,
                "title": chat.title,
                "message_type": 1,
                "from_user": self.user?.id ?? chat.toUser,
                "to_user": chat.fromUser,
                "read": true,
                "is_mine": true,
                "chat_id": chat.chatId]){
                 MessagesRepository.shared.saveMessageInDB(message: createMessage)
                
            }
            
        }
    }


    func textViewChanged() {

    }
}




