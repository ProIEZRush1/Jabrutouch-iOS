//בס״ד
//  DownloadsTableViewCell.swift
//  Jabrutouch
//
//  Created by Aaron Tuil on 23/07/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import UIKit

class DownloadsCellController: UITableViewCell {
    
    @IBOutlet weak var progressBar: JBProgressBar!
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var book: UILabel!
    @IBOutlet weak var chapter: UILabel!
    @IBOutlet weak var number: UILabel!
    @IBOutlet weak var audioButton: UIButton!
    @IBOutlet weak var videoButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var cellTrailingConstraint: NSLayoutConstraint! // 21 or 45
    @IBOutlet weak var cellShadowView: UIView!
    
    weak var delegate: DownloadsCellDelegate?
    var indexPath: IndexPath?
    var isFirstTable = true // For multiple tables on same view controller
    
    @IBAction func deletePressed(_ sender: Any) {
        delegate?.cellDeletePressed(self)
    }
    
    @IBAction func playAudioPressed(_ sender: Any) {
        guard let indexPath = self.indexPath else { return }
        let lessonType: JTLessonType = self.isFirstTable ? .gemara : .mishna
        delegate?.playAudioPressed(atIndexPath: indexPath, lessonType: lessonType)
    }
    
    @IBAction func playVideoPressed(_ sender: Any) {
        guard let indexPath = self.indexPath else { return }
        let lessonType: JTLessonType = self.isFirstTable ? .gemara : .mishna
        delegate?.playVideoPressed(atIndexPath: indexPath, lessonType: lessonType)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

protocol DownloadsCellDelegate: class {
    func cellDeletePressed(_ cell: DownloadsCellController)
    func playAudioPressed(atIndexPath indexPath: IndexPath, lessonType: JTLessonType)
    func playVideoPressed(atIndexPath indexPath: IndexPath, lessonType: JTLessonType)
}
