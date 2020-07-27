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
    @IBOutlet weak var textLabel: UILabel!
    
    func setIndex(_ index: Int, _ sender: String) {
        self.setTitle(index, sender)
        self.imageViews.forEach{$0.isHidden = $0.tag != index}
    }
    
    private func setTitle(_ index: Int, _ sender: String) {
        if sender == "sginIn" {
            switch index {
            case 0:
                let attributedString = NSMutableAttributedString(string: Strings.welcomeToJabrutouch, attributes: [NSAttributedString.Key.font: Fonts.regularFont(size:24)])
                let range = (Strings.welcomeToJabrutouch as NSString).range(of: Strings.jabrutouch)
                attributedString.addAttributes([NSAttributedString.Key.font: Fonts.heavyFont(size:30)], range: range)
                
                self.titleLabel.attributedText = attributedString
                //            self.titleLabel.text = Strings.welcomeToJabrutouch
                self.textLabel.text = Strings.walkthrough1Text
            case 1:
                self.titleLabel.text = Strings.learnTalmudAndGemara
                self.textLabel.text = Strings.walkthrough2Text
            case 2:
                self.titleLabel.text = Strings.giveTheGiftOfLearning
                self.textLabel.text = Strings.walkthrough3Text
            case 3:
                self.titleLabel.text = Strings.askTheRabbiJoinTheJabruta
                self.textLabel.text = Strings.walkthrough4Text
            default:
                break
            }
        } else if sender == "donations" {
            switch index {
            case 0:
//
                self.titleLabel.text = "page 1 titel"
                self.textLabel.text = "page 1 text"
            case 1:
                self.titleLabel.text = "page 2 titel"
                self.textLabel.text = "page 2 text"
            case 2:
                self.titleLabel.text = "page 3 titel"
                self.textLabel.text = "page 3 text"
            case 3:
                self.titleLabel.text = "page 4 titel"
                self.textLabel.text = "page 4 text"
            default:
                break
            }
        }
    }
}
