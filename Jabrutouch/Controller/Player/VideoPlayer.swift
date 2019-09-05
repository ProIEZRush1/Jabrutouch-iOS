//בעזרת ה׳ החונן לאדם דעת
//  VideoPlayer.swift
//  Jabrutouch
//
//  Created by Yoni Reiss on 29/08/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import UIKit
import AVKit

enum VideoPlayerMode {
    case regular
    case small
    case fullScreen
}

protocol VideoPlayerInterface {
    var isPlaying: Bool { get }
    var duration: TimeInterval { get }
    var currentTime: TimeInterval { get }
    func setCurrentTime(_ currentTime: TimeInterval)
}

protocol VideoPlayerDelegate: class {
    func currentTimeDidChange(currentTime: TimeInterval, duration: TimeInterval)
    func didStartPlaying()
    func didFinishPlaying()
    func videoPlayerModeDidChange(newMode: VideoPlayerMode)
}

class VideoPlayer: UIView {
    
    //----------------------------------------------------
    // MARK: - @IBOutlets
    //----------------------------------------------------
    @IBOutlet private weak var videoView: UIView!
    
    @IBOutlet private weak var accessoriesContainer: UIView!
    @IBOutlet private weak var toolBar: UIToolbar!
    @IBOutlet private weak var playPauseButtonItem: UIBarButtonItem!
    @IBOutlet private weak var forwardButtonItem: UIBarButtonItem!
    @IBOutlet private weak var rewindButtonItem: UIBarButtonItem!
    @IBOutlet private weak var nextButtonItem: UIBarButtonItem!
    @IBOutlet private weak var previousButtonItem: UIBarButtonItem!
    @IBOutlet private weak var playbackSpeedButton: UIButton!
    @IBOutlet private weak var minimizeButton: UIButton!
    @IBOutlet private weak var fullscreenButton: UIButton!
    @IBOutlet private weak var currentTimeLabel: UILabel!
    @IBOutlet private weak var endTimeButton: UIButton!
    @IBOutlet private weak var slider: UISlider!
    
    
    @IBOutlet private weak var buttonsStackView: UIStackView!
    @IBOutlet private weak var buttonsStackViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var playPauseButton: UIButton!
    @IBOutlet private weak var forwardButton: UIButton!
    @IBOutlet private weak var rewindButton: UIButton!
    @IBOutlet private weak var playbackSpeedButtonLandscape: UIButton!
    //----------------------------------------------------
    // MARK: - Properies
    //----------------------------------------------------
    
    weak var delegate: VideoPlayerDelegate?
    private var mode: VideoPlayerMode = .regular
    private var timeUpdateTimer: Timer?
    private var hideAccessoriesTimer: Timer?
    private var currentSpeed: PlaybackSpeed = .regular
    private var url: URL?
    private var videoLayer: AVPlayerLayer!
    private let videoAspectRatio: CGFloat = (480/270)
    private var endTimeDisplayType: EndTimeDisplayMode = .duration
    
    private var player: AVPlayer? {
        return self.videoLayer.player
    }
    
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
        let nib:UINib = UINib(nibName: "VideoPlayer", bundle: bundle)
        
        // Assumes UIView is top level and only object in CustomView.xib file
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
    
    override func awakeFromNib() {
        
        
        self.playPauseButtonItem.isEnabled = false
        self.forwardButtonItem.isEnabled = false
        self.rewindButtonItem.isEnabled = false
        self.playbackSpeedButton.isEnabled = false
        
        self.setupVideoLayer()
        self.setupToolbar()
        self.setupSliders()
        self.addBorders()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("TOUCHES BEGAN")
        if self.player != nil {
            switch self.mode {
            case .regular, .fullScreen:
                self.showAccessoriesView()
            case .small:
                self.mode = .regular
                self.delegate?.videoPlayerModeDidChange(newMode: .regular)
            }
        }
    }
    //----------------------------------------------------
    // MARK: - Setup
    //----------------------------------------------------
    
