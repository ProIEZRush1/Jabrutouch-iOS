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
    @IBOutlet weak var cancelButton: UIButton!
    

    func setIndex(_ index: Int) {
        self.setTitle(index)
        self.imageViews.forEach{$0.isHidden = $0.tag != index}
    }
    
    private func setTitle(_ index: Int) {
            switch index {
            case 0:
                self.titleLabel.text = Strings.tourwalkthrough1Text
                self.cancelButton.isHidden = true
            case 1:
                self.titleLabel.text = Strings.tourwalkthrough2Text
                self.cancelButton.isHidden = true
            case 2:
                self.titleLabel.text = Strings.tourwalkthrough3Text
                self.cancelButton.isHidden = true
            case 3:
                self.titleLabel.text = Strings.tourwalkthrough4Text
                self.cancelButton.isHidden = false
            default:
                break
            }
    }
    @IBAction func cancelPressed(_ sender: Any) {
        print("CANCEL PRESSED")
    }
}
