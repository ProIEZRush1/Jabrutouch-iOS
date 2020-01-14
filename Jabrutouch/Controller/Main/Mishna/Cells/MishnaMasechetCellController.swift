//בס״ד
//  MishnaMasechetCellController.swift
//  Jabrutouch
//
//  Created by Aaron Tuil on 31/07/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import UIKit

class MishnaMasechetCellController: UITableViewCell {
    
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var masechetName: UILabel!
    @IBOutlet weak var chaptersCount: UILabel!
    @IBOutlet weak var chapterText: UILabel!
    @IBOutlet weak var arrowImageView: UIImageView!
    
    var indexPath: IndexPath = []
    weak var delegate: MishnaMasechetCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let gestureRecognizer = (UITapGestureRecognizer(target: self, action: #selector(cellPressed)))
        cellView.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc func cellPressed() {
        delegate?.getMasectChapterContent(indexPath: indexPath, isFirst: false)
    }
}

protocol MishnaMasechetCellDelegate: class {
    func showMasechetChapters(indexPath: IndexPath)
    func getMasectChapterContent(indexPath: IndexPath, isFirst: Bool)
}
