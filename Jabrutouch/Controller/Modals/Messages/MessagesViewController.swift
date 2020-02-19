//
//  MessagesViewController.swift
//  Jabrutouch
//
//  Created by Shlomo Carmen on 05/12/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import UIKit

class MessagesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    //========================================
    // MARK: - Properties
    //========================================
    
    var messagesArray: [String] = []
    var chatsArray: [JTChatMessage] = []
 
    //========================================
    // MARK: - @IBOutlets
    //========================================
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var noMessagesLabel: UILabel!
    @IBOutlet weak var noMessagesImage: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    //========================================
    // MARK: - LifeCycle
    //========================================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.messagesArray.append("test")

        self.chatsArray = MessagesRepository.shared.getAllChatsFromDB()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        CoreDataManager.shared.delegate = self
//        self.tableView.reloadData()
        self.setTableView()
        
    }
    
   
    //========================================
    // MARK: - Setup
    //========================================
    
    func setTableView() {
        DispatchQueue.main.async {
            if self.chatsArray.count > 0 {
                self.noMessagesImage.isHidden = true
                self.noMessagesLabel.isHidden = true
            } else {
                self.tableView.isHidden = true
                self.searchButton.isHidden =  true
            }
            self.chatsArray = CoreDataManager.shared.getAllChats()
            self.tableView.reloadData()
            
        }
    }
    
    
    func getTime(lastMessageTime: Date)-> String{
        let calander = Calendar.current
        let dateFormatter = DateFormatter()
        var date: String
        if calander.isDateInToday(lastMessageTime){
           dateFormatter.dateFormat = "HH:mm"
           date = dateFormatter.string(from: lastMessageTime)
        }else if calander.isDateInYesterday(lastMessageTime){
            date = "AYER"
        }else{
//            dateFormatter.dateFormat = calander.component(.year, from: lastMessageTime) == calander.component(.year, from: Date()) ? "MMM d" : "MMM d, yyyy"
            dateFormatter.dateFormat = "MMM d"
            date = dateFormatter.string(from: lastMessageTime)
        }
        return date
    }
    
    //========================================
    // MARK: - Table Views
    //========================================
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.chatsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "chatCell", for: indexPath) as? ChatCell else { return UITableViewCell() }
        cell.timeLabel.text = self.getTime(lastMessageTime: chatsArray[indexPath.row].lastMessageTime)
        cell.groupName.text = chatsArray[indexPath.row].title
        cell.message.text = chatsArray[indexPath.row].lastMessage
        
        if !chatsArray[indexPath.row].read{
                cell.timeLabel.font = Fonts.heavyFont(size: 15)
                cell.groupName.font = Fonts.blackFont(size: 17)
                cell.message.font = Fonts.heavyFont(size: 15)
        }else{
            cell.timeLabel.font = Fonts.mediumTextFont(size: 15)
            cell.groupName.font = Fonts.mediumTextFont(size: 17)
            cell.message.font = Fonts.mediumTextFont(size: 15)
        }
        
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        CoreDataManager.shared.setChatReadById(chatId: chatsArray[indexPath.row].chatId, status: true)
    
        performSegue(withIdentifier: "openChat", sender: indexPath)
    }
    
    func presentChat(_ index: Int){
        self.chatsArray = MessagesRepository.shared.getAllChatsFromDB()
        for (i, chat) in self.chatsArray.enumerated(){
            if chat.chatId == index{
            performSegue(withIdentifier: "openChat", sender: IndexPath(row: i, section: 0))
            return
            }
        }
    }
    
    //========================================
    // MARK: - @IBActions
    //========================================

    @IBAction func searchButtonPressed(_ sender: Any) {}
    

    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    //========================================
    // MARK: - navigation
    //========================================

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "openChat" {
            guard let indexPath = sender as? IndexPath else {return}
            let chat = self.chatsArray[indexPath.row]
            let chatVC = segue.destination as? ChatViewController
            chatVC?.currentChat = chat
        }
    }
}

extension MessagesViewController: MessagesRepositoryDelegate{
    func didSendMessage() {
        
    }
    
    func didReciveNewMessage() {
        self.setTableView()
       
    }
}


