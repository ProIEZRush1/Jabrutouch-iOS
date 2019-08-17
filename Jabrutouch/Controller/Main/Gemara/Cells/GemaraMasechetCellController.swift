//בס״ד
//  GemaraMasechetCellController.swift
//  Jabrutouch
//
//  Created by Aaron Tuil on 05/08/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import UIKit

class GemaraMasechetCellController: UITableViewCell {
    
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var masechetName: UILabel!
    @IBOutlet weak var pagesCountLabel: UILabel!
    @IBOutlet weak var pagesCountTextLabel: UILabel!
    
    var indexPath: IndexPath = []
    weak var delegate: GemaraMasechetCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let gestureRecognizer = (UITapGestureRecognizer(target: self, action: #selector(cellPressed)))
        cellView.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc func cellPressed() {
        delegate?.showMasechetLessons(indexPath: indexPath)
    }
}

protocol GemaraMasechetCellDelegate: class {
    func showMasechetLessons(indexPath: IndexPath)
}

