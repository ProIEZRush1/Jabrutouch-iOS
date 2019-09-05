//בעזרת ה׳ החונן לאדם דעת
//  LessonPlayerViewController.swift
//  Jabrutouch
//
//  Created by Yoni Reiss on 22/08/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import UIKit
import WebKit
import SnapKit
import PDFKit

class LessonPlayerViewController: UIViewController {
    
    //====================================================
    // MARK: - @IBOutlets
    //====================================================
    
    // Portrait Header View
    @IBOutlet weak var portraitHeaderView: UIView!
    @IBOutlet weak var portraitHeaderViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var portraitBackButton: UIButton!
    @IBOutlet weak var portraitDownloadButton: UIButton!
    @IBOutlet weak var portraitChatButton: UIButton!
    @IBOutlet weak var portraitPhotoButton: UIButton!
    @IBOutlet weak var audioSliderContainer: UIView!
    @IBOutlet weak var audioSlider: UISlider!
    @IBOutlet weak var audioCurrentTimeLabel: UILabel!
    @IBOutlet weak var audioEndTimeButton: UIButton!
    
    // Landscape Header View
    @IBOutlet weak var landscapeHeaderView: UIView!
    @IBOutlet weak var landscapeBackButton: UIButton!
    @IBOutlet weak var landscapeDownloadButton: UIButton!
    @IBOutlet weak var landscapeChatButton: UIButton!
    @IBOutlet weak var landscapePhotoButton: UIButton!
    
    // Audio Player
    @IBOutlet weak var audioPlayerContainer: UIView!
    @IBOutlet weak var audioPlayerContainerWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var audioPlayer: AudioPlayer!
    
    // Video Player
    @IBOutlet weak var videoPlayer: VideoPlayer!
    
    // PDF WebView
    @IBOutlet weak var pdfView: PDFView!
    @IBOutlet weak var pdfViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var pdfViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var pdfViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var pdfViewTrailingConstraint: NSLayoutConstraint!
    //====================================================
    // MARK: - Properties
    //====================================================
    
    var pdfUrl: URL
    var videoUrl: URL?
    var audioUrl: URL?
    var mediaType: JTLessonMediaType
    var endTimeDisplayType: EndTimeDisplayMode = .duration
    
    private var videoPlayerMode: VideoPlayerMode = .regular
    
    private let portraitHeaderViewAudioHeight: CGFloat = 100.0
    private let portraitHeaderViewVideoHeight: CGFloat = 53.0
    private let landscapeHeaderViewVideoWidth: CGFloat = 53.0
    
    private let audioPlayerPortraitWidth: CGFloat = 301.0
    private let audioPlayerLandscapeWidth: CGFloat = 600.0
    
    private let videoAspectRatio: CGFloat = 270/480
    
    private var activityView: ActivityView?
    //====================================================
    // MARK: - LifeCycle
    //====================================================
    
    init(pdfUrl: URL, videoUrl: URL?, audioUrl: URL?, mediaType: JTLessonMediaType) {
        self.pdfUrl = pdfUrl
        self.videoUrl = videoUrl
        self.audioUrl = audioUrl
        self.mediaType = mediaType
        
        super.init(nibName: "LessonPlayerViewController", bundle: Bundle.main)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
    }
    
    override func loadView() {
        Bundle.main.loadNibNamed("LessonPlayerViewController", owner: self, options: nil)
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.allButUpsideDown]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.pdfView.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.showActivityView()
        self.roundCorners()
        self.setPlayers()
        self.setShadows()
        self.setPortraitHeader()
        
        self.setPortraitHeaderViewHeight()
        self.setPortraitMode()
        
