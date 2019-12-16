//
//  IncomingMessageCell.swift
//  Jabrutouch
//
//  Created by Shlomo Carmen on 11/12/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import UIKit

class IncomingMessageCell: UITableViewCell {
    
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.roundCorners()
        self.setShadow()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func roundCorners() {
        self.messageView.layer.cornerRadius = 18
        
    }
    
    func setShadow(){
        let color = #colorLiteral(red: 0.1, green: 0.12, blue: 0.57, alpha: 0.4)
        self.messageView.layer.shadowPath = UIBezierPath(roundedRect: self.messageView.bounds, cornerRadius: self.messageView.bounds.height/2).cgPath
        Utils.dropViewShadow(view: self.messageView, shadowColor: color, shadowRadius: 36, shadowOffset: CGSize(width: 0, height: 12))
    }

}
