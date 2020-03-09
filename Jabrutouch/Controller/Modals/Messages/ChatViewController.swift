//
//  ChatViewController.swift
//  Jabrutouch
//
//  Created by Shlomo Carmen on 10/12/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import UIKit
import AVFoundation
class PlayButton: UIButton{
    var indexPath: IndexPath?
    
}
enum MessageType: Int {
    case text  = 1
    case voice = 2
}

enum VoiceMessageType: String{
    case outgoing, incoming
    struct Images {
        let play: String, pause: String
    }
    var images: Images{
        switch self {
        case .outgoing:
            return Images(play: "playWhite", pause: "pause1")
        case .incoming:
            return Images(play: "play1", pause: "pause")
        }
    }
}

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    
    //========================================
    // MARK: - Properties
    //========================================
    enum LinkType {
        case crowns
        case download
        case gemara
        case mishna
    }
    
    enum MessageType: Int {
        case text  = 1
        case voice = 2
        case video = 3
        case image = 4
        case link = 5
    }
    
    
    var messagesArray: [[JTMessage]] = []
    var user: JTUser?
    var currentChat: JTChatMessage?
    var dates: [String]?
    var playingCellIndexPath: IndexPath? {
        didSet{
            guard let indexPath = oldValue else { return }
            if indexPath != playingCellIndexPath{
                let oldMessage = messagesArray[indexPath.section][indexPath.row]
                oldMessage.isPlay = false
                guard let cell = self.tableView.cellForRow(at: indexPath) as? UserRecorderCell else { return }
                DispatchQueue.main.async {
                    cell.playButton.setImage(UIImage(named: oldMessage.isMine
                        ? VoiceMessageType.outgoing.images.play
                        :VoiceMessageType.incoming.images.play), for: .normal)
                }
            }
        }
    }
    var selectedMessage:JTMessage?
    
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
        CoreDataManager.shared.setChatReadById(chatId: currentChat!.chatId, status: true)
        self.chatControlsView.delegate = self
        AudioMessagesManager.shared.delegate = self
        MessagesRepository.shared.getAllMessagesFromDB(chatId: currentChat!.chatId)
        (self.messagesArray, self.dates) = self.groupArrayByDate(messages: MessagesRepository.shared.messages)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.titleLabel.text = currentChat?.title
        self.roundCorners()
        self.user = UserRepository.shared.getCurrentUser()
        self.downloadRecorde(messages: MessagesRepository.shared.messages)
        UNUserNotificationCenter.current().removeAllDeliveredNotifications() // For removing all delivered notification
