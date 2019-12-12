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
//    var messagesArray: [JTChatMessage] = []
    let timeFormatter = DateFormatter()
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.setTableView()
        
    }
    
    //========================================
    // MARK: - Setup
    //========================================
    
    func setTableView() {
        if self.messagesArray.count > 0 {
            self.noMessagesImage.isHidden = true
            self.noMessagesLabel.isHidden = true
        } else {
            self.tableView.isHidden = true
        }
    }
    
    func getTime()-> String {
        let toDay = Date()
        // Convert Date to timeStemp
        let timeStemp = toDay.timeIntervalSince1970
        // Convert timeStemp to Date
        let toDayAgain = Date(timeIntervalSince1970: timeStemp)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        let string = dateFormatter.string(from: toDayAgain)
        
        return string

    }
    
    //========================================
    // MARK: - Table Views
    //========================================
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messagesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "chatCell", for: indexPath) as? ChatCell else { return UITableViewCell() }
        cell.timeLabel.text = self.getTime()
        cell.groupName.text = "Jabrutouch Team"
        cell.message.text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "openChat", sender: self)
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
//            let chatVC = segue.destination as? ChatViewController
//            chatVC?.titleLabel.text = "test"
           
        }
    }

}
