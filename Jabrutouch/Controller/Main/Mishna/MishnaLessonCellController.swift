//בס״ד
//  MishnaLessonCellController.swift
//  Jabrutouch
//
//  Created by Aaron Tuil on 01/08/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import UIKit

class MishnaLessonCellController: UITableViewCell {
    
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var underneathCellView: UIView!
    @IBOutlet weak var lessonNumber: UILabel!
    @IBOutlet weak var lessonLength: UILabel!
    @IBOutlet weak var audioImage: UIImageView!
    @IBOutlet weak var videoImage: UIImageView!
    @IBOutlet weak var redAudioVImage: UIImageView!
    @IBOutlet weak var redVideoVImage: UIImageView!
    @IBOutlet weak var audioButton: UIButton!
    @IBOutlet weak var videoButton: UIButton!
    @IBOutlet weak var underneathAudioButton: UIButton!
    @IBOutlet weak var underneathVideoButton: UIButton!
    @IBOutlet weak var underneathAudioDownloadImage: UIImageView!
    @IBOutlet weak var underneathVideoDownloadImage: UIImageView!
    @IBOutlet weak var cellViewTrailingConstraint: NSLayoutConstraint!
    
    var selectedRow: Int = 0
    weak var delegate: MishnaLessonCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let cellGestureRecognizer = (UITapGestureRecognizer(target: self, action: #selector(cellPressed)))
        cellView.addGestureRecognizer(cellGestureRecognizer)
        let audioGestureRecognizer = (UITapGestureRecognizer(target: self, action: #selector(audioPressed)))
        audioButton.addGestureRecognizer(audioGestureRecognizer)
        let videoGestureRecognizer = (UITapGestureRecognizer(target: self, action: #selector(videoPressed)))
        videoButton.addGestureRecognizer(videoGestureRecognizer)
        let downloadAudioGestureRecognizer = (UITapGestureRecognizer(target: self, action: #selector(underneathAudioPressed)))
        underneathAudioButton.addGestureRecognizer(downloadAudioGestureRecognizer)
        let downloadVideoGestureRecognizer = (UITapGestureRecognizer(target: self, action: #selector(underneathVideoPressed)))
        underneathVideoButton.addGestureRecognizer(downloadVideoGestureRecognizer)
    }
    
    @objc private func cellPressed() {
        delegate?.cellPressed(selectedRow: selectedRow)
    }
    
    @objc private func audioPressed() {
        delegate?.audioPressed(selectedRow: selectedRow)
    }
    
    @objc private func videoPressed() {
        delegate?.videoPressed(selectedRow: selectedRow)
    }
    
    @objc private func underneathAudioPressed() {
        delegate?.underneathAudioPressed(selectedRow: selectedRow)
    }
    
    @objc private func underneathVideoPressed() {
        delegate?.underneathVideoPressed(selectedRow: selectedRow)
    }
}

protocol MishnaLessonCellDelegate: class {
    func cellPressed(selectedRow: Int)
    func audioPressed(selectedRow: Int)
    func videoPressed(selectedRow: Int)
    func underneathAudioPressed(selectedRow: Int)
    func underneathVideoPressed(selectedRow: Int)
}
