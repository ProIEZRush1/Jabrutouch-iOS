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
import UICircularProgressRing

class LessonPlayerViewController: UIViewController {
    
    //====================================================
    // MARK: - @IBOutlets
    //====================================================
    var user: JTUser?
    // Portrait Header View
    @IBOutlet weak var portraitHeaderView: UIView!
    @IBOutlet weak var portraitHeaderViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var portraitBackButton: UIButton!
    @IBOutlet weak var portraitDownloadButton: UIButton!
    @IBOutlet weak var portraitChatButton: UIButton!
    @IBOutlet weak var portraitPhotoButton: UIButton!
    @IBOutlet weak var portraitDownloadProgressView: UICircularProgressRing!
    @IBOutlet weak var portraitButtonsStackView: UIStackView!
    
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
    @IBOutlet weak var landscapeDownlaodProgressView: UICircularProgressRing!
    @IBOutlet weak var landscapeButtonsStackView: UIStackView!
    @IBOutlet weak var masechetTitleLabel: UILabel!
    
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
    
    private var lesson: JTLesson
    private var mediaType: JTLessonMediaType
    private var endTimeDisplayType: EndTimeDisplayMode = .duration
    private var sederId: String
    private var masechetId: String
    private var chapter: String?
    
    private var videoPlayerMode: VideoPlayerMode = .regular
    
    private let portraitHeaderViewAudioHeight: CGFloat = 100.0
    private let portraitHeaderViewVideoHeight: CGFloat = 53.0
    private let landscapeHeaderViewVideoWidth: CGFloat = 53.0
    
    private let audioPlayerPortraitWidth: CGFloat = 301.0
    private let audioPlayerLandscapeWidth: CGFloat = 600.0
    
    private let videoAspectRatio: CGFloat = 270/480
    
    private var activityView: ActivityView?
    
    private var didSetMediaUrl: Bool = false
    private var shouldStartPlay: Bool
    private var shouldDisplayDonationPopUp: Bool

    private var activityViewPortraitFrame: CGRect {
        let y = self.portraitHeaderView.frame.maxY
        return CGRect(x: 0, y: y, width: self.view.frame.width, height: self.view.frame.height - y)
    }
    
    private var activityViewLandscapeFrame: CGRect {
        let x = self.landscapeHeaderView.frame.maxX
        return CGRect(x: x, y: 0, width: self.view.frame.width - x, height: self.view.frame.height)
    }
    
    private var isLandscape: Bool {
        return UIScreen.main.bounds.height < UIScreen.main.bounds.width
    }
    var masechet = ""
    var daf = ""
    //====================================================
    // MARK: - LifeCycle
    //====================================================
    
