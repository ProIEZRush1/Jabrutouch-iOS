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
        guard let path = Bundle.main.path(forResource: "GRACIAS_BAJA_2", ofType:"mov") else {
            print("video.mov not found")
            return
        }
        let player = AVPlayer(url: URL(fileURLWithPath: path))
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.videoView.bounds
        self.videoView.layer.addSublayer(playerLayer)
        player.play()

    }
}
