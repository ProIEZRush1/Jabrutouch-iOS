//
//  TourWalkThroughCollectionViewCell.swift
//  Jabrutouch
//
//  Created by Avraham Deutsch on 20/07/2020.
//  Copyright © 2020 Ravtech. All rights reserved.
//

import UIKit

class TourWalkThroughCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet var imageViews: [UIImageView]!
    
    
    func setIndex(_ index: Int, _ sender: String) {
        self.setTitle(index, sender)
        self.imageViews.forEach{$0.isHidden = $0.tag != index}
    }
    
    private func setTitle(_ index: Int, _ sender: String) {
        if sender == "sginIn" {
            switch index {
            case 0:
                self.titleLabel.text =  Strings.tourwalkthrough1Text
            case 1:
                self.titleLabel.text = Strings.tourwalkthrough2Text
            case 2:
                self.titleLabel.text = Strings.tourwalkthrough3Text
            case 3:
                self.titleLabel.text = Strings.tourwalkthrough4Text
            default:
                break
            }
        } else if sender == "donations" {
            switch index {
            case 0:
                self.titleLabel.text = "page 1 titel"
            case 1:
                self.titleLabel.text = "page 2 titel"
            case 2:
                self.titleLabel.text = "page 3 titel"
            case 3:
                self.titleLabel.text = "page 4 titel"
            default:
                break
            }
        }
    }
}
