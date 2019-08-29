//בעזרת ה׳ החונן לאדם דעת
//  LessonPlayerViewController.swift
//  Jabrutouch
//
//  Created by Yoni Reiss on 22/08/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import UIKit
import WebKit

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
    @IBOutlet weak var videoPlayerContainer: UIView!
    
    // PDF WebView
    @IBOutlet weak var pdfWebView: WKWebView!
    @IBOutlet weak var pdfWebViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var pdfWebViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var pdfWebViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var pdfWebViewTrailingConstraint: NSLayoutConstraint!
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
    
    private var safeAreaBounds: CGRect {
        let window = UIApplication.shared.keyWindow
        let topPadding = window?.safeAreaInsets.top ?? 0.0
        let bottomPadding = window?.safeAreaInsets.bottom ?? 0.0
        let leftPadding = window?.safeAreaInsets.left ?? 0.0
        let rightPadding = window?.safeAreaInsets.right ?? 0.0
        
        let width = UIScreen.main.bounds.width - leftPadding - rightPadding
        let height = UIScreen.main.bounds.height - topPadding - bottomPadding
        let bounds = CGRect(x: 0, y: 0, width: width, height: height)
        print("safe area bounds: \(bounds), isLandscape: \(UIDevice.current.orientation.isLandscape)")
        return bounds
    }
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
        if UIDevice.current.orientation.isLandscape {
            self.setLandscapeMode()
        } else {
            self.setPortraitMode()
        }
    }
    
    override func loadView() {
        Bundle.main.loadNibNamed("LessonPlayerViewController", owner: self, options: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.pdfWebView.uiDelegate = self
        self.pdfWebView.navigationDelegate = self
        self.loadPDF()
        self.roundCorners()
        self.setPlayers()
        self.setShadows()
        self.setPortraitHeader()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setPortraitHeaderViewHeight()
        self.setPortraitMode()
        
        self.pdfWebView.isOpaque = false
        self.pdfWebView.backgroundColor = UIColor.clear
        
        self.pdfWebView.scrollView.backgroundColor = UIColor.clear
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.audioPlayer.stopAndRelease()
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
            self.pdfWebViewTopConstraint.constant = self.portraitHeaderViewAudioHeight
        case .video:
            switch self.videoPlayerMode {
            case .regular:
                self.pdfWebViewTopConstraint.constant = self.portraitHeaderViewVideoHeight + UIScreen.main.bounds.width * (229/423)
            case .small:
                self.pdfWebViewTopConstraint.constant = self.portraitHeaderViewVideoHeight
            case .fullScreen:
                break
            }
        }
        self.pdfWebViewBottomConstraint.constant = 0.0
        self.pdfWebViewLeadingConstraint.constant = 0.0
        self.pdfWebViewTrailingConstraint.constant = 0.0
        
        // Set audio player
        self.audioPlayer.setUIMode(.portrait)
        self.audioPlayerContainerWidthConstraint.constant = self.audioPlayerPortraitWidth
        
        // Set video player
        switch self.videoPlayerMode {
        case .fullScreen:
           break
        case .regular:
            break
        case .small:
            break
        }
        
        self.view.updateConstraints()
        self.view.layoutIfNeeded()
    }
    
    private func setLandscapeMode() {
        self.portraitHeaderView.isHidden = true
        self.landscapeHeaderView.isHidden = false
        
        // Set pdf view
        self.pdfWebViewTopConstraint.constant = 0.0
        self.pdfWebViewBottomConstraint.constant = 0.0
        self.pdfWebViewLeadingConstraint.constant = self.landscapeHeaderViewVideoWidth
        self.pdfWebViewTrailingConstraint.constant = 0.0
        
        // Set audio player
        self.audioPlayer.setUIMode(.landscape)
        self.audioPlayerContainerWidthConstraint.constant = self.audioPlayerLandscapeWidth
        
        // Set video player
        switch self.videoPlayerMode {
        case .fullScreen:
            break
        case .small, .regular:
            break
        }
        self.view.updateConstraints()
        self.view.layoutIfNeeded()
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
            self.videoPlayerContainer.isHidden = false
            self.audioPlayerContainer.isHidden = true
            
        case .audio:
            self.videoPlayerContainer.isHidden = true
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
        self.pdfWebView.loadFileURL(self.pdfUrl, allowingReadAccessTo: self.pdfUrl)
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
    
}

extension LessonPlayerViewController: WKUIDelegate {
    
    
}

extension LessonPlayerViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        switch self.mediaType {
        case .video:
            break
        case .audio:
            if let url = self.audioUrl {
                self.audioPlayer.setAudioUrl(url, startPlaying: true)
            }
        }
    }
}

extension LessonPlayerViewController: AudioPlayerDelegate {
    func currentTimeDidChange(currentTime: TimeInterval, duration: TimeInterval) {
        self.updateAudioSliderTimes(currentTime: currentTime, duration: duration)
    }
    
    func didStartPlaying() {
        
    }
    
    func didFinishPlaying() {
        
    }
    
    
}
