//
//  DonationWalkThroughCollectionViewCell.swift
//  Jabrutouch
//
//  Created by Avraham Deutsch on 26/07/2020.
//  Copyright © 2020 Ravtech. All rights reserved.
//

import UIKit

class DonationWalkThroughCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var noteLabel: UILabel!
    @IBOutlet weak var noteButtomLabel: UILabel!
    @IBOutlet var imageViews: [UIImageView]!
    

    func setIndex(_ index: Int) {
        self.setTitle(index)
        self.imageViews.forEach{$0.isHidden = $0.tag != index}
    }
    
    private func setTitle(_ index: Int) {
            switch index {
            case 0:
                self.titleLabel.text = Strings.donateTour0Title
                self.noteLabel.text = Strings.donateTour0
                self.noteButtomLabel.alpha = 0
            case 1:
                self.titleLabel.text = Strings.donateTour1Title
                self.noteLabel.text = Strings.donateTour1
                self.noteButtomLabel.text = Strings.donateTour1Buttom
                self.noteButtomLabel.alpha = 1
            case 2:
                self.titleLabel.text = Strings.donateTour2Title
                self.noteLabel.text = Strings.donateTour2
                self.noteButtomLabel.alpha = 0
            default:
                break
            }
    }
   
}
