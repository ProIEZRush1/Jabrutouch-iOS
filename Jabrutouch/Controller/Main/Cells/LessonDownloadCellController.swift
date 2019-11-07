//בס״ד
//  MishnaLessonCellController.swift
//  Jabrutouch
//
//  Created by Aaron Tuil on 01/08/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import UIKit
import UICircularProgressRing

class LessonDownloadCellController: UITableViewCell {
    
    //=====================================================
    // MARK: - @IBOutlets
    //=====================================================
    
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var downloadButtonsContainerView: UIView!
    @IBOutlet weak var lessonNumber: UILabel!
    @IBOutlet weak var lessonLength: UILabel!
    @IBOutlet weak var downloadProgressView: UICircularProgressRing!
    @IBOutlet weak var audioImage: UIImageView!
    @IBOutlet weak var videoImage: UIImageView!
    @IBOutlet weak var redAudioVImage: UIImageView!
    @IBOutlet weak var redVideoVImage: UIImageView!
    @IBOutlet weak var playAudioButton: UIButton!
    @IBOutlet weak var playVideoButton: UIButton!
    @IBOutlet weak var downloadAudioButton: UIButton!
    @IBOutlet weak var downloadVideoButton: UIButton!
    @IBOutlet weak var downloadAudioButtonImageView: UIImageView!
    @IBOutlet weak var downloadVideoButtonImageView: UIImageView!
    @IBOutlet weak var cellViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var cellViewLeadingConstraint: NSLayoutConstraint!
    
    //=====================================================
    // MARK: - Properties
    //=====================================================
    var selectedRow: Int = 0
    weak var delegate: MishnaLessonCellDelegate?
    
    //=====================================================
    // MARK: - LifeCycle
    //=====================================================
   
