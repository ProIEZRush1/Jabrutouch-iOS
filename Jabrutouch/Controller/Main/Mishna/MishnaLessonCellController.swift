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
    @IBOutlet weak var lessonNumber: UILabel!
    @IBOutlet weak var lessonLength: UILabel!
    @IBOutlet weak var audioImage: UIImageView!
    @IBOutlet weak var videoImage: UIImageView!
    
    var indexPath: IndexPath = []
    weak var delegate: MishnaLessonCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
//    @objc private func audioDownloadPressed() {
//        delegate?.audioDownloadPressed(indexPath: indexPath)
//    }
}

protocol MishnaLessonCellDelegate: class {
    func audioDownloadPressed(indexPath: IndexPath)
    func videoDownloadPressed(indexPath: IndexPath)
}
