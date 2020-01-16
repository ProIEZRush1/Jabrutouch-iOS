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
        shadowView.layer.cornerRadius = shadowView.bounds.height/2

    }
}
