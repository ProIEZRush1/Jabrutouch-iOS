//בס״ד
//  MishnaLessonCellController.swift
//  Jabrutouch
//
//  Created by Aaron Tuil on 01/08/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import UIKit

class LessonDownloadCellController: UITableViewCell {
    
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var downloadButtonsContainerView: UIView!
    @IBOutlet weak var lessonNumber: UILabel!
    @IBOutlet weak var lessonLength: UILabel!
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
    
    var selectedRow: Int = 0
    weak var delegate: MishnaLessonCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let cellGestureRecognizer = (UITapGestureRecognizer(target: self, action: #selector(cellPressed)))
        cellView.addGestureRecognizer(cellGestureRecognizer)
    }
    
    @objc private func cellPressed() {
        delegate?.cellPressed(selectedRow: selectedRow)
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
        delegate?.downloadAudioPressed(selectedRow: selectedRow)
    }
    
    @IBAction func downloadVideoButtonPressed(_ sender: UIButton) {
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