    override func awakeFromNib() {
        super.awakeFromNib()
        let cellGestureRecognizer = (UITapGestureRecognizer(target: self, action: #selector(cellPressed)))
        cellView.addGestureRecognizer(cellGestureRecognizer)
    }
    
    //=====================================================
    // MARK: - Setup
    //=====================================================
    func setLesson(_ lesson: JTLesson) {
        self.setHiddenButtonsForLesson(lesson)
//        self.setImagesForLesson(lesson)
        self.setDownloadModeForLesson(lesson)
        self.setButtonBackground(lesson)
        self.downloadButtonsContainerView.layoutIfNeeded()
        self.cellView.layoutIfNeeded()
    }
    
    func setEditingIfNeeded(lesson: JTLesson, isCurrentlyEditing: Bool) {
        self.animateImagesVisibilityIfNeeded(lesson, isCurrentlyEditing: isCurrentlyEditing)
        UIView.animate(withDuration: 0.6) {
            let isDownloading = lesson.isDownloadingAudio || lesson.isDownloadingVideo

            if isCurrentlyEditing && !isDownloading {
                self.cellViewTrailingConstraint.constant = UIScreen.main.bounds.size.width / 2 - 20
            } else {
                self.cellViewTrailingConstraint.constant = 18
            }
            self.layoutIfNeeded()

            
        }

    }
    private func animateImagesVisibilityIfNeeded(_ lesson: JTLesson, isCurrentlyEditing: Bool) {
        if (self.audioImage.isHidden) == !isCurrentlyEditing { // Animate only when a change occurred
            UIView.animate(withDuration: 0.2, delay: isCurrentlyEditing ? 0 : 0.1, animations: {
                if lesson.isAudioDownloaded  { // Animate only when suppose to be visible
                    self.redAudioVImage.isHidden = isCurrentlyEditing ? true : false
                }
                if lesson.isVideoDownloaded {
                    self.redVideoVImage.isHidden = isCurrentlyEditing ? true : false
                }
                self.audioImage.isHidden = isCurrentlyEditing ? true : false
                self.videoImage.isHidden = isCurrentlyEditing ? true : false
                self.playAudioButton.isHidden = isCurrentlyEditing ? true : false
                self.playVideoButton.isHidden = isCurrentlyEditing ? true : false
            })
        }
    }
    
    private func setHiddenButtonsForLesson(_ lesson: JTLesson) {
        self.playAudioButton.isHidden = (lesson.audioURL == nil)
        self.playVideoButton.isHidden = (lesson.videoURL == nil)
        self.audioImage.isHidden = (lesson.audioURL == nil)
        self.videoImage.isHidden = (lesson.videoURL == nil)
        
        self.downloadAudioButton.isHidden = (lesson.audioURL == nil)
        self.downloadVideoButton.isHidden = (lesson.videoURL == nil)
        self.downloadAudioButtonImageView.isHidden = (lesson.audioURL == nil)
        self.downloadVideoButtonImageView.isHidden = (lesson.videoURL == nil)
    }
    
    private func setDownloadModeForLesson(_ lesson: JTLesson) {
        let progress = lesson.audioDownloadProgress ?? lesson.videoDownloadProgress ?? 0.0
        let isDownloading = lesson.isDownloadingAudio || lesson.isDownloadingVideo
        self.downloadProgressView.value = CGFloat(progress*100)
       
        self.downloadProgressView.isHidden = !isDownloading
        self.downloadAudioButton.isEnabled = !isDownloading
        self.downloadVideoButton.isEnabled = !isDownloading
        
        self.downloadAudioButtonImageView.alpha = lesson.isDownloadingAudio ? 0.3 : 1.0
        self.downloadVideoButtonImageView.alpha = lesson.isDownloadingVideo ? 0.3 : 1.0
    }
    
    func setButtonBackground(_ lesson: JTLesson){
        if lesson.isAudioDownloaded {
            self.playAudioButton.setImage(#imageLiteral(resourceName: "audio-downloaded"), for: .normal)
            self.playAudioButton.setImage(#imageLiteral(resourceName: "audio-downloaded"), for: .highlighted)
             
        } else {
            self.playAudioButton.setImage(#imageLiteral(resourceName: "audio-nat"), for: .normal)
            self.playAudioButton.setImage(#imageLiteral(resourceName: "audio-prs"), for: .highlighted)
        }
        self.downloadAudioButtonImageView.isHidden = lesson.isAudioDownloaded
        
        if lesson.isVideoDownloaded {
            self.playVideoButton.setImage(#imageLiteral(resourceName: "video-downloaded"), for: .normal)
            self.playVideoButton.setImage(#imageLiteral(resourceName: "video-downloaded"), for: .highlighted)
    
        } else {
            self.playVideoButton.setImage(#imageLiteral(resourceName: "video-nat"), for: .normal)
            self.playVideoButton.setImage(#imageLiteral(resourceName: "video-prs"), for: .highlighted)
            
        }
        self.downloadVideoButtonImageView.isHidden = lesson.isVideoDownloaded

    }
    
    private func setImagesForLesson(_ lesson: JTLesson) {
        if lesson.isAudioDownloaded {
            self.audioImage?.image = UIImage(named: "RedAudio")
            self.redAudioVImage.isHidden = false
        } else {
            self.audioImage?.image = UIImage(named: "Audio")
            self.redAudioVImage.isHidden = true
        }
        
        self.downloadAudioButtonImageView.isHidden = lesson.isAudioDownloaded
        
        if lesson.isVideoDownloaded {
            self.videoImage?.image = UIImage(named: "RedVideo")
            self.redVideoVImage.isHidden = false
        } else {
            self.videoImage?.image = UIImage(named: "Video")
            self.redVideoVImage.isHidden = true
        }
        
        self.downloadVideoButtonImageView.isHidden = lesson.isVideoDownloaded
    }
    
    
    //=====================================================
    // MARK: - @IBActions
    //=====================================================
    
    @objc private func cellPressed() {
        delegate?.cellPressed(selectedRow: selectedRow)
        delegate?.playVideoPressed(selectedRow: selectedRow)

    }
    
    @IBAction func playAudioButtonPressed(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3) {
            self.audioImage.alpha = 1.0
        }
        delegate?.playAudioPressed(selectedRow: selectedRow)
    }
    
    @IBAction func playVideoButtonPressed(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3) {
            self.videoImage.alpha = 1.0
        }
        delegate?.playVideoPressed(selectedRow: selectedRow)
    }
    
    @IBAction func downloadAudioButtonPressed(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3) {
            self.downloadAudioButtonImageView.alpha = 1.0
        }
        delegate?.downloadAudioPressed(selectedRow: selectedRow)
    }
    
    @IBAction func downloadVideoButtonPressed(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3) {
            self.downloadVideoButtonImageView.alpha = 1.0
        }
        delegate?.downloadVideoPressed(selectedRow: selectedRow)
    }
    
    @IBAction func playAudioButtonTouchedDown(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3) {
            self.downloadAudioButtonImageView.alpha = 1.0
        }
        self.audioImage.alpha = 0.3
    }
    
    @IBAction func playVideoButtonTouchedDown(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3) {
            self.downloadVideoButtonImageView.alpha = 1.0
        }
        self.videoImage.alpha = 0.3
    }
    
    @IBAction func downloadAudioButtonTouchedDown(_ sender: UIButton) {
        self.downloadAudioButtonImageView.alpha = 0.3
    }
    
    @IBAction func downloadVideoButtonTouchedDown(_ sender: UIButton) {
        self.downloadVideoButtonImageView.alpha = 0.3
    }
    
    @IBAction func playAudioButtonTouchedUp(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3) {
            self.audioImage.alpha = 1.0
        }
    }
    
    @IBAction func playVideoButtonTouchedUp(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3) {
            self.videoImage.alpha = 1.0
        }
    }
    
    @IBAction func downloadAudioButtonTouchedUp(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3) {
            self.downloadAudioButtonImageView.alpha = 1.0
        }
    }
    
    @IBAction func downloadVideoButtonTouchedUp(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3) {
            self.downloadVideoButtonImageView.alpha = 1.0
        }
    }
}

protocol MishnaLessonCellDelegate: class {
    func cellPressed(selectedRow: Int)
    func playAudioPressed(selectedRow: Int)
    func playVideoPressed(selectedRow: Int)
    func downloadAudioPressed(selectedRow: Int)
    func downloadVideoPressed(selectedRow: Int)
}
