//
//  ChatControllView.swift
//  Jabrutouch
//
//  Created by Shlomo Carmen on 12/12/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import UIKit
import AVFoundation

class ChatControlsView: UIView {
    
    //========================================
    // MARK: - Properties
    //========================================
    
    var soundRecorder = AVAudioRecorder()
    var soundPlayer = AVAudioPlayer()
    var fileName: String = "audioFile.m4a"
    
    //========================================
    // MARK: - @IBOutlets
    //========================================
    
    @IBOutlet weak var inputTextView:UITextView!
    @IBOutlet weak var plaseHolderLabel: UILabel!
    @IBOutlet weak var sendMessageButton: UIButton!
    @IBOutlet weak var recordMessageButton: UIButton!
    @IBOutlet weak var shadowView: UIView!
    
    //========================================
    // MARK: - LifeCycle
    //========================================
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.xibSetup()
        self.inputTextView.delegate = self
        self.setUpRecord()
        self.setRoundCorners()
    }
    
    override func awakeFromNib() {
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.xibSetup()
    }
    
    // Our custom view from the XIB file
    var view: UIView!
    
    func xibSetup() {
        self.view = loadViewFromNib()
        
        // use bounds not frame or it'll be offset
        self.view.frame = bounds
        
        // Make the view stretch with containing view
        self.view.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
        
        // Adding custom subview on top of our view (over any custom drawing > see note below)
        self.addSubview(view)
        self.backgroundColor = .clear
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib:UINib = UINib(nibName: "ChatControls", bundle: bundle)
        
        // Assumes UIView is top level and only object in CustomView.xib file
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
    
    
    //========================================
    // MARK: - Setup
    //========================================
    
    func setRoundCorners() {
        self.inputTextView.layer.cornerRadius = 22.5
        self.shadowView.layer.cornerRadius = 25
        
        
        self.shadowView.layer.borderColor = Colors.borderGray.cgColor
        self.shadowView.layer.borderWidth = 1.0
    }
    
    //========================================
    // MARK: - @IBActions
    //========================================
    
    @IBAction func sendMessageButtonPressed(_ sender: Any) {
        
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
    
}

extension ChatControlsView: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
//        self.setHeightOfTextView(text: "\(textView.text ?? "")\(text)")
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if inputTextView.text.isEmpty {
            self.plaseHolderLabel.isHidden = false
        } else {
            self.plaseHolderLabel.isHidden = true
        }
    }
    
    func refreshTextField() {
        self.plaseHolderLabel.isHidden = false
        self.inputTextView.text = ""
        self.setHeightOfTextView(text: "")
    }
    
    func setHeightOfTextView(text: String){
        let demoTextView = UITextView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: UIScreen.main.bounds.width - 122, height: 66)))
        demoTextView.font = UIFont.systemFont(ofSize: 15)
        demoTextView.text = text
        let viewSize = demoTextView.sizeThatFits(CGSize(width: UIScreen.main.bounds.width - 122, height: 50))
        
        self.view.layoutIfNeeded()
        self.inputTextView.updateConstraints()
        self.view.layoutIfNeeded()
    }
    
}

extension ChatControlsView: AVAudioPlayerDelegate, AVAudioRecorderDelegate {
    
    func setUpRecord() {
        let recordSettings = [AVFormatIDKey: kAudioFormatAppleLossless,
                              AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue,
                              AVEncoderBitRateKey: 320000,
                              AVNumberOfChannelsKey: 2,
                              AVSampleRateKey: 44100.0 ] as [String : Any]
        
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
        //        self.playButton.isHidden = false
        //        self.playButton.isEnabled = true
    }
    
    func getDocumentDirectory()-> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}