    private func setupVideoLayer() {
        self.videoLayer = AVPlayerLayer(player: nil)
        self.videoLayer.frame = self.videoView.layer.bounds
        self.videoView.layer.addSublayer(self.videoLayer)
        self.videoView.clipsToBounds = true
    }
    
    private func setupToolbar() {
        self.toolBar.setBackgroundImage(UIImage(),
                                        forToolbarPosition: .any,
                                        barMetrics: .default)
        self.toolBar.setShadowImage(UIImage(), forToolbarPosition: .any)
    }
    
    private func setupSliders() {
        self.slider.setThumbImage(#imageLiteral(resourceName: "thumb"), for: .normal)        
        
        if let image = Utils.linearGradientImage(size: self.slider.frame.size, colors: [Colors.appBlue, Colors.appOrange]) {
            self.slider.setMinimumTrackImage(image, for: .normal)
            
        }
    }
    
    private func addBorders() {
        self.playbackSpeedButton.layer.cornerRadius = self.playbackSpeedButton.bounds.width/2
        self.playbackSpeedButton.layer.borderWidth = 2.0
        self.playbackSpeedButton.layer.borderColor = UIColor.white.cgColor
        self.playbackSpeedButton.clipsToBounds = true
    }
    
    //----------------------------------------------------
    // MARK: - Methods
    //----------------------------------------------------
    
   
    
    func setMode(_ mode: VideoPlayerMode) {
        self.mode = mode
        switch mode {
        case .regular:
            self.accessoriesContainer.isHidden = true
            self.buttonsStackView.isHidden = true
            // Set Video Layer
            self.videoView.snp.removeConstraints()
            self.videoView.snp.makeConstraints { (maker) in
                maker.top.equalTo(self.view.snp.top)
                maker.bottom.equalTo(self.view.snp.bottom).inset(15.0)
                maker.leading.equalTo(self.view.snp.leading)
                maker.trailing.equalTo(self.view.snp.trailing)
            }
            
            self.slider.snp.removeConstraints()
            self.slider.snp.makeConstraints { (maker) in
                maker.bottom.equalToSuperview()
                maker.trailing.equalToSuperview()
                maker.leading.equalToSuperview()
                maker.height.equalTo(30.0)
            }
            self.view.layer.cornerRadius = 0.0
            self.view.clipsToBounds = true
        case .small:
            self.accessoriesContainer.isHidden = true
            self.buttonsStackView.isHidden = false
            
            self.videoView.snp.removeConstraints()
            self.videoView.snp.makeConstraints { (maker) in
                maker.top.equalTo(self.view.snp.top)
                maker.bottom.equalTo(self.view.snp.bottom)
                maker.leading.equalTo(self.view.snp.leading)
                maker.width.equalTo(self.videoView.snp.height).multipliedBy(self.videoAspectRatio)
            }
            
            let videoViewWidth = self.videoView.frame.height * self.videoAspectRatio
            self.buttonsStackViewLeadingConstraint.constant = videoViewWidth
            
            self.view.layer.cornerRadius = 15.0
            self.view.clipsToBounds = true
        case .fullScreen:
            self.accessoriesContainer.isHidden = true
            self.buttonsStackView.isHidden = true
            
            self.videoView.snp.removeConstraints()
            self.videoView.snp.makeConstraints { (maker) in
                maker.top.equalTo(self.view.snp.top)
                maker.bottom.equalTo(self.view.snp.bottom)
                maker.leading.equalTo(self.view.snp.leading)
                maker.trailing.equalTo(self.view.snp.trailing)
            }
            
            self.slider.snp.removeConstraints()
            self.slider.snp.makeConstraints { (maker) in
                maker.leading.equalTo(self.currentTimeLabel.snp.trailing).offset(8.0)
                maker.trailing.equalTo(self.endTimeButton.snp.leading).inset(8.0)
                maker.centerY.equalTo(self.currentTimeLabel.snp.centerY)
                maker.height.equalTo(30.0)
            }
            
            self.view.layer.cornerRadius = 0.0
            self.view.clipsToBounds = true
        }
        
        UIView.animate(withDuration: 0.4) {
            self.view.updateConstraints()
            self.view.layoutIfNeeded()
            self.accessoriesContainer.updateConstraints()
            self.accessoriesContainer.layoutIfNeeded()
        }
        self.videoLayer.resizeAndMove(frame: self.videoView.layer.bounds, animated: true, duration: 0.4)
    }
    
    func setVideoUrl(_ url: URL, startPlaying: Bool) {
        self.url = url
        self.playPauseButtonItem.isEnabled = true
        self.forwardButtonItem.isEnabled = true
        self.rewindButtonItem.isEnabled = true
        self.playbackSpeedButton.isEnabled = true
        
        if self.player == nil {
            self.videoLayer.player = AVPlayer(url: url)
            self.videoLayer.player?.addObserver(self, forKeyPath: "timeControlStatus", options: [.old, .new], context: nil)
        }
        else {
            let currentTime = self.player!.currentTime
            self.player?.removeObserver(self, forKeyPath: "timeControlStatus")
            self.videoLayer.player = AVPlayer(url: url)
            self.videoLayer.player?.addObserver(self, forKeyPath: "timeControlStatus", options: [.old, .new], context: nil)
            self.setCurrentTime(currentTime)
            self.changePlaybackSpeed(self.currentSpeed)
        }
        
        if startPlaying {
            self.play()
        }
    }
    
    func stopAndRelease() {
        self.player?.removeObserver(self, forKeyPath: "timeControlStatus")
        self.player?.pause()
        self.videoLayer.player = nil
        self.stopTimeUpdateTimer()
    }
    //----------------------------------------------------
    // MARK: - @IBActions
    //----------------------------------------------------
    
    @IBAction func playPauseButtonPressed(_ sender: Any) {
        guard let player = self.player else { return }
        if player.isPlaying {
            self.pause()
            switch self.mode {
            case .regular, .fullScreen:
                self.showAccessoriesView()
            case .small:
                break
            }
        }
        else {
            self.play()
        }
        
        
        
    }
    
    @IBAction func forwardButtonPressed(_ sender: Any) {
        self.forward(10.0)
        switch self.mode {
        case .regular, .fullScreen:
            self.showAccessoriesView()
        case .small:
            break
        }
    }
    
    @IBAction func rewindButtonPressed(_ sender: Any) {
        self.rewind(10.0)
        switch self.mode {
        case .regular, .fullScreen:
            self.showAccessoriesView()
        case .small:
            break
        }
    }
    
    @IBAction func playbackSpeedButtonPressed(_ sender: Any) {
        switch self.currentSpeed {
        case .regular:
            self.changePlaybackSpeed(.oneAndAHalf)
        case .oneAndAHalf:
            self.changePlaybackSpeed(.double)
        case .double:
            self.changePlaybackSpeed(.regular)
        }
        
        switch self.mode {
        case .regular, .fullScreen:
            self.showAccessoriesView()
        case .small:
            break
        }
    }
    
    @IBAction func minimizeButtonPressed(_ sender: Any) {
        self.mode = .small
        self.delegate?.videoPlayerModeDidChange(newMode: .small)
    }
    
    @IBAction func previousButtonPressed(_ sender: Any) {
        switch self.mode {
        case .regular, .fullScreen:
            self.showAccessoriesView()
        case .small:
            break
        }
    }
    
    @IBAction func nextButtonPressed(_ sender: Any) {
        switch self.mode {
        case .regular, .fullScreen:
            self.showAccessoriesView()
        case .small:
            break
        }
    }
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        guard let player = self.player else { return }
        let time = player.duration * Double(sender.value)
        self.setCurrentTime(time)
        
        switch self.mode {
        case .regular, .fullScreen:
            self.showAccessoriesView()
        case .small:
            break
        }
    }
    