        self.pdfView.isOpaque = false
        self.pdfView.backgroundColor = UIColor.clear
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.orientationDidChange(_:)), name: UIDevice.orientationDidChangeNotification, object: nil)
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            self.loadPDF()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.audioPlayer.stopAndRelease()
        self.videoPlayer.stopAndRelease()
        
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func orientationDidChange(_ notification: Notification) {
        print(UIDevice.current.orientation.rawValue)
        print(self.view.frame)
        if UIScreen.main.bounds.height < UIScreen.main.bounds.width {
            self.setLandscapeMode()
        }
        else  {
            self.setPortraitMode()
        }
    }
    //====================================================
    // MARK: - Setup
    //====================================================
    
    private func setPortraitMode() {
        
        // Set header view
        self.portraitHeaderView.isHidden = false
        self.landscapeHeaderView.isHidden = true
        
        // Set pdf view
        switch self.mediaType {
        case .audio:
            self.pdfViewTopConstraint.constant = self.portraitHeaderViewAudioHeight
        case .video:
            switch self.videoPlayerMode {
            case .regular:
                let screenWidth = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
                self.pdfViewTopConstraint.constant = self.portraitHeaderViewVideoHeight + screenWidth * self.videoAspectRatio
            case .small:
                self.pdfViewTopConstraint.constant = self.portraitHeaderViewVideoHeight
            case .fullScreen:
                break
            }
        }
        self.pdfViewBottomConstraint.constant = 0.0
        self.pdfViewLeadingConstraint.constant = 0.0
        self.pdfViewTrailingConstraint.constant = 0.0
        
        // Set audio player
        self.audioPlayer.setOrientation(.portrait)
        self.audioPlayerContainerWidthConstraint.constant = self.audioPlayerPortraitWidth
        
        // Set video player
        if self.videoPlayerMode == .regular {
            self.videoPlayer.setMode(.regular)
        }
        self.videoPlayer.snp.removeConstraints()
        switch self.videoPlayerMode {
        case .fullScreen:
            self.videoPlayer.snp.makeConstraints { (maker: ConstraintMaker) in
                maker.top.equalTo(self.view.snp.top)
                maker.leading.equalTo(self.view.snp.leading)
                maker.trailing.equalTo(self.view.snp.trailing)
                maker.bottom.equalTo(self.view.snp.bottom)
            }
            self.videoPlayer.layer.cornerRadius = 0.0
            Utils.dropViewShadow(view: self.videoPlayer, shadowColor: UIColor.clear, shadowRadius: 0, shadowOffset: CGSize(width: 0.0, height: 12))
            
        case .regular:
            self.videoPlayer.snp.makeConstraints { (maker: ConstraintMaker) in
                maker.top.equalTo(self.portraitHeaderView.snp.bottom)
                maker.leading.equalTo(self.view.snp.leading)
                maker.trailing.equalTo(self.view.snp.trailing)
                maker.height.equalTo(self.videoPlayer.snp.width).multipliedBy(self.videoAspectRatio).offset(15.0)
            }
            self.videoPlayer.layer.cornerRadius = 0.0
            Utils.dropViewShadow(view: self.videoPlayer, shadowColor: UIColor.clear, shadowRadius: 0, shadowOffset: CGSize(width: 0.0, height: 12))
            
        case .small:
            self.videoPlayer.snp.makeConstraints { (maker: ConstraintMaker) in
                maker.bottom.equalTo(self.view.snp.bottom).inset(16.0)
                maker.centerX.equalToSuperview()
                maker.width.equalTo(386.0).priority(ConstraintPriority.high)
                maker.height.equalTo(70.0).priority(ConstraintPriority.high)
                maker.trailing.lessThanOrEqualTo(self.view.snp.trailing).inset(16.0).priority(ConstraintPriority.required)
                maker.leading.greaterThanOrEqualTo(self.view.snp.leading).offset(16.0).priority(ConstraintPriority.required)
            }
            self.videoPlayer.layer.cornerRadius = 15.0
            Utils.dropViewShadow(view: self.videoPlayer, shadowColor: Colors.playerShadowColor, shadowRadius: 36, shadowOffset: CGSize(width: 0.0, height: 12))
        }
        
        UIView.animate(withDuration: 0.4) {
            self.view.updateConstraints()
            self.view.layoutIfNeeded()
        }
        self.videoPlayer.setMode(self.videoPlayerMode)
        
    }
    
    private func setLandscapeMode() {
        self.portraitHeaderView.isHidden = true
        self.landscapeHeaderView.isHidden = false
        
        // Set pdf view
        self.pdfViewTopConstraint.constant = 0.0
        self.pdfViewBottomConstraint.constant = 0.0
        self.pdfViewLeadingConstraint.constant = self.landscapeHeaderViewVideoWidth
        self.pdfViewTrailingConstraint.constant = 0.0
        
        // Set audio player
        self.audioPlayer.setOrientation(.landscape)
        self.audioPlayerContainerWidthConstraint.constant = self.audioPlayerLandscapeWidth
        
        // Set video player
        
        self.videoPlayer.snp.removeConstraints()
        switch self.videoPlayerMode {
        case .fullScreen:
            self.videoPlayer.snp.makeConstraints { (maker: ConstraintMaker) in
                maker.top.equalTo(self.view.snp.top)
                maker.leading.equalTo(self.view.snp.leading)
                maker.trailing.equalTo(self.view.snp.trailing)
                maker.bottom.equalTo(self.view.snp.bottom)
            }
            self.videoPlayer.layer.cornerRadius = 0.0
            Utils.dropViewShadow(view: self.videoPlayer, shadowColor: UIColor.clear, shadowRadius: 0, shadowOffset: CGSize(width: 0.0, height: 12))
        case .small, .regular:
            self.videoPlayer.snp.makeConstraints { (maker: ConstraintMaker) in
                maker.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).inset(16.0)
                maker.centerX.equalToSuperview()
                maker.width.equalTo(386.0)
                maker.height.equalTo(70.0)
            }
            self.videoPlayer.layer.cornerRadius = 15.0
            Utils.dropViewShadow(view: self.videoPlayer, shadowColor: Colors.playerShadowColor, shadowRadius: 36, shadowOffset: CGSize(width: 0.0, height: 12))
        }
        
        UIView.animate(withDuration: 0.4) {
            self.view.updateConstraints()
            self.view.layoutIfNeeded()
        }
        if self.videoPlayerMode == .regular || self.videoPlayerMode == .small{
            self.videoPlayer.setMode(.small)
        }
        else {
            self.videoPlayer.setMode(.fullScreen)
        }
        
    }
    
    private func setPortraitHeaderViewHeight() {
        let height: CGFloat!
        switch self.mediaType {
        case .audio:
            height = self.portraitHeaderViewAudioHeight
        case .video:
            height = self.portraitHeaderViewVideoHeight
        }
        
        self.portraitHeaderViewHeightConstraint.constant = height
        self.portraitHeaderView.updateConstraints()
        self.view.layoutIfNeeded()
    }
    
    private func roundCorners() {
        self.audioPlayerContainer.layer.cornerRadius = 15.0
        self.audioPlayer.layer.cornerRadius = 15.0
        self.audioPlayer.clipsToBounds = true
        
    }
    
    private func setShadows() {
        let shadowOffset = CGSize(width: 0.0, height: 12)
        Utils.dropViewShadow(view: self.audioPlayerContainer, shadowColor: Colors.playerShadowColor, shadowRadius: 36, shadowOffset: shadowOffset)
        Utils.dropViewShadow(view: self.videoPlayer, shadowColor: Colors.playerShadowColor, shadowRadius: 36, shadowOffset: shadowOffset)
        
    }
    
    private func setPortraitHeader() {
        switch self.mediaType {
        case .video:
            self.audioSliderContainer.isHidden = true
        case .audio:
            self.audioSliderContainer.isHidden = false
            if let image = Utils.linearGradientImage(size: self.audioSlider.frame.size, colors: [Colors.appBlue, Colors.appOrange]) {
                self.audioSlider.setMinimumTrackImage(image, for: .normal)
            }
        }
    }
    private func setPlayers() {
        switch self.mediaType {
        case .video:
            self.videoPlayer.isHidden = false
            self.audioPlayerContainer.isHidden = true
            self.videoPlayer.delegate = self
            
        case .audio:
            self.videoPlayer.isHidden = true
            self.audioPlayerContainer.isHidden = false
            self.audioPlayer.delegate = self
        }
    }
    
    private func updateAudioSliderTimes(currentTime: TimeInterval, duration: TimeInterval) {
        let percentage = Float(currentTime/duration)
        self.audioSlider.value = percentage
        self.audioCurrentTimeLabel.text = Utils.convertTimeInSecondsToDisplayString(currentTime)
        
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
        self.audioEndTimeButton.setTitle(title, for: .normal)
    }
    //====================================================
    // MARK: - Content setup
    //====================================================
    
    private func loadPDF() {
        
        if let pdfDocument = PDFDocument(url: self.pdfUrl) {
            self.pdfView.document = pdfDocument
            self.pdfView.autoScales = true
            switch self.mediaType {
            case .video:
                if let url = self.videoUrl {
                    self.videoPlayer.setVideoUrl(url, startPlaying: true)
                }
            case .audio:
                if let url = self.audioUrl {
                    self.audioPlayer.setAudioUrl(url, startPlaying: true)
                }
            }
        }
        
        
    }
    
    //====================================================
    // MARK: - @IBActions
    //====================================================
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func downloadButtonPressed(_ sender: UIButton) {
        
    }
    
    @IBAction func photoButtonPressed(_ sender: UIButton) {
        
    }
    
    @IBAction func chatButtonPressed(_ sender: UIButton) {
        
    }
    
    @IBAction func audioEndTimeButtonPressed(_ sender: UIButton) {
        switch self.endTimeDisplayType {
        case .duration:
            self.endTimeDisplayType = .timeLeft
        case .timeLeft:
            self.endTimeDisplayType = .duration
        }
        self.updateAudioSliderTimes(currentTime: self.audioPlayer.currentTime, duration: self.audioPlayer.duration)
    }
    
    @IBAction func audioSliderValueChanged(_ sender: UISlider) {
        let time = self.audioPlayer.duration * Double(sender.value)
        self.audioPlayer.setCurrentTime(time)
    }
    
    //============================================================
    // MARK: - ActivityView
    //============================================================
    
    private func showActivityView() {
        DispatchQueue.main.async {
            if self.activityView == nil {
                self.activityView = Utils.showActivityView(inView: self.view, withFrame: self.view.frame, text: nil)
            }
        }
    }
    private func removeActivityView() {
        DispatchQueue.main.async {
            if let view = self.activityView {
                Utils.removeActivityView(view)
            }
        }
    }
}

extension LessonPlayerViewController: WKUIDelegate {
    
    
}

extension LessonPlayerViewController: PDFViewDelegate {
    
}

extension LessonPlayerViewController: AudioPlayerDelegate, VideoPlayerDelegate {
    func videoPlayerModeDidChange(newMode: VideoPlayerMode) {
        self.videoPlayerMode = newMode
        if UIScreen.main.bounds.height <  UIScreen.main.bounds.width {
            self.setLandscapeMode()
        }
        else  {
            self.setPortraitMode()
        }
    }
    
    func currentTimeDidChange(currentTime: TimeInterval, duration: TimeInterval) {
        self.updateAudioSliderTimes(currentTime: currentTime, duration: duration)
    }
    
    func didStartPlaying() {
        self.removeActivityView()
    }
    
    func didFinishPlaying() {
        
    }
    
    
}
