//
//  NewsItemCell.swift
//  Jabrutouch
//
//  Created by Avraham Kirsch on 26/08/2021.
//  Copyright © 2021 Ravtech. All rights reserved.
//

import UIKit
import AVKit


class NewsItemCell: UITableViewCell{

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    var newsItem: JTNewsFeedItem?
    var videoPlayer: AVPlayer?
    var playerController: AVPlayerViewController?
    var audioPlayer: AVPlayer?
    
    
    @IBOutlet weak var newsItemView: UIView!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var audioView: UIView!
    ///
    @IBOutlet weak var audioSlider: UISlider!
    
    ///  A timer to update the audioSlider with the current time of the audio player
    var displayLink: CADisplayLink?
    
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var imageBox: UIImageView!
    @IBOutlet weak var textContainer: UIView!
    @IBOutlet weak var textBox: UITextView!
    @IBOutlet weak var publishDateLabel: UILabel!

    //==================================================
    // MARK: Setup
    //==================================================

    
    func setupPlayer(){
        guard let audioURL = URL(string:self.newsItem?.mediaLink ?? "") else { return }
        let playerItem = AVPlayerItem(url: audioURL)
        self.audioPlayer = AVPlayer(playerItem: playerItem)
        self.setSlider()
        self.playAudio()
        self.startUpdatingPlaybackStatus()
        NotificationCenter.default.addObserver(self, selector: #selector(resetPlayer), name: .AVPlayerItemDidPlayToEndTime, object: self.audioPlayer?.currentItem)
    }
    
    //==================================================
    // MARK: Audio Controls
    //==================================================
    
    
    @IBAction func playPausePressed(_ sender: Any) {
        if let player = self.audioPlayer {
            if player.isPlaying {
                self.pauseAudio()
            } else {
                self.playAudio()
            }
        } else {
            // Setup player the first time
            // (this causes minor delay until playback starts - other option is to instantiate in cellForRowAt, but then there's unnecessary instantiating and destroying happening on every scroll of the tableView) 
            self.setupPlayer()

        }
    }

    private func playAudio() {
        self.audioPlayer?.play()
        displayLink?.isPaused = false
        playPauseButton.setImage(UIImage(named: "pause"), for: .normal)
    }
    
    private func pauseAudio() {
        self.audioPlayer?.pause()
        displayLink?.isPaused = true
        playPauseButton.setImage(UIImage(named: "play1"), for: .normal)
    }
    
    @objc private func resetPlayer() {
        self.pauseAudio()
        self.audioSlider.value = 0
        self.audioPlayer?.seek(to: CMTime(seconds: 0, preferredTimescale: 1))
    }
    
    //==================================================
    // MARK: Slider setup & controls
    //==================================================
    
    
    func setSlider() {
        self.audioSlider.minimumValue = 0
        self.audioSlider.maximumValue = 1
        self.audioSlider.addTarget(self, action: #selector(didBeginDraggingSlider), for: .touchDown)
        self.audioSlider.addTarget(self, action: #selector(didEndDraggingSlider), for: .valueChanged)
        self.displayLink = CADisplayLink(target: self, selector: #selector(updatePlaybackStatus))
        self.displayLink?.preferredFramesPerSecond = 2
        
    }

    func startUpdatingPlaybackStatus() {
        displayLink?.add(to: .main, forMode: .common)
    }

    func stopUpdatingPlaybackStatus() {
        displayLink?.invalidate()
    }
    
    @objc
    func updatePlaybackStatus() {
        guard let player = audioPlayer else { return }
        let playbackProgress = Float(player.currentTime / player.duration)
        audioSlider.setValue(playbackProgress, animated: true)
    }
    
    @objc
    func didBeginDraggingSlider() {
        displayLink?.isPaused = true
    }

    @objc
    func didEndDraggingSlider() {
        guard let player = audioPlayer else { return }
        let newPosition = CMTime(seconds: player.duration * Double(audioSlider.value), preferredTimescale: 1)
        
        player.seek(to: newPosition)
        displayLink?.isPaused = false

    }
   
    //==================================================
    // MARK: Cleanup
    //==================================================
    
    override func prepareForReuse() {
        //this way once user scrolls player will pause
        super.prepareForReuse()
        self.playerController?.player?.pause()
        self.videoPlayer = nil
        self.playerController?.player = nil
        
        self.imageBox.image = nil
        self.imageBox.cancelImageLoad()
        
        self.pauseAudio()
        self.audioPlayer = nil
        self.stopUpdatingPlaybackStatus()
        self.audioSlider.value = 0
    }
    
}



