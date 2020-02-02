//
//  TopicCollectionViewCell.swift
//  Jabrutouch
//
//  Created by Shlomo Carmen on 23/10/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import UIKit

class TopicCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var topicLabel: LabelWithPadding!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var containerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        shadowView.layer.cornerRadius = shadowView.bounds.height/2

    }
    
    override var isSelected: Bool {
        didSet {
            shadowView.backgroundColor = isSelected ? #colorLiteral(red: 0.102, green: 0.120, blue: 0.567, alpha: 1) : .white
            topicLabel.textColor = isSelected ? #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0) : .black
        }
    }
}