//        UNUserNotificationCenter.current().removeAllPendingNotificationRequests() // For removing all pending notifications which are not delivered yet but scheduled. 
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        CoreDataManager.shared.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    override func viewDidLayoutSubviews() {
        
        
        let (row, section) = currentPosition(position: currentChat?.unreadMessages)
        self.tableView.scrollToRow(at: IndexPath(row:row , section: section), at: UITableView.ScrollPosition.bottom, animated: false)
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
    
    private  func currentPosition(position: Int?)-> (Int, Int){
        if position != nil && position != 0 {
            var counter = 0
            var currentArray = self.messagesArray.count
            for arr in messagesArray.reversed(){
                currentArray -= 1
                var index = arr.count
                for i in arr.reversed(){
                    counter += 1
                    index -= 1
                    if counter == position{
                        return (index, currentArray)
                    }
                }
            }
        }
        return (self.messagesArray[self.messagesArray.count-1].count-1, self.messagesArray.count-1)
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
    
//    private func getViewWidth(_ text: String) -> CGFloat {
//        let label = UILabel()
//        label.font = Fonts.mediumTextFont(size: 18)
//        label.numberOfLines = 0
//        label.text = text
//        label.lineBreakMode = .byWordWrapping
//        let width = label.sizeThatFits(CGSize(width: 218, height: 600)).width
//        return width
//
//    }
    
    func getTime(lastMessageTime: Date)-> String {
        let timeStemp = lastMessageTime.timeIntervalSince1970
        let toDayAgain = Date(timeIntervalSince1970: timeStemp)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        let string = dateFormatter.string(from: toDayAgain)
        
        return string
        
    }
    
    func getDuration(_ url : String)->CMTime{
        let audioAsset = AVURLAsset.init(url: FilesManagementProvider.shared.loadFile(link: url, directory: FileDirectory.recorders) as URL, options: nil)
        let duration = audioAsset.duration
        return duration
    }
    
    
    func downloadRecorde(messages:[JTMessage]){
        for message in messages {
            if message.messageType == 2 {
                guard let baseUrl = FileDirectory.recorders.url?.absoluteString else { return }
                let fileUrl = "\(baseUrl)\(message.message)"
                let isExsist = FileManager.default.fileExists(atPath: URL.init(string: fileUrl)!.path )
                if !(isExsist){
                    let recordUrl = message.message.components(separatedBy: "/")
                    AWSS3Provider.shared.handleFileDownload(fileName: "users-record/\(recordUrl[recordUrl.count-1])", bucketName: AWSS3Provider.appS3BucketName, progressBlock: nil) {  (result) in
                        switch result{
                        case .success(let data):
                            do{
                                try FilesManagementProvider.shared.overwriteFile(
                                    path: FilesManagementProvider.shared.loadFile(link: "\(recordUrl[recordUrl.count-1])",
                                        directory: FileDirectory.recorders),
                                    data: data)
                            } catch {
                                print("error")
                            }
                        case .failure(let error):
                            print(error)
                        }
                    }
                }
            }
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
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
        
        var theCell: UITableViewCell?
        
        switch self.messagesArray[indexPath.section][indexPath.row].messageType {
        case MessageType.text.rawValue:
            if self.messagesArray[indexPath.section][indexPath.row].isMine{
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "userMessageCell", for: indexPath) as? UserMessageCell else { return UITableViewCell() }
                let text = self.messagesArray[indexPath.section][indexPath.row].message
                let height = self.getViewHeight(text)
                cell.messageViewHeightConstraint.constant = height + 32
                cell.message.text = text
                cell.messageTextView.textContainer.lineBreakMode = .byWordWrapping
                cell.messageTextView.text = text
                cell.timeLabel.text = self.getTime(lastMessageTime: messagesArray[indexPath.section][indexPath.row].sentDate)
                cell.userImage.image = #imageLiteral(resourceName: "Avatar")
                theCell = cell
                
            }else {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "incomingMessageCell", for: indexPath) as? IncomingMessageCell else { return UITableViewCell() }
                let text = self.messagesArray[indexPath.section][indexPath.row].message
                let height = self.getViewHeight(text)
                cell.messageViewHeightConstraint.constant = height + 32
                cell.message.text = text
                cell.messageTextView.textContainer.lineBreakMode = .byWordWrapping
                cell.messageTextView.text = text
                cell.timeLabel.text =  self.getTime(lastMessageTime: messagesArray[indexPath.section][indexPath.row].sentDate)
                if self.currentChat?.chatType == 1 {
                    cell.userImage.image = #imageLiteral(resourceName: "incomingUserImege")
                } else {
                    cell.userImage.image = #imageLiteral(resourceName: "JBlogo")
                }
                theCell = cell
            }
            
        case MessageType.voice.rawValue:
            if self.messagesArray[indexPath.section][indexPath.row].isMine{
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "userRecorderCell", for: indexPath) as? UserRecorderCell else { return UITableViewCell() }
                let message = self.messagesArray[indexPath.section][indexPath.row]
                cell.dateLable.text = self.getTime(lastMessageTime: messagesArray[indexPath.section][indexPath.row].sentDate)
                cell.playButton.indexPath = indexPath
                if message.isPlay{
                    cell.playButton.setImage(UIImage(named: VoiceMessageType.outgoing.images.pause), for: .normal)
                }else{
                    cell.playButton.setImage(UIImage(named: VoiceMessageType.outgoing.images.play), for: .normal)
                }
                cell.timeLabel.text = message.currentTime > 0
                    ? Utils.convertTimeintervalToHumanTime(TimeInterval(message.currentTime))
                    : self.getDuration(message.message).positionalTime
                cell.playButton.addTarget(self, action: #selector(self.playAudio(_:)), for: .touchUpInside)
                //                cell.slider.value = message.currentTime
                cell.slider.setValue(message.currentTime, animated: true)
                cell.slider.setThumbImage(#imageLiteral(resourceName: "newThumb"), for: .normal)
                if let image = Utils.linearGradientImage(endXPoint: 0.0, size: cell.slider.frame.size, colors: [Colors.appBlue, Colors.appOrange]) {
                    cell.slider.setMinimumTrackImage(image, for: .normal)
                }
                cell.userImage.image = #imageLiteral(resourceName: "Avatar")
                theCell = cell
                
            }else {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "incomingRecordCell", for: indexPath) as? UserRecorderCell else { return UITableViewCell() }
                let message = self.messagesArray[indexPath.section][indexPath.row]
                cell.dateLable.text = self.getTime(lastMessageTime: messagesArray[indexPath.section][indexPath.row].sentDate)
                cell.playButton.indexPath = indexPath
                if message.isPlay{
                    cell.playButton.setImage(UIImage(named: VoiceMessageType.incoming.images.pause), for: .normal)
                }else{
                    cell.playButton.setImage(UIImage(named: VoiceMessageType.incoming.images.play), for: .normal)
                }
                cell.timeLabel.text = message.currentTime > 0
                    ? Utils.convertTimeintervalToHumanTime(TimeInterval(message.currentTime))
                    : self.getDuration(message.message).positionalTime
                cell.playButton.addTarget(self, action: #selector(self.playAudio(_:)), for: .touchUpInside)
                cell.slider.value = message.currentTime
                cell.slider.setThumbImage(#imageLiteral(resourceName: "newThumb"), for: .normal)
                if let image = Utils.linearGradientImage(endXPoint: 0.0, size: cell.slider.frame.size, colors: [Colors.appBlue, Colors.appOrange]) {
                    cell.slider.setMinimumTrackImage(image, for: .normal)
                }
                cell.slider.setValue(message.currentTime, animated: true)
                if self.currentChat?.chatType == 1 {
                    cell.userImage.image = #imageLiteral(resourceName: "incomingUserImege")
                } else {
                    cell.userImage.image = #imageLiteral(resourceName: "JBlogo")
                }
                theCell = cell
                
            }
        case MessageType.link.rawValue:
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "incomingMessageCell", for: indexPath) as? IncomingMessageCell else { return UITableViewCell() }
            let text = self.messagesArray[indexPath.section][indexPath.row].message
            let height = self.getViewHeight(text)
            cell.messageViewHeightConstraint.constant = height + 40
            var link = ""
            switch self.messagesArray[indexPath.section][indexPath.row].linkTo {
            case 1:
                link = "crowns"
            case 2:
                link = "download"
            case 3:
                link = "gemara"
            case 4:
                link = "mishna"
            default:
                break
            }
            let attributedString = NSMutableAttributedString(string: text, attributes: [NSAttributedString.Key.link: "jabrutouch://\(link)", NSAttributedString.Key.foregroundColor: UIColor.blue,NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue, NSAttributedString.Key.font: Fonts.mediumTextFont(size: 16)])

            cell.message.text = text
//            cell.messageTextView.textContainer.lineBreakMode = .byWordWrapping
            cell.messageTextView.attributedText = attributedString

            cell.timeLabel.text =  self.getTime(lastMessageTime: messagesArray[indexPath.section][indexPath.row].sentDate)
            if self.currentChat?.chatType == 1 {
                cell.userImage.image = #imageLiteral(resourceName: "incomingUserImege")
            } else {
                cell.userImage.image = #imageLiteral(resourceName: "JBlogo")
            }
            theCell = cell
        default:
            print("empty")
        }
        
        return theCell!
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let text = self.messagesArray[indexPath.section][indexPath.row].message
        let height = self.getViewHeight(text)
        return height + 90
        
    }
    
    
    
    //========================================
    // MARK: - @IBActions
    //========================================
    
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        
    }
    
    @objc func playAudio(_ sender: PlayButton) {
        guard let indexPath = sender.indexPath else { return }
        self.playingCellIndexPath = sender.indexPath
        self.selectedMessage = self.messagesArray[indexPath.section][indexPath.row]
        self.selectedMessage?.isPlay.toggle()
        guard let message = self.selectedMessage else { return }
        guard let cell = self.tableView.cellForRow(at: indexPath) as? UserRecorderCell else { return }
        if  message.isPlay{
            self.playMusic(cell, message)
        }else{
            self.playingCellIndexPath = nil
            self.stopMusic(cell, message)
        }
    }
    
    
    
    func playMusic(_ cell:UserRecorderCell, _ message: JTMessage){
        AudioMessagesManager.shared.startPlayer(message.message)
        AudioMessagesManager.shared.setCurrentTime(message.currentTime)
        DispatchQueue.main.async {
            cell.playButton.setImage(UIImage(named: message.isMine
                ? VoiceMessageType.outgoing.images.pause
                :VoiceMessageType.incoming.images.pause), for: .normal)
        }
    }
    
    func stopMusic(_ cell:UserRecorderCell, _ message: JTMessage){
        message.isPlay = false
        AudioMessagesManager.shared.stopPlayer()
        DispatchQueue.main.async {
            cell.playButton.setImage(UIImage(named: message.isMine
                ? VoiceMessageType.outgoing.images.play
                :VoiceMessageType.incoming.images.play), for: .normal)
        }
    }
    
}

