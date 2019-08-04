//בס״ד
//  MishnaChapterCellController.swift
//  Jabrutouch
//
//  Created by Aaron Tuil on 31/07/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import UIKit

class MishnaChapterCellController: UITableViewCell {
    
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var chapterName: UILabel!
    @IBOutlet weak var mishnaiotCount: UILabel!
    @IBOutlet weak var mishnaiotText: UILabel!
    
    var selectedRow: Int = 0
    weak var delegate: MishnaChapterCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let gestureRecognizer = (UITapGestureRecognizer(target: self, action: #selector(cellPressed)))
        cellView.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc private func cellPressed() {
        delegate?.showMasechetLessons(selectedRow: selectedRow)
    }
}

protocol MishnaChapterCellDelegate: class {
    func showMasechetLessons(selectedRow: Int)
}
