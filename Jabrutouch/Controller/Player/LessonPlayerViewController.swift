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
    
    // send message header view
    @IBOutlet weak var buttonsContainer: UIView!
    @IBOutlet weak var messageHeaderView: UIView!
    @IBOutlet weak var cancelMessageButton: UIButton!
    
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
    
    var watchDuration: TimeInterval!
    var gallery: [String] = []
    var videoParts: [String] = []
    private var lessonWatched: [JTLessonWatched] = []
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
    var lessonParts: [Double] = []
    var textingMode: Bool = false
    var donationAllertData: JTDonated?
    
    var crownId: Int?
    var withDonation = false
    
    private lazy var chatControlsView: ChatControlsView = {
        var view = ChatControlsView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 70))
        
        return view
    }()
    
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
        self.setupWatchAnalistic()
        !lesson.isAudioDownloaded && !lesson.isVideoDownloaded ? self.getDonorText() : self.getDonorDownloadText()
        self.messageHeaderView.isHidden = true
        self.chatControlsView.delegate = self
        self.pdfView.delegate = self
        self.user = UserRepository.shared.getCurrentUser()
        self.masechetTitleLabel.text = "\(self.masechet) \(self.daf)"
        for image in self.lesson.gallery {
            self.gallery.append(image.imageLink)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //        if self.shouldDisplayDonationPopUp {
        //            self.presentDonateAlert()
        //        }
        self.lessonWatched = UserDefaultsProvider.shared.lessonWatched
        self.showActivityView()
        self.roundCorners()
        self.setPlayers()
        self.setShadows()
        self.setToolBar()
        self.setPortraitHeader()
        
        self.setPortraitHeaderViewHeight()
        self.setPortraitMode()
        self.setUpGallery()
        self.pdfView.isOpaque = false
        self.pdfView.backgroundColor = UIColor.clear
        self.setProgressRing()
        NotificationCenter.default.addObserver(self, selector: #selector(self.orientationDidChange(_:)), name: UIDevice.orientationDidChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.applicationWillTerminate(_:)), name: UIApplication.willTerminateNotification, object: nil)
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
        let analisticEvent = self.createLessonAnalisticEvent()
        self.saveLessonLocation()
        self.postWatchAnalyticEvent(event: analisticEvent)
        NotificationCenter.default.removeObserver(self)
        ContentRepository.shared.removeDelegate(self)
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override var inputAccessoryView: UIView? {
        if self.textingMode {
            return self.chatControlsView
        } else {
            return nil
        }
    }
    
    @objc func orientationDidChange(_ notification: Notification) {
        print("orientationDidChange, userInfo: \(notification.userInfo ?? [:])")
        print(UIDevice.current.orientation.rawValue)
        print(self.view.frame)
        print(self.videoPlayer.slider.frame)
        if self.isLandscape {
            self.setLandscapeMode()
        }
        else  {
            self.setPortraitMode()
        }
    }
    
    @objc func applicationWillTerminate(_ notification: Notification) {
        self.audioPlayer.stopAndRelease()
        self.videoPlayer.stopAndRelease()
        UserDefaultsProvider.shared.lessonAnalitics = createLessonAnalisticEvent()
    }
    
    private func setupWatchAnalistic(){
        guard let watchAnalitics = UserDefaultsProvider.shared.lessonAnalitics else { return }
        self.postWatchAnalyticEvent(event: watchAnalitics)
    }
    
    private func createLessonAnalisticEvent()-> JTLessonAnalitics{
        var category: AnalyticsEventCategory!
        var online: Bool!
        
        switch self.mediaType {
        case .audio:
            self.watchDuration = self.audioPlayer.watchDuration
            online = self.lesson.isAudioDownloaded
        case .video:
            self.watchDuration = self.videoPlayer.watchDuration
            online = self.lesson.isVideoDownloaded
        }
        
        if let _ = self.lesson as? JTGemaraLesson {
            category = .gemara
        }
            
        else if let _ = self.lesson as? JTMishnaLesson {
            category = .mishna
        }
        
        return JTLessonAnalitics(eventType: .watch, category: category, mediaType: self.mediaType, lessonId: self.lesson.id, duration: Int64(watchDuration) * 1000, online: online)
        
    }
    
    private func postWatchAnalyticEvent(event: JTLessonAnalitics?) {
        guard let event = event else { return }
        if event.duration > 0 {
            AnalyticsManager.shared.postEvent(eventType: event.eventType, category: event.category, mediaType: event.mediaType, lessonId: event.lessonId, duration: event.duration, online: event.online, completion:{ result in
                switch result {
                case .success:
                    UserDefaultsProvider.shared.lessonAnalitics = nil
                case.failure:
                    print("post watch analitics event faild.")
                }
            })
        } else {
            UserDefaultsProvider.shared.lessonAnalitics = nil
        }
    }
    
    private func saveLessonLocation() {
        if self.watchDuration > 0.0 {
            
            var watchLocation: TimeInterval!
            switch self.mediaType {
            case .audio:
                watchLocation = self.audioPlayer.watchLocation
            case .video:
                watchLocation = self.videoPlayer.watchLocation
            }
            var lessonWatchedList = UserDefaultsProvider.shared.lessonWatched
            for (index, _lesson) in lessonWatchedList.enumerated() {
                if _lesson.lessonId == lesson.id{
                    lessonWatchedList[index].duration = watchLocation ?? 0.0
                    UserDefaultsProvider.shared.lessonWatched = lessonWatchedList
                    return
                }
            }
            let values = ["lessonId": lesson.id, "duration": watchLocation ?? 0.0] as [String : Any]
            guard let lessonWatched = JTLessonWatched(values: values) else { return }
            lessonWatchedList.append(lessonWatched)
            UserDefaultsProvider.shared.lessonWatched = lessonWatchedList
        }
    }
    //====================================================
    // MARK: - Setup
    //====================================================
    
    func getDonorDownloadText() {
        var isGemara = false
        var newArray = [LessonDonationResponse]()
        if let _ = self.lesson as? JTGemaraLesson {isGemara = true}
        guard let userDefaultLessonDonations = UserDefaultsProvider.shared.lessonDonation else { return }
        
        for lessonDonation in userDefaultLessonDonations {
            
            if lessonDonation.isGemara == isGemara &&
                lessonDonation.lessonId == self.lesson.id &&
                lessonDonation.donatedBy.count > 0 {
                self.donationAllertData = lessonDonation.copy().donatedBy[0]
                self.shouldDisplayDonationPopUp = true
                self.shouldStartPlay = false
                    DispatchQueue.main.async {
                        self.presentDonateAlert()
                    }
            } else {
                newArray.append(lessonDonation)
            }
        }
        UserDefaultsProvider.shared.lessonDonation = newArray
        
    }
    
    func getDonorText() {
        var isGemara = false
        if let _ = self.lesson as? JTGemaraLesson {isGemara = true}
        let downloaded = lesson.isAudioDownloaded || lesson.isVideoDownloaded
        DonationManager.shared.getDonationAllertData(lessonId:lesson.id, isGemara: isGemara, downloaded: downloaded) { (result) in
            switch result {
            case .success(let response):
                
                if response.donatedBy.count > 0 {
                    if let crown_Id = response.crownId {
                        self.crownId = crown_Id
                    }
                    self.donationAllertData = response.donatedBy[0]
                    if self.shouldDisplayDonationPopUp {
                        if !(self.donationAllertData?.dedicationText == "" &&
                            self.donationAllertData?.firstName == "" &&
                            self.donationAllertData?.lastName == "") {
                            DispatchQueue.main.async {
                                self.presentDonateAlert()
                            }
                        } else {
                            self.didDismiss(withDonation: true)
                        }
                    }
                } else {
                    self.didDismiss(withDonation: true)
//                    if self.shouldDisplayDonationPopUp {
//                        DispatchQueue.main.async {
//                            self.presentNotDonateAlert()
//                        }
//                    }
                }
                
            case .failure(let error):
                let title = Strings.error
                let message = error.message
                Utils.showAlertMessage(message, title: title, viewControler: self)
                
            }
        }
    }
    
    private func setProgressRing() {
        let startColor: UIColor = UIColor(red: 0.3, green: 0.31, blue: 0.82, alpha: 1)
        let endColor: UIColor = UIColor(red: 1, green: 0.37, blue: 0.31, alpha: 1)
        
        self.portraitDownloadProgressView.gradientOptions = UICircularRingGradientOptions(startPosition: .topRight,
                                                                                          endPosition: .bottomRight,
                                                                                          colors: [startColor, endColor],
                                                                                          colorLocations: [0.1, 1])
    }
    
    private func setUpGallery() {
        DispatchQueue.main.async {
            if self.lesson.gallery.count > 0 {
                self.portraitPhotoButton.tintColor = #colorLiteral(red: 1, green: 0.373, blue: 0.314, alpha: 1)
            } else {
                self.portraitPhotoButton.tintColor = #colorLiteral(red: 0.286, green: 0.286, blue: 0.286, alpha: 1)
            }
        }
    }
    
    func setLessonParts(parts: [Double], view: UIView, width: CGFloat, height:CGFloat, sender: String) {
        for subView in view.subviews {
            if subView is JBView {
                subView.removeFromSuperview()
            }
        }
        if sender == "audio" {
            for part in self.lessonParts {
                
                let customView = JBView()
                let y = view.bounds.midY - height
                let x = CGFloat((part / self.audioPlayer.duration) * Double(view.bounds.width))
                customView.frame = CGRect.init(x: x, y: y, width: width, height: height)
                customView.backgroundColor = #colorLiteral(red: 1, green: 0.817, blue: 0.345, alpha: 0.66)
                view.addSubview(customView)
            }
        }
        else if sender == "video" {
            for part in self.lessonParts {
                
                let customView = JBView()
                let y = view.bounds.midY - height
                let x = CGFloat((part / self.videoPlayer.duration) * Double(view.bounds.width))
                customView.frame = CGRect.init(x: x, y: y, width: width, height: height)
                customView.backgroundColor = #colorLiteral(red: 1, green: 0.817, blue: 0.345, alpha: 0.66)
                view.addSubview(customView)
            }
        }
        else if sender == "videoSmall" {
            for part in self.lessonParts {
                
                let customView = JBView()
                let x = CGFloat((part / self.videoPlayer.duration) * Double(view.bounds.width))
                customView.frame = CGRect.init(x: x, y: 0.0, width: width, height: height)
                customView.backgroundColor = #colorLiteral(red: 0.178, green: 0.168, blue: 0.663, alpha: 0.5)
                view.addSubview(customView)
            }
        }
    }
    
    private func initLessonParts() {
        switch self.mediaType {
        case .audio:
            DispatchQueue.main.async {
                if self.lesson.videoPart.count > 0 {
                    for part in self.lesson.videoPart {
                        if let part = Double(part.videoPart) {
                            self.lessonParts.append(part)
                        }
                        self.setLessonParts(parts: self.lessonParts, view: self.audioSlider, width: 4, height: 6, sender: "audio")
                    }
                }
            }
        case .video:
            DispatchQueue.main.async {
                if self.lesson.videoPart.count > 0 {
                    self.videoPlayer.setVideoPartsUI()
                    for part in self.lesson.videoPart {
                        if let part = Double(part.videoPart){
                            self.lessonParts.append(part)
                        }
                        self.setLessonParts(parts: self.lessonParts, view: self.videoPlayer.slider, width: 4, height: 16, sender: "video")
                    }
                    self.videoPlayer.videoParts = self.lessonParts
                }
            }
        }
    }
    
    private func presentDonateAlert() {
        guard let donationData = self.donationAllertData else { return }
        
        let alertVC = DonatedAlert()
        alertVC.modalTransitionStyle = .crossDissolve
        alertVC.delegate = self
        if donationData.dedicationTemplateText != "" {
            alertVC.dedicationText = donationData.dedicationTemplateText
            alertVC.dedicationNameText = donationData.dedicationText
        }
        if (donationData.dedicationTemplateText.isEmpty && donationData.dedicationText.isEmpty) {
            //            alertVC.dedicationText.
            //            alertVC.dedicationNameText
        }
        if donationData.nameToRepresent != "" {
            alertVC.nameText = donationData.nameToRepresent
        } else {
            alertVC.nameText = "\(donationData.firstName) \(donationData.lastName)"
        }
        alertVC.locationText = donationData.country
        alertVC.modalPresentationStyle = .overFullScreen
        self.present(alertVC, animated: true, completion: nil)
    }
    
    private func presentNotDonateAlert() {
        let alertVC = NotDonateAlert()
        alertVC.delegate = self
        alertVC.modalTransitionStyle = .crossDissolve
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
        
        // Set lesson parts
        switch self.mediaType {
        case .audio:
            self.setLessonParts(parts: self.lessonParts, view: self.audioSlider, width: 4, height: 6, sender: "audio")
        case .video:
            switch self.videoPlayerMode {
            case .fullScreen:
                self.setLessonParts(parts: self.lessonParts, view: self.videoPlayer.slider, width: 4, height: 16, sender: "video")
            case .regular:
                self.setLessonParts(parts: self.lessonParts, view: self.videoPlayer.slider, width: 4, height: 16, sender: "video")
            case .small:
                self.setLessonParts(parts: self.lessonParts, view: self.videoPlayer.videoProgressBar, width: 4, height: 4, sender: "videoSmall")
            }
        }
        
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
        
        // Set lesson parts
        switch self.mediaType {
        case .audio:
            self.setLessonParts(parts: self.lessonParts, view: self.audioPlayer.slider, width: 4, height: 6, sender: "audio")
        case .video:
            switch self.videoPlayerMode {
            case .fullScreen:
                self.setLessonParts(parts: self.lessonParts, view: self.videoPlayer.slider, width: 4, height: 16, sender: "video")
            case .regular:
                self.setLessonParts(parts: self.lessonParts, view: self.videoPlayer.slider, width: 4, height: 16, sender: "video")
            case .small:
                self.setLessonParts(parts: self.lessonParts, view: self.videoPlayer.videoProgressBar, width: 4, height: 4, sender: "videoSmall")
            }
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
            if let image = Utils.linearGradientImage(endXPoint: self.audioPlayer.currentTime, size: self.audioSlider.frame.size, colors: [Colors.appBlue, Colors.appOrange]) {
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
        let endXPoint =  self.audioPlayer.currentTime / self.audioPlayer.duration
        if let image = Utils.linearGradientImage(endXPoint: endXPoint, size: self.audioSlider.frame.size, colors: [Colors.appBlue, Colors.appOrange]) {
            self.audioSlider.setMinimumTrackImage(image, for: .normal)
        }
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
        
        //        self.portraitChatButton.tintColor = #colorLiteral(red: 0.286, green: 0.286, blue: 0.286, alpha: 1)
        
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
            DispatchQueue.main.async { [weak self] in
                self?.pdfView.document = pdfDocument
                self?.pdfView.autoScales = true
                self?.setMediaURL(startPlaying: self?.shouldStartPlay ?? true)
                self?.maHaytaHadeke()
                self?.initLessonParts()
            }
        }
    }
    
    private func maHaytaHadeke(){
        if self.lessonWatched.count > 0 {
            for _lesson in self.lessonWatched {
                if _lesson.lessonId == self.lesson.id {
                    let percentage = _lesson.duration / Double(self.lesson.duration)
                    self.audioPlayer.seek(percentage: percentage)
                    self.videoPlayer.seek(percentage: percentage)
                }
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
    
    func startTextinfMode() {
        self.buttonsContainer.isHidden = true
        self.messageHeaderView.isHidden = false
        switch self.mediaType {
        case .video:
            let _ = self.videoPlayer.pause()
            UIView.animate(withDuration: 0.3) {
                self.pdfViewTopConstraint.constant = self.messageHeaderView.bounds.height
                self.videoPlayer.isHidden = true
                self.view.layoutIfNeeded()
            }
        case .audio:
            let _ = self.audioPlayer.pause()
        }
        
        self.textingMode = true
        self.becomeFirstResponder()
        self.reloadInputViews()
        self.chatControlsView.inputTextView.becomeFirstResponder()
        
    }
    
    func stopTextingMode() {
        self.textingMode = false
        self.reloadInputViews()
        self.chatControlsView.inputTextView.resignFirstResponder()
        self.buttonsContainer.isHidden = false
        self.messageHeaderView.isHidden = true
        switch self.mediaType {
        case .video:
            let _ = self.videoPlayer.play()
            UIView.animate(withDuration: 0.3) {
                let screenWidth = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
                self.pdfViewTopConstraint.constant = self.portraitHeaderViewVideoHeight + screenWidth * self.videoAspectRatio
                self.videoPlayer.isHidden = false
                self.view.layoutIfNeeded()
            }
        case .audio:
            let _ = self.audioPlayer.play()
        }
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
        if self.gallery.count > 0 {
            let galleryViewController = Storyboards.Gallery.galleryViewController
            galleryViewController.images = self.gallery
            galleryViewController.modalTransitionStyle = .crossDissolve
            galleryViewController.modalPresentationStyle = .overFullScreen
            self.present(galleryViewController, animated: true)
        }
    }
    
    @IBAction func chatButtonPressed(_ sender: UIButton) {
        self.startTextinfMode()
    }
    
    @IBAction func cancelMessageButtonPressed(_ sender: Any) {
        self.stopTextingMode()
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
    
    
    func AudioSendLikeAfter30seconds() {
        self.sendLike()
    }
    
    func videoSendLikeAfter30seconds() {
        self.sendLike()
    }
    
    
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
    
    func sendLike() {
        if self.withDonation {
            var isGemara = false
            if let _ = self.lesson as? JTGemaraLesson {
                isGemara = true
            }
            DonationManager.shared.createLike(lessonId: self.lesson.id, isGemara: isGemara, crownId: self.crownId ?? 0) { (result) in
                switch result {
                case .success(let response):
                    print(response)
                case .failure(let error):
                    print(error)
                }
            }
        }

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
            //            self.portraitDownloadProgressView.gradientColors = [Colors.appBlue, Colors.appOrange]
            self.portraitDownloadProgressView.value = CGFloat(progress*100)
            self.landscapeDownlaodProgressView.value = CGFloat(progress*100)
        }
    }
}

extension LessonPlayerViewController: DonatedAlertDelegate {
    
    
    func didDismiss(withDonation: Bool) {
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
        if withDonation {
            self.withDonation = true
        }
    }
    
}

extension LessonPlayerViewController: ChatControlsViewDelegate {
    
    func recordSavedInS3(_ fileName: String) {
        self.createMessage(fileName, MessageType.voice)
    }
    
    func sendVoiceMessageButtonTouchUp(_ fileName: String) {
        self.stopTextingMode()
        self.setMediaURL(startPlaying: true)
        //        self.createMessage(fileName, MessageType.voice)
    }
    
    func sendTextMessageButtonPressed() {
        self.stopTextingMode()
        if let text = self.chatControlsView.inputTextView.text {
            self.createMessage(text, MessageType.text)
        }
    }
    
    func textViewChanged() {}
    
    func createMessage(_ text: String, _ type: MessageType){
        var gemara = true
        var title = "ask the rabbi: \(self.masechet) "
        if let _ = self.lesson as? JTGemaraLesson {
            title += self.daf
        }else{
            title += "\(self.chapter ?? ""), \(self.daf)"
            gemara = false
        }
        guard let toUser = self.lesson.presenter?.id else{ return }
        
        MessagesRepository.shared.sendMessage( message: text,  sentAt: Date(), title: title, messageType: type.rawValue, toUser: toUser, chatId: nil, lessonId: self.lesson.id, gemara: gemara, linkTo: nil, completion:  { (result) in
            print("result",result)
            switch result{
            case .success(let data):
                let recordUrl = data.message.message.components(separatedBy: "/")
                data.message.title = title
                data.message.message = recordUrl[recordUrl.count-1]
                MessagesRepository.shared.saveMessageInDB(message: data.message)
                print("success", data.message.chatId)
            case .failure(_):
                print("error")
            }
        })
    }
    
}
