//
//  ChatViewController.swift
//  Jabrutouch
//
//  Created by Shlomo Carmen on 10/12/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import UIKit
import AVFoundation

class ChatViewController: UIViewController {
    
    //========================================
    // MARK: - Properties
    //========================================
    
    var soundRecorder = AVAudioRecorder()
    var soundPlayer = AVAudioPlayer()
    var fileName: String = "audioFile.m4a"
    //========================================
    // MARK: - @IBOutlets
    //========================================
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var sendMessageContainerView: UIView!
    @IBOutlet weak var sendMessageBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var sendMessageButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var recordMessageButton: UIButton!
    
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var textFieldContainer: UIView!
    
    //========================================
    // MARK: - LifeCycle
    //========================================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.playButton.isEnabled = false
        self.textField.delegate = self
        //        self.sendMessageButton.setImage(#imageLiteral(resourceName: "mic"), for: .normal)
        self.roundCorners()
        self.setUpRecord()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    @objc func keyboardWillShow(_ notification: NSNotification) {
        if let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            print(keyboardRect.height)
            self.sendMessageBottomConstraint.constant = -keyboardRect.height
        }
    }
    
    //========================================
    // MARK: - Setup
    //========================================
    
    
    private func roundCorners() {
        self.textFieldContainer.layer.cornerRadius = self.textFieldContainer.bounds.height/2
        self.shadowView.layer.cornerRadius = self.shadowView.bounds.height/2
        self.textField.layer.cornerRadius = self.textField.bounds.height/2
        
        self.shadowView.layer.borderColor = Colors.borderGray.cgColor
        self.shadowView.layer.borderWidth = 1.0
    }
    //========================================
    // MARK: - collection View
    //========================================
    
    
    //========================================
    // MARK: - @IBActions
    //========================================
    
    @IBAction func sendMessageButtonPressed(_ sender: Any) {
        self.sendMessage()
    }
    @IBAction func playButtonPressed(_ sender: Any) {
        self.setUpPlayer()
        self.soundPlayer.play()
    }
    
    @IBAction func recordButtonPressed(_ sender: Any) {
        self.soundRecorder.record()
    }
    
    @IBAction func recordButtonTouchedUp(_ sender: Any) {
        self.soundRecorder.stop()
    }
    
    @IBAction func recordButtonDragLeft(_ sender: Any) {
    }
    
    @IBAction func textFieldChanged(_ sender: Any) {
        if textField.text?.isEmpty ?? true {
            self.sendMessageButton.isHidden = true
            self.recordMessageButton.isHidden = false
            //            self.sendMessageButton.setImage(#imageLiteral(resourceName: "mic"), for: .normal)
        } else {
            self.recordMessageButton.isHidden = true
            self.sendMessageButton.isHidden = false
            self.sendMessageButton.setImage(#imageLiteral(resourceName: "Paper Airplane"), for: .normal)
        }
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func sendMessage(){
        
    }
}

extension ChatViewController: AVAudioPlayerDelegate, AVAudioRecorderDelegate {
    
    func setUpRecord() {
        let recordSettings = [AVFormatIDKey: kAudioFormatAppleLossless,
                              AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue,
                              AVEncoderBitRateKey: 320000,
                              AVNumberOfChannelsKey: 2,
                              AVSampleRateKey: 44100.0 ] as [String : Any]
        
//        let error: NSError?
        let url = getDocumentDirectory().appendingPathComponent(fileName)
        do {
            self.soundRecorder = try AVAudioRecorder(url: url, settings: recordSettings)
            self.soundRecorder.delegate = self
            self.soundRecorder.prepareToRecord()
        }
        catch {
            print(error)
        }
    }
    
    func setUpPlayer() {
        let url = getDocumentDirectory().appendingPathComponent(fileName)
        do {
            self.soundPlayer = try AVAudioPlayer(contentsOf: url)
            self.soundPlayer.delegate = self
            self.soundPlayer.prepareToPlay()
            self.soundPlayer.volume = 1.0
            
        }
        catch {
            print(error)
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        self.playButton.isEnabled = true
    }
    
    func getDocumentDirectory()-> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}

extension ChatViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.textField.resignFirstResponder()
        self.sendMessageBottomConstraint.constant = 0
        return true
    }
}
