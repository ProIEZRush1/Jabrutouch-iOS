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
    
    @IBOutlet weak var lessonProgressBar: JBProgressBar!
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var downloadButtonsContainerView: UIView!
    @IBOutlet weak var lessonNumber: UILabel!
    @IBOutlet weak var lessonLength: UILabel!
    @IBOutlet weak var cellViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var cellViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var downloadVideoPBWB: JBProgressBarWithButton!
    @IBOutlet weak var downloadAudioPBWB: JBProgressBarWithButton!
    @IBOutlet weak var cellVideoPBWB: JBProgressBarWithButton!
    @IBOutlet weak var cellAudioPBWB: JBProgressBarWithButton!
       
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
    
    func setProgressViewButtons(_ lesson: JTLesson) {
        
        if lesson.isAudioDownloaded {
            self.downloadAudioPBWB.setButtonImage(NormalImage: #imageLiteral(resourceName: "audio-downloaded"), highlightedImage: #imageLiteral(resourceName: "audio-downloaded"))
            self.cellAudioPBWB.setButtonImage(NormalImage: #imageLiteral(resourceName: "audio-downloaded"), highlightedImage: #imageLiteral(resourceName: "audio-downloaded"))
            
        } else {
            self.downloadAudioPBWB.setButtonImage(NormalImage: #imageLiteral(resourceName: "downloadAudio"), highlightedImage: #imageLiteral(resourceName: "downloadAudio"))
            self.cellAudioPBWB.setButtonImage(NormalImage: #imageLiteral(resourceName: "audio-nat"), highlightedImage: #imageLiteral(resourceName: "audio-prs"))
            self.cellAudioPBWB.button.addTarget(self, action: #selector(playAudio(_:)), for: .touchUpInside)
            self.downloadAudioPBWB.button.addTarget(self, action: #selector(downloadAudio(_:)), for: .touchUpInside)
            
        }
        if lesson.isVideoDownloaded {
            self.downloadVideoPBWB.setButtonImage(NormalImage: #imageLiteral(resourceName: "video-downloaded"), highlightedImage: #imageLiteral(resourceName: "video-downloaded"))
            self.cellVideoPBWB.setButtonImage(NormalImage: #imageLiteral(resourceName: "video-downloaded"), highlightedImage: #imageLiteral(resourceName: "video-downloaded"))
            
        } else {
            self.downloadVideoPBWB.setButtonImage(NormalImage: #imageLiteral(resourceName: "downloadVideo"), highlightedImage: #imageLiteral(resourceName: "downloadVideo"))
            self.cellVideoPBWB.setButtonImage(NormalImage: #imageLiteral(resourceName: "video-nat"), highlightedImage: #imageLiteral(resourceName: "video-prs"))
            self.cellVideoPBWB.button.addTarget(self, action: #selector(playVideo(_:)), for: .touchUpInside)
            self.downloadVideoPBWB.button.addTarget(self, action: #selector(downloadVideo(_:)), for: .touchUpInside)
            
        }
        
        self.downloadVideoPBWB.setProgress(progress: nil, fontColor: .white, ringColor: Colors.appBlue)
        self.downloadAudioPBWB.setProgress(progress: nil, fontColor: .white, ringColor: Colors.appBlue)
        self.cellVideoPBWB.setProgress(progress: nil, fontColor: .black, ringColor: .lightGray)
        self.cellAudioPBWB.setProgress(progress: nil, fontColor: .black, ringColor: .lightGray)
        
    }
    
    @objc func playAudio(_ sender: UIButton) {
        delegate?.playAudioPressed(selectedRow: selectedRow)
    }
    
    @objc func playVideo(_ sender: UIButton) {
        delegate?.playVideoPressed(selectedRow: selectedRow)
    }
    
    @objc func downloadAudio(_ sender: UIButton) {
        delegate?.downloadAudioPressed(selectedRow: selectedRow)
    }
    
    @objc func downloadVideo(_ sender: UIButton) {
        delegate?.downloadVideoPressed(selectedRow: selectedRow)
    }
    
    func setLesson(_ lesson: JTLesson) {
        self.setProgressViewButtons(lesson)
        self.downloadButtonsContainerView.layoutIfNeeded()
        self.cellView.layoutIfNeeded()
    }
    
    func setEditingIfNeeded(lesson: JTLesson, isCurrentlyEditing: Bool) {
        self.animateImagesVisibility(isCurrentlyEditing: isCurrentlyEditing)
        UIView.animate(withDuration: 0.6) {
            if isCurrentlyEditing {
                self.cellViewTrailingConstraint.constant = UIScreen.main.bounds.size.width / 2 - 20
            } else {
                self.cellViewTrailingConstraint.constant = 18
            }
            self.layoutIfNeeded()
        }
    }
    
    private func animateImagesVisibility(isCurrentlyEditing: Bool) {
        self.cellVideoPBWB.isHidden = isCurrentlyEditing ? true : false
        self.cellAudioPBWB.isHidden = isCurrentlyEditing ? true : false
    }
    
    func setDownloadModeForLesson(_ lesson: JTLesson, isCurrentlyEditing: Bool) {
        let downloadingProgress = lesson.audioDownloadProgress ?? lesson.videoDownloadProgress ?? 0.0
        let progress = CGFloat(downloadingProgress * 100)
        if isCurrentlyEditing {
            if lesson.isDownloadingAudio {
                self.downloadAudioPBWB.setProgress(progress: progress, fontColor: .white, ringColor: Colors.appBlue)
                self.downloadVideoPBWB.button.isEnabled = false
            } else if lesson.isDownloadingVideo {
                self.downloadVideoPBWB.setProgress(progress: progress, fontColor: .white, ringColor: Colors.appBlue)
                self.downloadAudioPBWB.button.isEnabled = false
            }
        } else {
            if lesson.isDownloadingAudio {
                self.cellAudioPBWB.setProgress(progress: progress, fontColor: .black, ringColor: .lightGray)
            } else if lesson.isDownloadingVideo {
                self.cellVideoPBWB.setProgress(progress: progress, fontColor: .black, ringColor: .lightGray)
            }
        }
    }
    
    //=====================================================
    // MARK: - @IBActions
    //=====================================================
    
    @objc private func cellPressed() {
        delegate?.cellPressed(selectedRow: selectedRow)
        delegate?.playVideoPressed(selectedRow: selectedRow)

    }
    
}

protocol MishnaLessonCellDelegate: class {
    func cellPressed(selectedRow: Int)
    func playAudioPressed(selectedRow: Int)
    func playVideoPressed(selectedRow: Int)
    func downloadAudioPressed(selectedRow: Int)
    func downloadVideoPressed(selectedRow: Int)
}
