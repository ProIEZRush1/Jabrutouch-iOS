//
//  VideoViewController.swift
//  Jabrutouch
//
//  Created by Shlomo Carmen on 20/02/2020.
//  Copyright © 2020 Ravtech. All rights reserved.
//

import UIKit
import AVFoundation

class VideoViewController: UIViewController {

    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var skipView: UIView!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var playVideoButton: UIButton!
    
    var videoUrl: URL?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.videoView.layer.cornerRadius = 16
        
    }
    
    @IBAction func playVideoButtonPressed(_ sender: Any) {
        self.playVideo()
    }
    
    @IBAction func skipButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func getVideoUrl() {
        AWSS3Provider.shared.handleFileDownload(fileName: "", bucketName: AWSS3Provider.appS3BucketName, progressBlock: nil) {  (result) in
            switch result{
            case .success(let data):
                print(data)
                self.videoUrl = URL(string: "")
            case .failure(_):
                break
            }
        }
        
    }

    func playVideo() {
        //        if let videoURL = self.videoUrl {
        let videoURL = URL(string: "https://vod-progressive.akamaized.net/exp=1582466703~acl=%2A%2F1633894284.mp4%2A~hmac=e16e42e41e054f2f7c987e516597672068c7288341eb42d648a8b76d96bd6c0d/vimeo-prod-skyfire-std-us/01/2487/15/387438884/1633894284.mp4")
        let player = AVPlayer(url: videoURL!)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.videoView.bounds
        self.videoView.layer.addSublayer(playerLayer)
        player.play()
//        }
    }
}
