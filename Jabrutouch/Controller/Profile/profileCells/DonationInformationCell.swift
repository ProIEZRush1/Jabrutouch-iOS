//
//  DonationInformationCell.swift
//  Jabrutouch
//
//  Created by Shlomo Carmen on 07/10/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import UIKit

class DonationInformationCell: UITableViewCell {
    
    @IBOutlet weak var gradientView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var donatedLabel: UILabel!
    @IBOutlet weak var learedLabel: UILabel!
    @IBOutlet weak var donateButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        let color = #colorLiteral(red: 0.1, green: 0.12, blue: 0.57, alpha: 0.1)
        Utils.dropViewShadow(view: self.containerView, shadowColor: color, shadowRadius: 36, shadowOffset: CGSize(width: 0, height: 12))

        self.donateButton.layer.cornerRadius = 10
        self.containerView.layer.cornerRadius = 12
        self.containerView.clipsToBounds = false

    }

//    func createGradient() {
//        let startColor: UIColor = UIColor(red: 0.81, green: 0.94, blue: 1, alpha: 1)
//        let endColor: UIColor = UIColor(red: 0.5, green: 0.62, blue: 0.86, alpha: 1)
//
//        let colors = [startColor.cgColor, endColor.cgColor]
//        if let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors as CFArray, locations: [0.54, 1]) {
//
//        }
//    }
}
