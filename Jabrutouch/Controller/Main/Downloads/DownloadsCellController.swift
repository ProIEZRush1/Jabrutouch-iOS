//
//  DownloadsTableViewCell.swift
//  Jabrutouch
//
//  Created by Aaron Tuil on 23/07/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import UIKit

class DownloadsCellController: UITableViewCell {
    
    @IBOutlet weak var cellView: UILabel!
    @IBOutlet weak var book: UILabel!
    @IBOutlet weak var chapter: UILabel!
    @IBOutlet weak var number: UILabel!
    @IBOutlet weak var audioButton: UIButton!
    @IBOutlet weak var videoButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var cellTrailingConstraint: NSLayoutConstraint! // 21 or 45
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
