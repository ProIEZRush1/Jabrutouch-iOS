//
//  UserRecorderCell.swift
//  Jabrutouch
//
//  Created by AviDeutsch on 29/01/2020.
//  Copyright © 2020 Ravtech. All rights reserved.
//

import UIKit
import AVFoundation

protocol cellVoiceDelegate {
    func currentCellPlay()
    
    
}

class UserRecorderCell: UITableViewCell {
    
//    var url: String = ""
    
//    var play = false
    
    weak var delegate: ChatControlsViewDelegate?
    
//    var message: JTMessage?
    
//    var timer = Timer()

    //========================================
    // MARK: - Outlets
    //========================================
    
    @IBOutlet weak var recordView: UIView!
    
    @IBOutlet weak var slider: CustomTrackHeightSlider!
    
    @IBOutlet weak var playButton: PlayButton!
        
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var dateLable: UILabel!
    
    @IBOutlet weak var userImage: UIImageView!
    
    
    //========================================
    // MARK: - Setup
    //========================================
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.roundCorners()
        self.setShadow()
        
    }
    
    
    func roundCorners() {
        self.recordView.layer.cornerRadius = 18
    }
    
    func setShadow(){
        let color = #colorLiteral(red: 0.1019607843, green: 0.12, blue: 0.57, alpha: 0.1)
//        self.recordView.layer.shadowPath = UIBezierPath(roundedRect: self.recordView.bounds, cornerRadius: self.recordView.bounds.height/2).cgPath
        Utils.dropViewShadow(view: self.recordView, shadowColor: color, shadowRadius: 36, shadowOffset: CGSize(width: 0, height: 12))
    }
   
    
   
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
}


