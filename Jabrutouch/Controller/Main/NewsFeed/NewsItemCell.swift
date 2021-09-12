//
//  NewsItemCell.swift
//  Jabrutouch
//
//  Created by Avraham Kirsch on 26/08/2021.
//  Copyright © 2021 Ravtech. All rights reserved.
//

import UIKit
import AVKit


class NewsItemCell: UITableViewCell {
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    var newsItem: JTNewsFeedItem?
    var mediaPlayer: AVPlayer?
    var playerController: AVPlayerViewController?
    
    @IBOutlet weak var newsItemView: UIView!
    
    @IBOutlet weak var mediaView: UIView!
    @IBOutlet weak var imageBox: UIImageView!
    
    @IBOutlet weak var textContainer: UIView!
    @IBOutlet weak var textBox: UITextView!
    @IBOutlet weak var publishDateLabel: UILabel!
    

//    func setMediaPlayer(mediaURL: URL){
//        self.playerController = AVPlayerViewController()
//        self.mediaPlayer = AVPlayer(url: mediaURL)
//        self.playerController?.player = self.mediaPlayer
//        self.playerController?.showsPlaybackControls = true
//        
//        switch self.newsItem?.mediaType {
//        case .audio:
//            self.playerController?.view.frame = self.audioView.bounds
//            self.audioView.addSubview(self.playerController!.view)
//            Utils.setViewShape(view: self.audioView, viewCornerRadius: 18, maskedCorners: [.layerMinXMinYCorner, .layerMaxXMinYCorner])
//        case .video:
//            self.playerController?.view.frame = self.mediaView.bounds
//            self.mediaView.addSubview(self.playerController!.view)
//            Utils.setViewShape(view: self.mediaView, viewCornerRadius: 18, maskedCorners: [.layerMinXMinYCorner, .layerMaxXMinYCorner])
//        default:
//            break
//        }
//
//    }
    
    override func prepareForReuse() {
        //this way once user scrolls player will pause
        self.playerController?.player?.pause()
        self.mediaPlayer = nil
        self.playerController?.player = nil
    }
}



