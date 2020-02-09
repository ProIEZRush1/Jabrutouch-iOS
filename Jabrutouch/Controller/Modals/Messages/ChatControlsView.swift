//
//  ChatControllView.swift
//  Jabrutouch
//
//  Created by Shlomo Carmen on 12/12/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import UIKit
import AVFoundation

protocol ChatControlsViewDelegate: class {
    func sendMessageButtonPressed()
    func textViewChanged()
    func sendVoiceMessage()
}

class ChatControlsView: UIView {
    
    //========================================
    // MARK: - Properties
    //========================================
    var soundRecorder: AVAudioRecorder?
    var soundPlayer : AVAudioPlayer?
    var fileName: String = ""

    
    
    weak var delegate: ChatControlsViewDelegate?
    //========================================
    // MARK: - @IBOutlets
    //========================================
    
    @IBOutlet weak var inputTextViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var inputTextView:UITextView!
    @IBOutlet weak var plaseHolderLabel: UILabel!
    @IBOutlet weak var sendMessageButton: UIButton!
    @IBOutlet weak var recordMessageButton: UIButton!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var inputTextContainerView: UIView!
    
    //========================================
    // MARK: - LifeCycle
    //========================================
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.xibSetup()
        self.inputTextView.delegate = self
        
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
        self.inputTextContainerView.layer.cornerRadius = 22.5
        self.shadowView.layer.cornerRadius = 25
        
        
        self.shadowView.layer.borderColor = Colors.borderGray.cgColor
        self.shadowView.layer.borderWidth = 1.0
    }
    
    func createFileName(){
        let time = String(Date().timeIntervalSince1970 * 1000)
        let suffix = time.replacingOccurrences(of: ".", with: "_")
//        suffix += ".mp3"
        self.fileName = suffix
    }
    
    //========================================
    // MARK: - @IBActions
    //========================================
    
    @IBAction func sendMessageButtonPressed(_ sender: Any) {
        self.delegate?.sendMessageButtonPressed()
        self.inputTextView.text = ""
        self.plaseHolderLabel.isHidden = false
        self.sendMessageButton.isHidden = true
        self.recordMessageButton.isHidden = false
        
        
    }
    
    @IBAction func recordButtonPressed(_ sender: Any) {
        print("pressed recorder")
        self.createFileName()
        AudioMessagesManager.shared.startRecording(self.fileName)
    }
    
    @IBAction func recordButtonTouchedUp(_ sender: Any) {
        print("TouchedUp recorder")
        AudioMessagesManager.shared.stopRecoredr(self.fileName)
        self.delegate?.sendVoiceMessage()
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
            self.sendMessageButton.isHidden = true
            self.recordMessageButton.isHidden = false
        } else {
            self.plaseHolderLabel.isHidden = true
            self.recordMessageButton.isHidden = true
            self.sendMessageButton.isHidden = false
        }
    }
    
    
}


