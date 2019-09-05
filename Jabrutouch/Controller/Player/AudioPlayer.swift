//בעזרת ה׳ החונן לאדם דעת
//  AudioPlayer.swift
//  Jabrutouch
//
//  Created by Yoni Reiss on 29/08/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import UIKit
import AVKit

protocol AudioPlayerInterface {
    var isPlaying: Bool { get }
    var duration: TimeInterval { get }
    var currentTime: TimeInterval { get }
    func setCurrentTime(_ currentTime: TimeInterval)
}

protocol AudioPlayerDelegate: class {
    func currentTimeDidChange(currentTime: TimeInterval, duration: TimeInterval)
    func didStartPlaying()
    func didFinishPlaying()
}


enum PlayerOrientation {
    case portrait
    case landscape
}

class AudioPlayer: UIView {

    //----------------------------------------------------
    // MARK: - @IBOutlets
    //----------------------------------------------------
    
    @IBOutlet private weak var buttonsStackView: UIStackView!
    @IBOutlet private weak var playPauseButton: UIButton!
    @IBOutlet private weak var forwardButton: UIButton!
    @IBOutlet private weak var rewindButton: UIButton!
    @IBOutlet private weak var playbackSpeedButton: UIButton!
    @IBOutlet private weak var slider: UISlider!
    //----------------------------------------------------
    // MARK: - Properies
    //----------------------------------------------------
    
    weak var delegate: AudioPlayerDelegate?
    
    private var timeUpdateTimer: Timer?
    private var currentSpeed: PlaybackSpeed = .regular
    private var url: URL?
    private var player: AVPlayer?
    
    //----------------------------------------------------
    // MARK: - Initializers
    //----------------------------------------------------
    
    override init(frame: CGRect) {
        // 1. setup any properties here
        // 2. call super.init(frame:)
        super.init(frame: frame)
        
        // 3. Setup view from .xib file
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        // 1. setup any properties here
        // 2. call super.init(coder:)
        super.init(coder: aDecoder)
        
        // 3. Setup view from .xib file
        xibSetup()
    }
    
    // Our custom view from the XIB file
    var view: UIView!
    