    init(lesson: JTLesson, mediaType: JTLessonMediaType, sederId: String, masechetId: String, chapter: String?, shouldDisplayDonationPopUp: Bool = true) {
        self.lesson = lesson
        self.sederId = sederId
        self.masechetId = masechetId
        self.chapter = chapter
        self.mediaType = mediaType
        self.shouldDisplayDonationPopUp = shouldDisplayDonationPopUp
        self.shouldStartPlay = !shouldDisplayDonationPopUp
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
        self.user = UserRepository.shared.getCurrentUser()
        self.masechetTitleLabel.text = "\(self.masechet) \(self.daf)"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.shouldDisplayDonationPopUp {
            self.presentDonateAlert()
        }
        
        self.showActivityView()
        self.roundCorners()
        self.setPlayers()
        self.setShadows()
        self.setToolBar()
        self.setPortraitHeader()
        
        self.setPortraitHeaderViewHeight()
        self.setPortraitMode()

        self.pdfView.isOpaque = false
        self.pdfView.backgroundColor = UIColor.clear

        NotificationCenter.default.addObserver(self, selector: #selector(self.orientationDidChange(_:)), name: UIDevice.orientationDidChangeNotification, object: nil)
        ContentRepository.shared.addDelegate(self)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue(label: "player_loader", qos: .utility, attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil).async {
            self.loadPDF()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.audioPlayer.stopAndRelease()
        self.videoPlayer.stopAndRelease()
        self.postWatchAnalyticEvent()
        NotificationCenter.default.removeObserver(self)
        ContentRepository.shared.removeDelegate(self)
    }
    
    @objc func orientationDidChange(_ notification: Notification) {
        print(UIDevice.current.orientation.rawValue)
        print(self.view.frame)
        if self.isLandscape {
            self.setLandscapeMode()
        }
        else  {
            self.setPortraitMode()
        }
    }
    
    private func postWatchAnalyticEvent() {
        var watchDuration: TimeInterval!
        var category: AnalyticsEventCategory!
        var online: Bool!
        
        switch self.mediaType {
        case .audio:
            watchDuration = self.audioPlayer.watchDuration
            online = self.lesson.isAudioDownloaded
        case .video:
            watchDuration = self.videoPlayer.watchDuration
            online = self.lesson.isVideoDownloaded
        }
        
        if let _ = self.lesson as? JTGemaraLesson {
            category = .gemara
        }
        
        else if let _ = self.lesson as? JTMishnaLesson {
            category = .mishna
        }
        
        AnalyticsManager.shared.postEvent(eventType: .watch, category: category, mediaType: self.mediaType, lessonId: self.lesson.id, duration: Int64(watchDuration) * 1000, online: online) { (result: Result<Any, JTError>) in
            
        }
        guard var lessonWatched = JTLessonWatched(values: ["lessonId": lesson.id, "duration": watchDuration]) else { return }
        self.user?.lessonWatched.append(lessonWatched)
        UserRepository.shared.updateCurrentUser(self.user!)
        
    }
    //====================================================
    // MARK: - Setup
    //====================================================
    private func presentDonateAlert() {
        let alertVC = DonatedAlert()
        alertVC.modalTransitionStyle = .crossDissolve
        alertVC.delegate = self
        alertVC.modalPresentationStyle = .overFullScreen
        self.present(alertVC, animated: true, completion: nil)
    }
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
                maker.height.equalTo(self.videoPlayer.snp.width).multipliedBy(self.videoAspectRatio).offset(24.0)
            }
            self.videoPlayer.layer.cornerRadius = 0.0
            Utils.dropViewShadow(view: self.videoPlayer, shadowColor: UIColor.clear, shadowRadius: 0, shadowOffset: CGSize(width: 0.0, height: 12))
            
        case .small:
            self.videoPlayer.snp.makeConstraints { (maker: ConstraintMaker) in
                maker.bottom.equalTo(self.view.snp.bottom).inset(16.0)
                maker.centerX.equalToSuperview()
                maker.width.equalTo(386.0).priority(ConstraintPriority.high)
                maker.height.equalTo(69.0).priority(ConstraintPriority.high)
                maker.trailing.lessThanOrEqualTo(self.view.snp.trailing).inset(16.0).priority(ConstraintPriority.required)
                maker.leading.greaterThanOrEqualTo(self.view.snp.leading).offset(16.0).priority(ConstraintPriority.required)
            }
            self.videoPlayer.layer.cornerRadius = 15.0
            Utils.dropViewShadow(view: self.videoPlayer, shadowColor: Colors.playerShadowColor, shadowRadius: 36, shadowOffset: CGSize(width: 0.0, height: 12))
        }
        
