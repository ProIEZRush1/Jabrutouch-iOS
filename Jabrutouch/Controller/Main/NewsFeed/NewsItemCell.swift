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
    
    var mediaPlayer: AVPlayer?
    var playerController: AVPlayerViewController?
    
    @IBOutlet weak var newsItemView: UIView!
    
    @IBOutlet weak var audioView: UIView!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var imageBox: UIImageView!
    
    @IBOutlet weak var textContainer: UIView!
    @IBOutlet weak var textBox: UITextView!
    

    func setVideo(videoURL: URL){
            
//                let mediaPlayer = AVPlayer(url: url)

//                let mediaPlayerLayer = AVPlayerLayer(player: mediaPlayer)
//
//                mediaPlayerLayer.frame = cell.videoView.bounds
//                cell.videoView.layer.addSublayer(mediaPlayerLayer)
//                mediaPlayer.play()
        
//        let playerViewController = AVPlayerViewController()
//        playerViewController.player = player
//        playerViewController.view.frame = cell.videoView.bounds
//        self.addChild(playerViewController)

        self.playerController = AVPlayerViewController()
        self.mediaPlayer = AVPlayer(url: videoURL)
        self.playerController?.player = self.mediaPlayer
        self.playerController?.showsPlaybackControls = true
        self.playerController?.view.frame = self.videoView.bounds
        self.videoView.addSubview(self.playerController!.view)
        

        Utils.setViewShape(view: self.videoView, viewCornerRadius: 18, maskedCorners: [.layerMinXMinYCorner, .layerMaxXMinYCorner])

    }
    
    override func prepareForReuse() {
        //this way once user scrolls player will pause
        self.playerController?.player?.pause()
        self.mediaPlayer = nil
        self.playerController?.player = nil
    }
}