    func xibSetup() {
        view = loadViewFromNib()
        
        // use bounds not frame or it'll be offset
        view.frame = bounds
        
        // Make the view stretch with containing view
        view.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
        addSubview(view)
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib:UINib = UINib(nibName: "AudioPlayer", bundle: bundle)
        
        // Assumes UIView is top level and only object in CustomView.xib file
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
    
    override func awakeFromNib() {
        self.playPauseButton.isEnabled = false
        self.forwardButton.isEnabled = false
        self.rewindButton.isEnabled = false
        self.playbackSpeedButton.isEnabled = false
        
        self.slider.setThumbImage(#imageLiteral(resourceName: "thumb"), for: .normal)
        if let image = Utils.linearGradientImage(size: self.slider.frame.size, colors: [Colors.appBlue, Colors.appOrange]) {
            self.slider.setMinimumTrackImage(image, for: .normal)
            
        }
    }
 
    func stopAndRelease() {
        self.player?.removeObserver(self, forKeyPath: "timeControlStatus")
        self.player?.pause()
        self.player = nil
        self.stopTimeUpdateTimer()
    }
    //----------------------------------------------------
    // MARK: - Methods
    //----------------------------------------------------
    
    func setAudioUrl(_ url: URL, startPlaying: Bool) {
        self.url = url
        self.playPauseButton.isEnabled = true
        self.forwardButton.isEnabled = true
        self.rewindButton.isEnabled = true
        self.playbackSpeedButton.isEnabled = true
        
        if self.player == nil {
            self.player = AVPlayer(url: url)
            self.player?.addObserver(self, forKeyPath: "timeControlStatus", options: [.old, .new], context: nil)
        }
        else {
            let currentTime = self.player!.currentTime
            self.player?.removeObserver(self, forKeyPath: "timeControlStatus")
            self.player = AVPlayer(url: url)
            self.player?.addObserver(self, forKeyPath: "timeControlStatus", options: [.old, .new], context: nil)
            self.setCurrentTime(currentTime)
            self.changePlaybackSpeed(self.currentSpeed)
        }
        if startPlaying {
            self.play()
        }
    }
    
    func setOrientation(_ orientation: PlayerOrientation) {
        switch orientation {
        case .portrait:
            self.slider.isHidden = true
        case .landscape:
            self.slider.isHidden = false
        }
    }
    //----------------------------------------------------
    // MARK: - @IBActions
    //----------------------------------------------------
    
    @IBAction func playPauseButtonPressed(_ sender: UIButton) {
        guard let player = self.player else {
            self.play()
            return
        }
        if player.isPlaying {
            self.pause()
        }
        else {
            self.play()
        }
    }
    
    @IBAction func forwardPauseButtonPressed(_ sender: UIButton) {
        DispatchQueue.main.async {
            self.forward(10.0)
        }
        
    }
    
    @IBAction func rewindPauseButtonPressed(_ sender: UIButton) {
        DispatchQueue.main.async {
            self.rewind(30.0)
        }
    }
    
    @IBAction func playbackSpeedButtonPressed(_ sender: UIButton) {
        switch self.currentSpeed {
        case .regular:
            self.changePlaybackSpeed(.oneAndAHalf)
        case .oneAndAHalf:
            self.changePlaybackSpeed(.double)
        case .double:
            self.changePlaybackSpeed(.regular)
        }
    }
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        guard let player = self.player else { return }
        let time = player.duration * Double(sender.value)
        self.setCurrentTime(time)
    }
    //----------------------------------------------------
    // MARK: - Actions
    //----------------------------------------------------
    
    private func startTimeUpdateTimer() {
        
        DispatchQueue.main.async{
            self.timeUpdateTimer?.invalidate()
            self.timeUpdateTimer = nil
            self.timeUpdateTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateTime), userInfo: nil, repeats: true)
            
            self.timeUpdateTimer?.fire()
        }
    }
    
    private func stopTimeUpdateTimer() {
        DispatchQueue.main.async{
            self.timeUpdateTimer?.invalidate()
            self.timeUpdateTimer = nil
        }
        
    }
    private func play() {
        guard let player = self.player else { return }
        self.playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
        player.play()
        self.startTimeUpdateTimer()
    }
    
    private func pause() {
        self.player?.pause()
        self.playPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
        self.stopTimeUpdateTimer()

    }
    
    private func forward(_ time: TimeInterval) {
        guard let player = self.player else { return }
        let newTime = min(player.currentTime + time, player.duration)
        self.setCurrentTime(newTime)
    }
    
    private func rewind(_ time: TimeInterval) {
        guard let player = self.player else { return }
        let newTime = max(player.currentTime - time, 0.0)
        self.setCurrentTime(newTime)
    }
    
    private func changePlaybackSpeed(_ speed: PlaybackSpeed) {
        guard let player = self.player else { return }
        self.currentSpeed = speed

        switch speed {
        case .regular:
            self.playbackSpeedButton.setTitle("1", for: .normal)
        case .oneAndAHalf:
            self.playbackSpeedButton.setTitle("1.5", for: .normal)
        case .double:
            self.playbackSpeedButton.setTitle("2", for: .normal)
        }
        
        if player.isPlaying {
            player.rate = self.currentSpeed.rate
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let avPlayer = self.player else { return }
        if object as AnyObject? === avPlayer {
            if keyPath == "timeControlStatus" {
                if #available(iOS 10.0, *) {
                    if avPlayer.timeControlStatus == .playing {
                        self.delegate?.didStartPlaying()
                    } else {
                        
                    }
                }
            }
        }
    }
    
    @objc private func updateTime() {
        guard let player = self.player else { return }
        let percentage = player.currentTime/player.duration
        self.slider.value = Float(percentage)
        self.delegate?.currentTimeDidChange(currentTime: player.currentTime, duration: player.duration)
    }
}


extension AudioPlayer: AVAudioPlayerDelegate {
    
}

extension AudioPlayer: AudioPlayerInterface {
    var isPlaying: Bool {
        return self.player?.isPlaying ?? false
    }
    
    var duration: TimeInterval {
        guard let player = self.player else { return 0.0}
        return player.duration
    }
    
    var currentTime: TimeInterval {
        guard let player = self.player else { return 0.0}
        return player.currentTime
    }
    
    func setCurrentTime(_ time: TimeInterval) {
        guard let player = self.player else { return }
        let _time = CMTime(seconds: time, preferredTimescale: 1)
        player.seek(to: _time)
    }
}
