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
    @IBOutlet weak var cellViewShadowView: UIView!
    @IBOutlet weak var mishnaOrGemaraLabel: UILabel!
    /// One collectionView used for gemara & mishna history, Set true if lesson is gemara.
    var isGemara: Bool = true
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
        delegate?.cellPressed(selectedRow: selectedRow, isGemara: isGemara)
    }
    
    @objc private func audioPressed() {
        delegate?.audioPressed(selectedRow: selectedRow, isGemara: isGemara)
    }
    
    @objc private func videoPressed() {
        delegate?.videoPressed(selectedRow: selectedRow, isGemara: isGemara)
    }
    
    func setHiddenButtonsForLesson(_ lesson: JTLesson) {
        
            self.audioButton.isHidden = !lesson.isAudioDownloaded ? (lesson.audioURL == nil || !appDelegate.isInternetConenect) : (lesson.audioURL == nil)

        
            self.videoButton.isHidden = !lesson.isVideoDownloaded ? (lesson.videoURL == nil || !appDelegate.isInternetConenect) : (lesson.videoURL == nil)
    }
}

protocol MainCollectionCellDelegate: class {
    func cellPressed(selectedRow: Int, isGemara: Bool)
    func audioPressed(selectedRow: Int, isGemara: Bool)
    func videoPressed(selectedRow: Int, isGemara: Bool)
}