        UIView.animate(withDuration: 0.4) {
            self.view.updateConstraints()
            self.view.layoutIfNeeded()
            
            if self.activityView != nil {
                self.activityView?.frame = self.activityViewPortraitFrame
            }
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
            
            if self.activityView != nil {
                self.activityView?.frame = self.activityViewLandscapeFrame
            }
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
    
//    private func getMasechetName()-> String {
//       let seders = ContentRepository.shared.getGemaraSeders()
//        for seder in seders {
//            for masechet in seder.masechtot{
//                 return masechet.name
//            }
//        }
//        return ""
//    }
    
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
    
    func setToolBar() {
        self.portraitButtonsStackView.alignment = .trailing
        self.landscapeButtonsStackView.alignment = .bottom
        
        switch self.mediaType {
        case .audio:
            if self.lesson.isDownloadingAudio {
                self.landscapeDownlaodProgressView.isHidden = false
                self.portraitDownloadProgressView.isHidden = false
                
                self.portraitDownloadButton.isHidden = true
                self.landscapeDownloadButton.isHidden = true
                
                let progress = lesson.audioDownloadProgress ?? 0.0
                self.portraitDownloadProgressView.value = CGFloat(progress*100)
                self.landscapeDownlaodProgressView.value = CGFloat(progress*100)
            }
            else {
                self.landscapeDownlaodProgressView.isHidden = true
                self.portraitDownloadProgressView.isHidden = true
                
                self.portraitDownloadButton.isHidden = self.lesson.isAudioDownloaded
                self.landscapeDownloadButton.isHidden = self.lesson.isAudioDownloaded
            }
            
        case .video:
            if self.lesson.isDownloadingVideo {
                self.landscapeDownlaodProgressView.isHidden = false
                self.portraitDownloadProgressView.isHidden = false
                
                self.portraitDownloadButton.isHidden = true
                self.landscapeDownloadButton.isHidden = true
                
                let progress = lesson.videoDownloadProgress ?? 0.0
                self.portraitDownloadProgressView.value = CGFloat(progress*100)
                self.landscapeDownlaodProgressView.value = CGFloat(progress*100)
            }
            else {
                self.landscapeDownlaodProgressView.isHidden = true
                self.portraitDownloadProgressView.isHidden = true
                
                self.portraitDownloadButton.isHidden = self.lesson.isVideoDownloaded
                self.landscapeDownloadButton.isHidden = self.lesson.isVideoDownloaded
            
            }
            
        }
        
        self.disableHeaderButtons()
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
    
    private func disableHeaderButtons() {
        self.portraitDownloadButton.isEnabled = false
        self.landscapeDownloadButton.isEnabled = false
        
        self.portraitChatButton.isEnabled = false
        self.landscapeChatButton.isEnabled = false
        
        self.portraitPhotoButton.isEnabled = false
        self.landscapePhotoButton.isEnabled = false
        
        self.audioSlider.isEnabled = false
        self.audioEndTimeButton.isEnabled = false
    }
    
    private func enableHeaderButtons() {
        switch self.mediaType {
        case .audio:
            self.portraitDownloadButton.isEnabled = !self.lesson.isDownloadingVideo
            self.landscapeDownloadButton.isEnabled = !self.lesson.isDownloadingVideo
        case .video:
            self.portraitDownloadButton.isEnabled = !self.lesson.isDownloadingAudio
            self.landscapeDownloadButton.isEnabled = !self.lesson.isDownloadingAudio
        }
        
        
        self.portraitChatButton.isEnabled = true
        self.landscapeChatButton.isEnabled = true
        
        self.portraitPhotoButton.isEnabled = true
        self.landscapePhotoButton.isEnabled = true
        
        self.audioSlider.isEnabled = true
        self.audioEndTimeButton.isEnabled = true
    }
    //====================================================
    // MARK: - Content setup
    //====================================================
    
    private func loadPDF() {
        guard let pdfUrl = self.lesson.textURL else { return }
        if let pdfDocument = PDFDocument(url: pdfUrl) {
            DispatchQueue.main.async {
                self.pdfView.document = pdfDocument
                self.pdfView.autoScales = true
                self.setMediaURL(startPlaying: self.shouldStartPlay)
            }
        }
    }
    
    private func setMediaURL(startPlaying: Bool) {
        switch self.mediaType {
        case .video:
            if let url = self.lesson.videoURL {
                self.videoPlayer.setVideoUrl(url, startPlaying: startPlaying)
            }
        case .audio:
            if let url = self.lesson.audioURL {
                self.audioPlayer.setAudioUrl(url, startPlaying: startPlaying, mediaName: "")
            }
        }
        self.didSetMediaUrl = true
    }
    //====================================================
    // MARK: - @IBActions
    //====================================================
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func downloadButtonPressed(_ sender: UIButton) {
        
        self.portraitDownloadButton.isHidden = true
        self.landscapeDownloadButton.isHidden = true
        
        self.portraitDownloadProgressView.isHidden = false
        self.landscapeDownlaodProgressView.isHidden = false

        ContentRepository.shared.downloadLesson(lesson, mediaType: self.mediaType, delegate: ContentRepository.shared)
        
        ContentRepository.shared.lessonStartedDownloading(self.lesson.id, mediaType: self.mediaType)
        
    }
    
    @IBAction func photoButtonPressed(_ sender: UIButton) {
        Utils.showAlertMessage(Strings.inDevelopment, viewControler: self)
    }
    
    @IBAction func chatButtonPressed(_ sender: UIButton) {
        Utils.showAlertMessage(Strings.inDevelopment, viewControler: self)

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
                let frame = self.isLandscape ? self.activityViewLandscapeFrame : self.activityViewPortraitFrame
                self.activityView = Utils.showActivityView(inView: self.view, withFrame: frame, text: nil)
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
        self.enableHeaderButtons()
        self.removeActivityView()
    }
    
    func didFinishPlaying() {
        
    }
    
    
}


extension LessonPlayerViewController: ContentRepositoryDownloadDelegate {
    func downloadCompleted(downloadId: Int, mediaType: JTLessonMediaType) {        
        self.portraitDownloadProgressView.isHidden = true
        self.landscapeDownlaodProgressView.isHidden = true
        switch self.mediaType {
        case .audio:
            self.setMediaURL(startPlaying: self.audioPlayer.isPlaying)
        case .video:
            self.setMediaURL(startPlaying: self.videoPlayer.isPlaying)
        }
        
    }
    
    func downloadProgress(downloadId: Int, progress: Float, mediaType: JTLessonMediaType) {
        if downloadId == self.lesson.id {
            self.portraitDownloadProgressView.value = CGFloat(progress*100)
            self.landscapeDownlaodProgressView.value = CGFloat(progress*100)
        }
    }
}

extension LessonPlayerViewController: DonatedAlertDelegate {
    func didDismiss() {
//        self.visualEffectView.isHidden = true
        if self.didSetMediaUrl == false {
            self.shouldStartPlay = true
        }
        else {
            switch self.mediaType {
            case .video:
                let _ = self.videoPlayer.play()
            case .audio:
                let _ = self.audioPlayer.play()
            }
        }
    }
}
