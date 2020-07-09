//בעזרת ה׳ החונן לאדם דעת
//  AudioPlayer.swift
//  Jabrutouch
//
//  Created by Yoni Reiss on 29/08/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import UIKit
import AVKit
import MediaPlayer

protocol AudioPlayerInterface {
    var watchDuration: TimeInterval { get }
    var isPlaying: Bool { get }
    var duration: TimeInterval { get }
    var currentTime: TimeInterval { get }
    func setCurrentTime(_ currentTime: TimeInterval)
}

protocol AudioPlayerDelegate: class {
    func currentTimeDidChange(currentTime: TimeInterval, duration: TimeInterval)
    func didStartPlaying()
    func didFinishPlaying()
    func canSendLike()
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
    @IBOutlet weak var slider: UISlider!
    //----------------------------------------------------
    // MARK: - Properies
    //----------------------------------------------------
    
    weak var delegate: AudioPlayerDelegate?
    
    private var timeUpdateTimer: Timer?
    private var currentSpeed: PlaybackSpeed = .regular
    private var url: URL?
    private var player: AVPlayer?
    private(set) var watchDuration: TimeInterval = 0.0
    private(set) var watchLocation: TimeInterval = 0.0
    private var startPlayDate: Date?
    private var mediaName: String?
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
        
        self.slider.setThumbImage(#imageLiteral(resourceName: "newThumb"), for: .normal)
        if let image = Utils.linearGradientImage(endXPoint: 0.0, size: self.slider.frame.size, colors: [Colors.appBlue, Colors.appOrange]) {
            self.slider.setMinimumTrackImage(image, for: .normal)
            
        }
    }
    
    func stopAndRelease() {
        let _ = self.pause()
        guard let player = self.player else { return }
        self.watchLocation = player.currentTime
        self.player?.removeObserver(self, forKeyPath: "timeControlStatus")
        self.player = nil
        self.stopTimeUpdateTimer()
        self.removeRemoteTransportControls()
    }
    
    //----------------------------------------------------
    // MARK: - Methods
    //----------------------------------------------------
    
    func setAudioUrl(_ url: URL, startPlaying: Bool, mediaName: String) {
        self.url = url
        self.mediaName = mediaName
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
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            try AVAudioSession.sharedInstance().setActive(true)
            self.setupRemoteTransportControls()
        }
            
        catch {
            
        }
        
        if startPlaying {
            let _ = self.play()
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
            let _ = self.play()
            return
        }
        if player.isPlaying {
            let _ = self.pause()
        }
        else {
            let _ = self.play()
        }
    }
    
    @IBAction func forwardPauseButtonPressed(_ sender: UIButton) {
        DispatchQueue.main.async {
            self.forward(10.0)
        }
        
    }
    
    @IBAction func rewindPauseButtonPressed(_ sender: UIButton) {
        DispatchQueue.main.async {
            self.rewind(10.0)
            //            self.rewind(30.0)
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
    
    func seek(percentage: Double) {
        guard let player = self.player else { return }
        let time = player.duration * percentage
        self.setCurrentTime(time)
        self.slider.value = Float(percentage)
    }
    
    private func startTimeUpdateTimer() {
        
        DispatchQueue.main.async{
            self.timeUpdateTimer?.invalidate()
            self.timeUpdateTimer = nil
            self.timeUpdateTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateTime), userInfo: nil, repeats: true)
//            self.timeUpdateTimer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(self.updateAnaliticsTime), userInfo: nil, repeats: true)
            
            self.timeUpdateTimer?.fire()
        }
    }
    
    private func stopTimeUpdateTimer() {
        DispatchQueue.main.async{
            self.timeUpdateTimer?.invalidate()
            self.timeUpdateTimer = nil
        }
        
    }
    @objc func play() -> MPRemoteCommandHandlerStatus {
        guard let player = self.player else { return .commandFailed }
        self.playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
        player.play()
        player.rate = self.currentSpeed.rate
        self.startTimeUpdateTimer()
        return .success
    }
    
    @objc  func pause() -> MPRemoteCommandHandlerStatus {
        self.player?.pause()
        self.playPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
        self.stopTimeUpdateTimer()
        return .success
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
    
    @objc func changePlaybackPosition(_ event: MPChangePlaybackPositionCommandEvent) -> MPRemoteCommandHandlerStatus {
        self.setCurrentTime(event.positionTime)
        return .success
    }
    
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let avPlayer = self.player else { return }
        if object as AnyObject? === avPlayer {
            if keyPath == "timeControlStatus" {
                if #available(iOS 10.0, *) {
                    if avPlayer.timeControlStatus == .playing {
                        self.delegate?.didStartPlaying()
                        self.startPlayDate = Date()
                    } else if avPlayer.timeControlStatus == .paused {
                        if let date = self.startPlayDate {
                            let pauseDate = Date()
                            let duration = pauseDate.timeIntervalSince(date)
                            self.watchDuration += duration
                            self.startPlayDate = nil
                        }
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
        if (Int(player.currentTime().seconds) == 30) {
            self.delegate?.canSendLike()
        }
        setupNowPlaying()
        if let image = Utils.linearGradientImage(endXPoint: percentage, size: self.slider.frame.size, colors: [Colors.appBlue, Colors.appOrange]) {
            self.slider.setMinimumTrackImage(image, for: .normal)
            
        }
    }
    

    //----------------------------------------------------
    // MARK: - Command Center
    //----------------------------------------------------
    
    private func setupRemoteTransportControls() {
        // Get the shared MPRemoteCommandCenter
        let commandCenter = MPRemoteCommandCenter.shared()
        self.setupNowPlaying()
        // Add handler for Play/Pause Commande
        commandCenter.playCommand.addTarget(self, action: #selector(self.play))
        commandCenter.pauseCommand.addTarget(self, action: #selector(self.pause))
        commandCenter.changePlaybackPositionCommand.addTarget(self, action: #selector(self.changePlaybackPosition(_:)))
        commandCenter.playCommand.isEnabled = true
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.changePlaybackPositionCommand.isEnabled = true
    }
    
    private func removeRemoteTransportControls() {
        let commandCenter = MPRemoteCommandCenter.shared()
        
        commandCenter.playCommand.removeTarget(self)
        commandCenter.pauseCommand.removeTarget(self)
        commandCenter.changePlaybackPositionCommand.removeTarget(self)
        commandCenter.playCommand.isEnabled = false
        commandCenter.pauseCommand.isEnabled = false
        commandCenter.changePlaybackPositionCommand.isEnabled = false
    }
    
    func setupNowPlaying() {
        // Define Now Playing Info
        var nowPlayingInfo = [String : Any]()
//        nowPlayingInfo[MPMediaItemPropertyTitle] = self.mediaName
        
//        if let image = UIImage(named: "lockscreen") {
//            nowPlayingInfo[MPMediaItemPropertyArtwork] =
//                MPMediaItemArtwork(boundsSize: image.size) { size in
//                    return image
//            }
//        }
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player?.currentTime().seconds
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = player?.duration
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = player?.rate
        
        // Set the metadata
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
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
