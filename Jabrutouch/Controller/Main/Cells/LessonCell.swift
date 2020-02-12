//
//  LessonCell.swift
//  Jabrutouch
//
//  Created by Shlomo Carmen on 12/02/2020.
//  Copyright © 2020 Ravtech. All rights reserved.
//

import UIKit
import UICircularProgressRing

class LessonCell: UITableViewCell {

    @IBOutlet weak var lessonProgressBar: JBProgressBar!
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
    
    @IBOutlet weak var downloadAudioImage: UIImageView!
    @IBOutlet weak var downloadVideoImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