    @IBAction func endTimeButtonPressed(_ sender: UIButton) {
        switch self.endTimeDisplayType {
        case .duration:
            self.endTimeDisplayType = .timeLeft
        case .timeLeft:
            self.endTimeDisplayType = .duration
        }
        self.updateSliderAndTimeLabels()
    }
    
    @IBAction func fullscreenButtonPressed(_ sender: UIButton) {
        if self.mode == .regular {
            self.mode = .fullScreen
        }
        else if self.mode == .fullScreen {
            self.mode = .regular
        }
        self.delegate?.videoPlayerModeDidChange(newMode: self.mode)
    }
    //----------------------------------------------------
    // MARK: - Actions
    //----------------------------------------------------
    
    private func startHideAccessoriesTimer() {
        DispatchQueue.main.async{
            self.hideAccessoriesTimer?.invalidate()
            self.hideAccessoriesTimer = nil
            self.hideAccessoriesTimer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(self.hideAccessoriesView), userInfo: nil, repeats: false)
        }
    }
    
    private func stopHideAccessoriesTimer() {
        DispatchQueue.main.async{
            self.hideAccessoriesTimer?.invalidate()
            self.hideAccessoriesTimer = nil
        }
    }
    
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
        self.playPauseButtonItem.image = #imageLiteral(resourceName: "pause")
        self.playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
        player.play()
        player.rate = self.currentSpeed.rate
        self.startTimeUpdateTimer()
        self.hideAccessoriesView()
    }
    
    private func pause() {
        self.player?.pause()
        self.playPauseButtonItem.image = #imageLiteral(resourceName: "play_large")
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
            self.playbackSpeedButtonLandscape.setTitle("1", for: .normal)
        case .oneAndAHalf:
            self.playbackSpeedButton.setTitle("1.5", for: .normal)
            self.playbackSpeedButtonLandscape.setTitle("1.5", for: .normal)
        case .double:
            self.playbackSpeedButton.setTitle("2", for: .normal)
            self.playbackSpeedButtonLandscape.setTitle("2", for: .normal)
        }
        
        if player.isPlaying {
            player.rate = self.currentSpeed.rate
        }
    }
    
    @objc private func updateTime() {
        guard let player = self.player else { return }
        self.delegate?.currentTimeDidChange(currentTime: player.currentTime, duration: player.duration)
        self.updateSliderAndTimeLabels()
    }
    
    private func showAccessoriesView() {
        self.accessoriesContainer.isHidden = false
        UIView.animate(withDuration: 0.3, animations: {
            self.accessoriesContainer.alpha = 1.0
        })
        
        
        if self.player?.isPlaying == true {
            self.startHideAccessoriesTimer()
        }
        else {
            self.stopHideAccessoriesTimer()
        }
        
    }
    
    @objc private func hideAccessoriesView() {
        self.stopHideAccessoriesTimer()
        UIView.animate(withDuration: 0.3, animations: {
            self.accessoriesContainer.alpha = 0.0
        }) { (finish) in
            self.accessoriesContainer.isHidden = true
        }
    }
    
    private func updateSliderAndTimeLabels() {
        guard let player = self.player else { return }
        let currentTime = player.currentTime
        let duration = player.duration
        
        let percentage = Float(currentTime/duration)
        self.slider.value = percentage
        self.currentTimeLabel.text = Utils.convertTimeInSecondsToDisplayString(currentTime)
        
        let endTime: TimeInterval
        switch self.endTimeDisplayType {
        case .duration:
            endTime = duration
        case .timeLeft:
            endTime = duration - currentTime
        }
        var title = Utils.convertTimeInSecondsToDisplayString(endTime)
        if self.endTimeDisplayType == .timeLeft {
            title = "-\(title)"
        }
        self.endTimeButton.setTitle(title, for: .normal)
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
}

extension VideoPlayer: VideoPlayerInterface {
    
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
        self.updateTime()
    }
}
