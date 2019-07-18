//בעזרת ה׳ החונן לאדם דעת
//  WalkThroughCollectionViewCell.swift
//  Jabrutouch
//
//  Created by Yoni Reiss on 15/07/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import UIKit

class WalkThroughCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet var imageViews: [UIImageView]!
    
    func setIndex(_ index: Int) {
        self.setTitle(index)
        self.imageViews.forEach{$0.isHidden = $0.tag != index}
    }
    
    private func setTitle(_ index: Int) {
        switch index {
        case 0:
            self.titleLabel.text = Strings.welcomeToJabrutouch
        case 1:
            self.titleLabel.text = Strings.learnTalmudAndGemara
        case 2:
            self.titleLabel.text = Strings.giveTheGiftOfLearning
        case 3:
            self.titleLabel.text = Strings.askTheRabbiJoinTheJabruta
        default:
            break
        }
    }
}
