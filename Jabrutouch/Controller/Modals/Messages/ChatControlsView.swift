//
//  ChatControllView.swift
//  Jabrutouch
//
//  Created by Shlomo Carmen on 12/12/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import UIKit
import AVFoundation
import iRecordView

protocol ChatControlsViewDelegate: class {
    func sendTextMessageButtonPressed()
    func textViewChanged()
    func sendVoiceMessageButtonTouchUp(_ fileName: String)
    func recordSavedInS3(_ fileName: String)
}

class ChatControlsView: UIView, RecordViewDelegate {
    
    
    //========================================
    // MARK: - Properties
    //========================================
    var soundRecorder: AVAudioRecorder?
    var soundPlayer : AVAudioPlayer?
    var fileName: String = ""
    
    let recordView = RecordView()
    
    weak var delegate: ChatControlsViewDelegate?
    //========================================
    // MARK: - @IBOutlets
    //========================================
    
//    @IBOutlet weak var inputTextViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var inputTextView:UITextView!
    @IBOutlet weak var plaseHolderLabel: UILabel!
    @IBOutlet weak var sendMessageButton: UIButton!
    @IBOutlet weak var recordMessageButton: RecordButton!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var inputTextContainerView: UIView!
    
    //========================================
    // MARK: - LifeCycle
    //========================================
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.xibSetup()
        self.inputTextView.delegate = self
        
        recordView.delegate = self
        
        
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
        recordMessageButton.translatesAutoresizingMaskIntoConstraints = false
        recordView.translatesAutoresizingMaskIntoConstraints = false
        // use bounds not frame or it'll be offset
        self.view.frame = bounds
        
        // Make the view stretch with containing view
        self.view.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
        
        view.addSubview(recordView)
        
//                recordMessageButton.widthAnchor.constraint(equalToConstant: 35).isActive = true
//                recordMessageButton.heightAnchor.constraint(equalToConstant: 35).isActive = true
//        
//                recordMessageButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8).isActive = true
//                recordMessageButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16).isActive = true
        
        
        recordView.trailingAnchor.constraint(equalTo: recordMessageButton.leadingAnchor, constant: -40).isActive = true
        recordView.leadingAnchor.constraint(equalTo: inputTextView.leadingAnchor, constant: 5).isActive = true
        recordView.centerYAnchor.constraint(equalTo:inputTextView.centerYAnchor).isActive = true
        
        recordView.offset = 20
        recordView.durationTimerColor = #colorLiteral(red: 0.1764705882, green: 0.168627451, blue: 0.662745098, alpha: 1)
        recordView.slideToCancelTextColor = #colorLiteral(red: 0.6039215686, green: 0.6039215686, blue: 0.6039215686, alpha: 1)
//        recordView.slideToCancelArrowImage = #imageLiteral(resourceName: "leftGrayArrow")
        recordView.clipsToBounds = false
        
        recordMessageButton.recordView = recordView
        
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
        self.fileName = suffix
    }
    
    func saveRecordInS3(url: URL, fileName: String, completion: @escaping (Result<Void,Error>)->Void) {
        AWSS3Provider.shared.handleFileUpload(
            fileUrl: url, fileName: fileName,
            contentType: "audio/mp3",
            bucketName: AWSS3Provider.appS3BucketName,
            progressBlock: { (progress) in
//                print(progress)
        }) { (result:Result<String, Error>) in
            switch result {
            case .success(_):
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    //========================================
    // MARK: - @IBActions
    //========================================
    
    @IBAction func sendMessageButtonPressed(_ sender: Any) {
        self.delegate?.sendTextMessageButtonPressed()
        self.inputTextView.isHidden = false
        self.inputTextView.text = ""
        self.plaseHolderLabel.isHidden = false
        self.sendMessageButton.isHidden = true
        self.recordMessageButton.isHidden = false
        
    }
    
    func onStart() {
        self.plaseHolderLabel.isHidden = true
        self.inputTextView.isHidden = true
        self.createFileName()
        AudioMessagesManager.shared.startRecording(self.fileName)
    }
    
    func onCancel() {
        AudioMessagesManager.shared.stopRecoredr(self.fileName)
        let file = "\(self.fileName).mp3"
        let url = FilesManagementProvider.shared.loadFile(link: file, directory: FileDirectory.recorders)
        do{
            try FilesManagementProvider.shared.removeFile(atPath: url)
            print("The record deleted")
        }catch{
            print("The record didn't deleted.")
        }
    }
    
    func onFinished(duration: CGFloat) {
        if duration < 1.0 {
            self.onCancel()
        }else{
            AudioMessagesManager.shared.stopRecoredr(self.fileName)
            let file = "\(self.fileName).mp3"
            let url = FilesManagementProvider.shared.loadFile(link: file, directory: FileDirectory.recorders)
            self.delegate?.sendVoiceMessageButtonTouchUp(file)
            self.saveRecordInS3(url: url, fileName: "users-record/\(file)" , completion:{ (result: Result<Void, Error>) in
                switch result{
                case .success(let data):
//                    self.delegate?.recordSavedInS3(file)
                    self.delegate?.recordSavedInS3("/users-record/\(file)")
                    print(data)
                case .failure(let error):
                    print(error)
                }
            })
        }
        self.plaseHolderLabel.isHidden = false
        self.inputTextView.isHidden = false
    }
    
    func onAnimationEnd() {
        self.plaseHolderLabel.isHidden = false
        self.inputTextView.isHidden = false
    }
    
    
}

extension ChatControlsView: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
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