extension CMTime {
    var roundedSeconds: TimeInterval {
        return seconds.rounded()
    }
    var hours:  Int { return Int(roundedSeconds / 3600) }
    var minute: Int { return Int(roundedSeconds.truncatingRemainder(dividingBy: 3600) / 60) }
    var second: Int { return Int(roundedSeconds.truncatingRemainder(dividingBy: 60)) }
    var positionalTime: String {
        return hours > 0 ?
            String(format: "%d:%02d:%02d",
                   hours, minute, second) :
            String(format: "%02d:%02d",
                   minute, second)
    }
}
extension ChatViewController: AudioMessagesManagerDelegate{
    
    func currentTimeChanged(currentTime: TimeInterval) {
        self.selectedMessage?.currentTime = Float(currentTime)
        guard let indexPath = self.playingCellIndexPath, let message = self.selectedMessage else {
            return
        }
        DispatchQueue.main.async {
            guard let cell = self.tableView.cellForRow(at: indexPath) as? UserRecorderCell else {return}
            cell.timeLabel.text = message.currentTime > 0
                ? Utils.convertTimeintervalToHumanTime(TimeInterval(message.currentTime))
                : self.getDuration(message.message).positionalTime
            cell.slider.maximumValue = Float(self.getDuration(message.message).roundedSeconds)
            cell.slider.setValue(message.currentTime, animated: true)
            cell.slider.setThumbImage(#imageLiteral(resourceName: "newThumb"), for: .normal)
            if let image = Utils.linearGradientImage(endXPoint: 0.0, size: cell.slider.frame.size, colors: [Colors.appBlue, Colors.appOrange]) {
                cell.slider.setMinimumTrackImage(image, for: .normal)
                
            }
        }
        
    }
    
    
    func playerDidFinish() {
        self.selectedMessage?.isPlay = false
        self.selectedMessage?.currentTime = 0.0
        DispatchQueue.main.async {
            guard let indexPath = self.playingCellIndexPath else { return }
            guard let cell = self.tableView.cellForRow(at: indexPath) as? UserRecorderCell else { return }
            cell.playButton.setImage(UIImage(named: self.messagesArray[indexPath.section][indexPath.row].isMine
                ? VoiceMessageType.outgoing.images.play
                :VoiceMessageType.incoming.images.play), for: .normal)
        }
        self.playingCellIndexPath = nil
    }
    
    
}

extension ChatViewController: ChatControlsViewDelegate, MessagesRepositoryDelegate {
    
    
    func textViewChanged() {}
    
