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
    var isExpanded = false
    var isFirstTable = true // For multiple tables on same view controller
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(headerPressed)))
    }
    
    @objc private func headerPressed() {
        delegate?.toggleSection(header: self, section: section)
        arrowImage?.rotate(isExpanded ? .pi : 0.0)
    }
}

protocol HeaderViewDelegate: class {
    func toggleSection(header: DownloadsHeaderCellController, section: Int)
}

extension UIView {
    func rotate(_ toValue: CGFloat, duration: CFTimeInterval = 0.2) {
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        animation.toValue = toValue
        animation.duration = duration
        animation.isRemovedOnCompletion = false
        animation.fillMode = CAMediaTimingFillMode.forwards
        self.layer.add(animation, forKey: nil)
    }
}
