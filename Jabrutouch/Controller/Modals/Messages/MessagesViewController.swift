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
        self.chatsArray = MessagesRepository.shared.allChats
        MessagesRepository.shared.delegate = self
        
    }
    
//    func printer(arr:[JTChatMessage]){
//        for (i, item) in arr.enumerated(){
//            print(i,": ", item.lastMessageTime)
//        }
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.setTableView()
        
    }
    
   
    //========================================
    // MARK: - Setup
    //========================================
    
    func setTableView() {
        if self.chatsArray.count > 0 {
            self.noMessagesImage.isHidden = true
            self.noMessagesLabel.isHidden = true
        } else {
            self.tableView.isHidden = true
            self.searchButton.isHidden =  true
        }
        self.tableView.reloadData()
    }
    
    func getTime(lastMessageTime: Date)-> String {

        let timeStemp = lastMessageTime.timeIntervalSince1970
        let toDayAgain = Date(timeIntervalSince1970: timeStemp)
        let dateFormatter = DateFormatter()
        if self.checkDiffDate(day: toDayAgain) > 1 {
            dateFormatter.dateFormat = "MMM d"
            
        } else if self.checkDiffDate(day: toDayAgain) == 1{
            return "Yesterday"
        } else {
            dateFormatter.dateFormat = "HH:mm"
        }
        let string = dateFormatter.string(from: toDayAgain)
        
        return string

    }
    
    func checkDiffDate(day: Date) -> Int{
        
        let toDay = Date()
        let diff = Calendar.current.dateComponents([.day], from: day, to: toDay)
        return diff.day ?? 0
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

        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chatId = self.chatsArray[indexPath.row].chatId
        performSegue(withIdentifier: "openChat", sender: chatId)
    }
    
    
    //========================================
    // MARK: - @IBActions
    //========================================

    @IBAction func searchButtonPressed(_ sender: Any) {
        
    }
    

    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    //========================================
    // MARK: - navigation
    //========================================

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "openChat" {
            MessagesRepository.shared.getAllMessagesFromDB(chatId: sender as? Int ?? 0)
            
            let chatVC = segue.destination as? ChatViewController
            chatVC?.messagesArray = MessagesRepository.shared.messages
           
        }
    }

}

extension MessagesViewController: MessagesRepositoryDelegate {
    func didReciveNewMessage(allChats: [JTChatMessage]) {
        self.chatsArray = allChats
        self.tableView.reloadData()
    }
    
    
    
}
