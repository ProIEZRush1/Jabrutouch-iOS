//בס״ד
//  MainCollectionCellViewController.swift
//  Jabrutouch
//
//  Created by Aaron Tuil on 07/08/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import UIKit

class MainCollectionCellViewController: UICollectionViewCell {
    
    @IBOutlet weak var mainProgressBar: JBProgressBar!
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var masechetLabel: UILabel!
    @IBOutlet weak var chapterLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var audio: UIImageView!
    @IBOutlet weak var video: UIImageView!
    @IBOutlet weak var audioButton: UIButton!
    @IBOutlet weak var videoButton: UIButton!
    
    var isFirstCollection: Bool = true // When two collections are used in single screen
    var selectedRow: Int = 0
    weak var delegate: MainCollectionCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        let cellGestureRecognizer = (UITapGestureRecognizer(target: self, action: #selector(cellPressed)))
        cellView.addGestureRecognizer(cellGestureRecognizer)
        let audioGestureRecognizer = (UITapGestureRecognizer(target: self, action: #selector(audioPressed)))
        audioButton.addGestureRecognizer(audioGestureRecognizer)
        let videoGestureRecognizer = (UITapGestureRecognizer(target: self, action: #selector(videoPressed)))
        videoButton.addGestureRecognizer(videoGestureRecognizer)
        
        self.setButtonsBackground()
    }
    
    func setButtonsBackground() {
        self.audioButton.setImage(#imageLiteral(resourceName: "audio-nat"), for: .normal)
        self.audioButton.setImage(#imageLiteral(resourceName: "audio-prs"), for: .highlighted)
        
        self.videoButton.setImage(#imageLiteral(resourceName: "video-nat"), for: .normal)
        self.videoButton.setImage(#imageLiteral(resourceName: "video-prs"), for: .highlighted)

    }
    
    @objc private func cellPressed() {
        delegate?.cellPressed(selectedRow: selectedRow, isFirstCollection: isFirstCollection)
    }
    
    @objc private func audioPressed() {
        delegate?.audioPressed(selectedRow: selectedRow, isFirstCollection: isFirstCollection)
    }
    
    @objc private func videoPressed() {
        delegate?.videoPressed(selectedRow: selectedRow, isFirstCollection: isFirstCollection)
    }
    
    func setHiddenButtonsForLesson(_ lesson: JTLesson) {
       self.audioButton.isHidden = (lesson.audioURL == nil)
       self.videoButton.isHidden = (lesson.videoURL == nil)
    }
}

protocol MainCollectionCellDelegate: class {
    func cellPressed(selectedRow: Int, isFirstCollection: Bool)
    func audioPressed(selectedRow: Int, isFirstCollection: Bool)
    func videoPressed(selectedRow: Int, isFirstCollection: Bool)
}
