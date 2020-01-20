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
    
    var messagesArray: [[JTMessage]] = []
    var user: JTUser?
    var currentChat: JTChatMessage?
    var dates: [String]?
    
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
    @IBOutlet weak var tableViewButtom: NSLayoutConstraint!
    //========================================
    // MARK: - LifeCycle
    //========================================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CoreDataManager.shared.delegate = self
        CoreDataManager.shared.setChatReadById(chatId: currentChat!.chatId, status: true)
        self.chatControlsView.delegate = self
        MessagesRepository.shared.getAllMessagesFromDB(chatId: currentChat!.chatId)
        (self.messagesArray,self.dates) = self.groupArrayByDate(messages: MessagesRepository.shared.messages)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.titleLabel.text = currentChat?.title
        self.roundCorners()
        self.user = UserRepository.shared.getCurrentUser()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    override func viewDidAppear(_ animated: Bool) {
        //        self.tableView.scrollToRow(at: IndexPath(row: self.messagesArray.count-1, section: 0), at: UITableView.ScrollPosition.bottom, animated: false)
        self.tableView.scrollToRow(at: IndexPath(
            row: self.messagesArray[self.messagesArray.count-1].count-1,
            section: self.messagesArray.count-1 ), at: UITableView.ScrollPosition.bottom, animated: false)
        
    }
    
    override func viewDidLayoutSubviews() {
        
        self.tableView.scrollToRow(at: IndexPath(
            row: self.messagesArray[self.messagesArray.count-1].count-1,
            section: self.messagesArray.count-1 ), at: UITableView.ScrollPosition.bottom, animated: false)
        
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
    
    @objc func keyboardWillShow(_ notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let duration = ((notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey]) as! NSNumber) as! Double
            raiseScreenIfNeeded(keyboardSize.height, duration)
        }
    }
    
    @objc func keyboardWillHide(_ notification: NSNotification) {
        self.tableView.contentInset.bottom = 0
        //            self.tableView.layoutIfNeeded()
        //            self.tableView.scrollToRow(at: IndexPath(row: self.messagesArray.count-1, section: 0), at: UITableView.ScrollPosition.bottom, animated: false)
        
        //        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
        //            let duration = ((notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey]) as! NSNumber) as! Double
        //            raiseScreenIfNeeded(keyboardSize.height, duration)
        //        }
    }
    
    fileprivate func raiseScreenIfNeeded(_ keyboardSize: CGFloat, _ duration: Double) {
        UIView.animate(withDuration: duration) {
            self.tableView.contentInset.bottom = keyboardSize
            self.tableView.contentOffset.y += keyboardSize-70
            self.tableView.layoutIfNeeded()
            self.tableView.scrollToRow(at: IndexPath(
                row: self.messagesArray[self.messagesArray.count-1].count-1,
                section: self.messagesArray.count-1 ), at: UITableView.ScrollPosition.bottom, animated: false)
            
        }
        
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
        
        label.font = Fonts.mediumTextFont(size: 18)
        label.numberOfLines = 0
        label.text = text
        label.lineBreakMode = .byWordWrapping
        let height = label.sizeThatFits(CGSize(width: 218, height: 600)).height
        return height
        
    }
    
    private func getViewWidth(_ text: String) -> CGFloat {
        let label = UILabel()
        label.font = Fonts.mediumTextFont(size: 18)
        label.numberOfLines = 0
        label.text = text
        label.lineBreakMode = .byWordWrapping
        let width = label.sizeThatFits(CGSize(width: 218, height: 600)).width
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
    //    func getTime(lastMessageTime: Date)-> String {
    //
    //        let calander = Calendar.current
    //        let dateFormatter = DateIntervalFormatter()
    //        if calander.isDateInToday(lastMessageTime){
    //            dateFormatter.dateTemplate = "HH:mm:ss"
    //            return dateFormatter.string(from: lastMessageTime, to: lastMessageTime)
    //        }else if calander.isDateInYesterday(lastMessageTime){
    //            dateFormatter.dateTemplate = "HH:mm"
    //            return "Yesterday,\(dateFormatter.string(from: lastMessageTime,to: lastMessageTime)) "
    //        }else{
    //            dateFormatter.dateTemplate = "MMM d, HH:mm"
    //            return dateFormatter.string(from: lastMessageTime,to: lastMessageTime)
    //        }
    //    }
    
    
    
    func getImageFromURL(imageLink: String) {
        
    }
    
    
    //========================================
    // MARK: - group
    //========================================
    
    func groupArrayByDate(messages:[JTMessage]!)->([[JTMessage]],[String]){
        let calander = Calendar.current
        let dateFormatter = DateFormatter()
        var mainArray: [[JTMessage]] = []
        var innerArray: [JTMessage] = []
        var dates: [String] = []
        for message in messages{
            var date: String
            if calander.isDateInToday(message.sentDate){
                date = "HOY"
            }else if calander.isDateInYesterday(message.sentDate){
                date = "AYER"
            }else{
                dateFormatter.dateFormat = calander.component(.year, from: message.sentDate) == calander.component(.year, from: Date()) ? "MMM d" : "MMM d, yyyy"
                date = dateFormatter.string(from: message.sentDate)
            }
            if !dates.contains(date) {
                dates.append(date)
                if !innerArray.isEmpty{
                    mainArray.append(innerArray)
                    innerArray.removeAll()
                }
                innerArray.append(message)
                
            }else{
                innerArray.append(message)
                
            }
        }
        if mainArray.count < dates.count{
            mainArray.append(innerArray)
            innerArray.removeAll()
        }
       
        
        return (mainArray,dates)
    }
    
    //========================================
    // MARK: - table View
    //========================================
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return messagesArray.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return dates?[section]
    }
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = .clear
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textAlignment = .center
        header.textLabel?.textColor = UIColor(red: 0.51, green: 0.51, blue: 0.51, alpha: 1)
        header.textLabel?.font = UIFont(name: "SFProDisplay-Medium", size: 16)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messagesArray[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if self.messagesArray[indexPath.section][indexPath.row].isMine{
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "userMessageCell", for: indexPath) as? UserMessageCell else { return UITableViewCell() }
            let text = self.messagesArray[indexPath.section][indexPath.row].message
            let height = self.getViewHeight(text)
            cell.messageViewHeightConstraint.constant = height + 32
            cell.message.text = text
            cell.timeLabel.text = self.getTime(lastMessageTime: messagesArray[indexPath.section][indexPath.row].sentDate)
            cell.userImage.image = user?.profileImage ?? #imageLiteral(resourceName: "Avatar")
            
            return cell
        }else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "incomingMessageCell", for: indexPath) as? IncomingMessageCell else { return UITableViewCell() }
            let text = self.messagesArray[indexPath.section][indexPath.row].message
            let height = self.getViewHeight(text)
            cell.messageViewHeightConstraint.constant = height + 32
            cell.message.text = text
            cell.timeLabel.text = self.getTime(lastMessageTime: messagesArray[indexPath.section][indexPath.row].sentDate)
            cell.userImage.image = #imageLiteral(resourceName: "incomingUserImege")
            
            return cell
        }
    }
    
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let text = self.messagesArray[indexPath.section][indexPath.row].message
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
        MessagesRepository.shared.getAllMessagesFromDB(chatId: chat.chatId)
        (self.messagesArray, self.dates) = self.groupArrayByDate(messages: MessagesRepository.shared.messages)
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.tableView.scrollToRow(at: IndexPath(
                row: self.messagesArray[self.messagesArray.count-1].count-1,
                section: self.messagesArray.count-1 ), at: UITableView.ScrollPosition.bottom, animated: false)
            
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
                                                    print("")
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




