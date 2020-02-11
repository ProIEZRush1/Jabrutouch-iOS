//
//  IncomingRecordCell.swift
//  Jabrutouch
//
//  Created by AviDeutsch on 29/01/2020.
//  Copyright © 2020 Ravtech. All rights reserved.
//

import UIKit

class IncomingRecordCell: UITableViewCell {
    

    var url: String = ""
    
    var play = false
    
    var timer:Timer!
    
    
    
      //========================================
       // MARK: - Outlets
       //========================================
       
       @IBOutlet weak var recordView: UIView!
       
       @IBOutlet weak var slider: CustomTrackHeightSlider!
       
       @IBOutlet weak var playButton: UIButton!
              
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
           let color = #colorLiteral(red: 0.1, green: 0.12, blue: 0.57, alpha: 0.4)
           self.recordView.layer.shadowPath = UIBezierPath(roundedRect: self.recordView.bounds, cornerRadius: self.recordView.bounds.height/2).cgPath
           Utils.dropViewShadow(view: self.recordView, shadowColor: color, shadowRadius: 36, shadowOffset: CGSize(width: 0, height: 12))
       }
       
       //========================================
       // MARK: - Actions
       //========================================
       
       @IBAction func playPressed(_ sender: Any) {
        AudioMessagesManager.shared.stopPlayer()
        play.toggle()
        if play{
            playButton.setImage(UIImage(named:"pause"), for: .normal)
            AudioMessagesManager.shared.startPlayer(url)
//            if let image = Utils.linearGradientImage(endXPoint: MessagesRepository.shared!.soundPlayer.currentTime, size: self.slider.frame.size, colors: [Colors.appBlue, Colors.appOrange]) {
//                self.slider.setMinimumTrackImage(image, for: .normal)
//            }
            
        }else{
            playButton.setImage(UIImage(named:"play1"), for: .normal)
            AudioMessagesManager.shared.stopPlayer()
            
        }
//        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)

       }
    
//    @objc func updateTime() {
//        let currentTime = Int(MessagesRepository.shared.soundPlayer!.soundPlayer.currentTime)
//            let minutes = currentTime/60
//            let seconds = currentTime - minutes * 60
//            timeLabel.text = String(format: "%02d:%02d", minutes,seconds) as String
//
//
//
//         }
//
     
  
}