    func recordSavedInS3(_ fileName: String) {
        self.sendMessage(fileName, MessageType.voice)
    }
    
    func sendVoiceMessageButtonTouchUp(_ fileName: String) {
        self.createMessage(fileName, MessageType.voice)
    }
    
    func sendTextMessageButtonPressed() {
        if let text = self.chatControlsView.inputTextView.text {
            self.createMessage(text, MessageType.text)
            self.sendMessage(text, MessageType.text)
        }
    }
    
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
    
    func sendMessage(_ text: String, _ type: MessageType){
        guard let chat = self.currentChat else{return}
        let toUser = chat.fromUser == UserRepository.shared.getCurrentUser()?.id ?chat.toUser : chat.fromUser
        MessagesRepository.shared.sendMessage(
            message: text,
            sentAt: Date(),
            title: chat.title,
            messageType: type.rawValue,
            toUser: toUser,
            chatId: chat.chatId,
            lessonId: chat.lessonId,
            gemara: chat.gemara,
            linkTo: nil,
            completion:  { (resulte) in
                print("")
        })
    }
    
    func createMessage(_ text: String, _ type: MessageType){
        guard let chat = self.currentChat else{return}
        if let createMessage = JTMessage(values: [
            "message": text,
            "sent_at": Date().timeIntervalSince1970 * 1000 ,
            "title": chat.title,
            "message_type": type.rawValue,
            "from_user": self.user?.id ?? chat.toUser,
            "to_user": chat.fromUser,
            "read": true,
            "is_mine": true,
            "chat_id": chat.chatId]){
            MessagesRepository.shared.saveMessageInDB(message: createMessage)
        }
    }
    
    
    
}




