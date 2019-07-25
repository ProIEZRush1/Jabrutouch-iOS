//
//  DownloadsHeaderCellController.swift
//  Jabrutouch
//
//  Created by Aaron Tuil on 24/07/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import UIKit

class DownloadsHeaderCellController: UITableViewHeaderFooterView {
    
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var arrowImage: UIImageView!
    var section: Int = 0
    weak var delegate: HeaderViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(headerPressed)))
    }
    
    @objc private func headerPressed() {
        delegate?.toggleSection(header: self, section: section)
    }
}

protocol HeaderViewDelegate: class {
    func toggleSection(header: DownloadsHeaderCellController, section: Int)
}
