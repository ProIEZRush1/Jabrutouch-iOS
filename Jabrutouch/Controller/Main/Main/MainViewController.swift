//בעזת ה׳ החונן לאדם דעת
//  MainViewController.swift
//  Jabrutouch
//
//  Created by Yoni Reiss on 18/07/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

enum MainModal {
    case downloads
    case gemara
    case mishna
    case donations
    
}

protocol MainModalDelegate : class {
    func dismissMainModal()
    func presentAllGemara()
    func presentAllMishna()
}

class MainViewController: UIViewController, MainModalDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource {
    
    //========================================
    // MARK: - Properties
    //========================================
    
    private var modalsPresentingVC: ModalsContainerViewController!
    private var currentPresentedModal: MainModal?
    private var gemaraHistory: [JTGemaraLessonRecord] = []
    private var mishnaHistory: [JTMishnaLessonRecord] = []
    private var gemaraMishnaHistory: [Any] = []
    private var lessonWatched: [JTLessonWatched] = []
    
    private var contentAvailable: Bool {
        return self.gemaraHistory.count > 0 || self.mishnaHistory.count > 0
    }
    
    private var activityView: ActivityView?
    var user : JTUser?
    var firstOnScreen = true
    var singlePayment = false
    var pressEnable = appDelegate.isInternetConenect
    
    var latestNewsItemsList: [JTNewsFeedItem] = []
    
    //========================================
    // MARK: - @IBOutlets
    //========================================
    
    // Main Containers
    @IBOutlet weak private var mainContainer: UIView!
    @IBOutlet weak private var modalsContainer: UIView!
    
    // Header View
    @IBOutlet weak var headerContainer: UIView!
    @IBOutlet weak private var menuButton: UIButton!
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var messagesButton: UIButton!
    @IBOutlet weak private var unReadedLable: UILabel!
    
    // Welcome Views
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var welcomeImage: UIImageView!
    
    // Scroll View
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var todaysDafToWelcomeImageTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var todaysDafToScrollviewContentTopConstraint: NSLayoutConstraint!
    
    // Todays Daf Yomi
    @IBOutlet weak private var todaysDafProgressBar: JBProgressBar!
    @IBOutlet weak private var todaysDafOuterContainer: UIView!
    @IBOutlet weak private var todaysDafInnerContainer: UIView!
    @IBOutlet weak private var todaysDafTitleLabel: UILabel!
    @IBOutlet weak private var todaysDafLabel: UILabel!
    @IBOutlet weak private var todaysDateLabel: UILabel!
    @IBOutlet weak var todaysDafAudio: UIButton!
    @IBOutlet weak var todaysDafVideo: UIButton!
    @IBOutlet weak var shadaysDafShadowView: UIView!
    
    // Recents
    @IBOutlet weak var recentsGemaraAndMishnaLabel: UILabel!
    
    // TableView
    @IBOutlet weak var latestNewsTableView: UITableView!
    @IBOutlet weak var latestNewsTableViewHeightConstraint: NSLayoutConstraint!
    
    // More News Button
    @IBOutlet weak var viewMoreNewsButton: UIButton!
    
    // Tab bar buttons
    @IBOutlet weak private var downloadsImageView: UIImageView!
    @IBOutlet weak private var downloadsLabel: UILabel!
    @IBOutlet weak private var downloadsButton: UIButton!
    
    @IBOutlet weak private var gemaraImageView: UIImageView!
    @IBOutlet weak private var gemaraLabel: UILabel!
    @IBOutlet weak private var gemaraButton: UIButton!
    
    @IBOutlet weak private var mishnaImageView: UIImageView!
    @IBOutlet weak private var mishnaLabel: UILabel!
    @IBOutlet weak private var mishnaButton: UIButton!
    
    @IBOutlet weak private var donationsImageView: UIImageView!
    @IBOutlet weak private var donationsLabel: UILabel!
    @IBOutlet weak private var donationsButton: UIButton!
    
    // Recent Mishna & Gemara CollectionViews
    @IBOutlet weak var recentsGemaraAndMishnaCollectionView: UICollectionView!
    
    //========================================
    // MARK: - LifeCycle
    //========================================
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.portrait]
    }
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setStrings()
        self.roundCorners()
        self.setShadows()
        UserDefaultsProvider.shared.notFirstTime = true
        self.setButtonsBackground()
        CoreDataManager.shared.delegate = self
        self.user = UserRepository.shared.getCurrentUser()
        self.setNewsTableViewDelegate()

        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        CoreDataManager.shared.delegate = self
        self.setTodaysDafProgressBar()
        self.lessonWatched = UserDefaultsProvider.shared.lessonWatched
        self.setContent()
        let unReded = CoreDataManager.shared.getUnReadedChats()
        self.setUnReadedIcon(unReded)
        //        self.setDefaulteIcons()
        setView()
        self.firstOnScreen ? self.getPopup() : self.presentFiestaAlert()
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(internetConnect(_:)), name: NSNotification.Name(rawValue: "InternetConnect"), object: nil)
        nc.addObserver(self, selector: #selector(internetNotConnect(_:)), name: NSNotification.Name(rawValue: "InternetNotConnect"), object: nil)
        /// refresh latestNews here so it refreshes on returning from other screens that aren't in the modal container.
        self.getLatestNewsItems()

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
        
        // MARK: TODO - shut news audio when goes into background - refresh here is temporary hack.
        self.latestNewsTableView.reloadData()

    }
    
    @objc func applicationDidEnterBackground() {
        self.latestNewsTableView.reloadData()
    }
    
    @objc func internetConnect(_ notification:Notification) {
        self.pressEnable = appDelegate.isInternetConenect
        DispatchQueue.main.async {
            self.setButtonsBackground()
            self.recentsGemaraAndMishnaCollectionView.reloadData()
        }
    }
    
    @objc func internetNotConnect(_ notification:Notification) {
        self.pressEnable = appDelegate.isInternetConenect
        DispatchQueue.main.async {
            self.setButtonsBackground()
            self.recentsGemaraAndMishnaCollectionView.reloadData()
        }
    }
    
    //========================================
    // MARK: - Setup
    //========================================
    private func setUnReadedIcon(_ unReded :Int){
        DispatchQueue.main.async {
            if unReded > 0  {
                self.unReadedLable.layer.cornerRadius = self.unReadedLable.bounds.height / 2
                self.unReadedLable.clipsToBounds = true
                self.unReadedLable.text = "\(unReded)"
                
            }else{
                self.unReadedLable.isHidden = true
            }
        }
    }
    
    
    private func setTodaysDafProgressBar() {
        let todaysDaf = DafYomiRepository.shared.getTodaysDaf()
        guard let data = ContentRepository.shared.getMasechetByName(todaysDaf.masechet) else { return }
        ContentRepository.shared.getGemaraLesson(masechetId: data.masechet.id, page: todaysDaf.daf) { (result: Result<JTGemaraLesson, JTError>) in
            switch result {
            case .success(let lesson):
                for lessonWatched in self.lessonWatched {
                    if lessonWatched.lessonId == lesson.id {
                        let count = lessonWatched.duration / Double(lesson.duration)
                        Utils.setProgressbar(count: count, view: self.todaysDafProgressBar, rounded: false, cornerRadius: 0, bottomRadius: true)
                        break
                    }
                }
            case .failure:
                break
            }
        }
    }
    
    private func setStrings() {
        
        // Todays daf
        self.todaysDafTitleLabel.text = Strings.todaysDafYomi.uppercased()
        self.todaysDafLabel.text = DafYomiRepository.shared.getTodaysDaf().displayString
        let calendar = Calendar(identifier: .hebrew)
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = calendar
        dateFormatter.locale = Locale(identifier: "es_ES")
        dateFormatter.setLocalizedDateFormatFromTemplate("d MMMM YYYY")
        self.todaysDateLabel.text = dateFormatter.string(from: Date())
        self.recentsGemaraAndMishnaLabel.text = Strings.recentsGemaraAndMishna
        
        // Main tabs
        self.downloadsLabel.text = Strings.downloads
        self.gemaraLabel.text = Strings.gemara
        self.mishnaLabel.text = Strings.mishna
        self.donationsLabel.text = Strings.donations
        //        self.titleLabel.text = Strings.jabrutouch
        self.welcomeLabel.text = Strings.welcomeToNewJabrutouch
    }
    
    private func roundCorners() {
        self.todaysDafInnerContainer.layer.cornerRadius = 15
        self.shadaysDafShadowView.layer.cornerRadius = 15
    }
    
    private func setShadows() {
        let shadowOffset = CGSize(width: 0.0, height: 12)
        Utils.dropViewShadow(view: self.shadaysDafShadowView, shadowColor: Colors.shadowColor, shadowRadius: 36, shadowOffset: shadowOffset)
    }
    
    private func setView() {
        welcomeLabel.isHidden = self.contentAvailable
        welcomeImage.isHidden = self.contentAvailable
        recentsGemaraAndMishnaLabel.isHidden = !self.contentAvailable
                
        if !self.contentAvailable {
//            todaysDafToWelcomeImageTopConstraint?.isActive = true
//            todaysDafToScrollviewContentTopConstraint?.isActive = false

        } else {

            todaysDafToWelcomeImageTopConstraint?.isActive = false
            todaysDafToScrollviewContentTopConstraint?.isActive = true
        }
        
        self.view.layoutIfNeeded()
    }
        
    private func setContent() {
        self.gemaraHistory = ContentRepository.shared.lastWatchedGemaraLessons
        self.mishnaHistory = ContentRepository.shared.lastWatchedMishnaLessons
        self.gemaraMishnaHistory.append(contentsOf: gemaraHistory)
        self.gemaraMishnaHistory.append(contentsOf: mishnaHistory)
        //MARK: TODO: sort history - problem is they don't have the study date
        self.recentsGemaraAndMishnaCollectionView.reloadData()
    }
    
    private func setDefaulteIcons() {
        self.downloadsImageView.image = #imageLiteral(resourceName: "DownloadsNatural")
        self.gemaraImageView.image = #imageLiteral(resourceName: "GemaraNatural")
        self.mishnaImageView.image = #imageLiteral(resourceName: "MishnaNatural")
        self.donationsImageView.image = #imageLiteral(resourceName: "Donations")
        self.downloadsLabel.textColor = #colorLiteral(red: 0.4734545946, green: 0.6921172738, blue: 0.9352924824, alpha: 1)
        self.gemaraLabel.textColor = #colorLiteral(red: 0.4734545946, green: 0.6921172738, blue: 0.9352924824, alpha: 1)
        self.mishnaLabel.textColor = #colorLiteral(red: 0.4734545946, green: 0.6921172738, blue: 0.9352924824, alpha: 1)
        self.donationsLabel.textColor = #colorLiteral(red: 0.4734545946, green: 0.6921172738, blue: 0.9352924824, alpha: 1)
    }
    
    func setButtonsBackground() {
        if self.pressEnable {
            self.todaysDafAudio.setImage(#imageLiteral(resourceName: "audio-nat"), for: .normal)
            self.todaysDafAudio.setImage(#imageLiteral(resourceName: "audio-prs"), for: .highlighted)
            
            self.todaysDafVideo.setImage(#imageLiteral(resourceName: "video-nat"), for: .normal)
            self.todaysDafVideo.setImage(#imageLiteral(resourceName: "video-prs"), for: .highlighted)
            
            self.todaysDafAudio.isHidden = false
            self.todaysDafVideo.isHidden = false
        } else {
            self.todaysDafAudio.isHidden = true
            self.todaysDafVideo.isHidden = true
            
        }
        
    }
    
    func setNewsTableViewDelegate() {
        self.latestNewsTableView.delegate = self
        self.latestNewsTableView.dataSource = self
    }
    
    fileprivate func getLatestNewsItems() {
        NewsFeedRepository.shared.getLatestNewsItems() { latestNewsItemsResponse in
            self.latestNewsItemsList = latestNewsItemsResponse
            DispatchQueue.main.async {
                ///since tableView is inside a scrollview, and we only want the scrollview to scroll, we set the tableview to be NOT scrollable, and after reloadData() set tableView height to contentSize height
                self.latestNewsTableView.reloadData()
                self.view.layoutIfNeeded()
                self.latestNewsTableViewHeightConstraint.constant = self.latestNewsTableView.contentSize.height
                self.view.layoutIfNeeded()
                self.scrollView.reloadInputViews()
            }
        }
    }
    
    private func setAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
        }
        catch {
            print("Setting category to AVAudioSessionCategoryPlayback failed.")
        }
    }
    
    //========================================
    // MARK: - Collection Views
    //========================================
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return gemaraMishnaHistory.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "mainCollectionCell",
                                                            for: indexPath) as? MainCollectionCellViewController else { return UICollectionViewCell() }
            if let lessonRecord = gemaraMishnaHistory[indexPath.row] as? JTGemaraLessonRecord {
                
            

            cell.masechetLabel.text = lessonRecord.masechetName
            cell.chapterLabel.text = nil
            cell.mishnaOrGemaraLabel.text = Strings.gemaraCapitalized
            cell.isGemara = true
            cell.numberLabel.text = "\(lessonRecord.lesson.page)"
            if lessonRecord.lesson.isAudioDownloaded {
                cell.audioButton.setImage(#imageLiteral(resourceName: "audio-downloaded"), for: .normal)
                cell.audioButton.setImage(#imageLiteral(resourceName: "audio-downloaded"), for: .highlighted)
            } else {
                cell.audioButton.setImage(#imageLiteral(resourceName: "audio-nat"), for: .normal)
            }
            if lessonRecord.lesson.isVideoDownloaded{
                cell.videoButton.setImage(#imageLiteral(resourceName: "video-downloaded") , for: .normal)
                cell.videoButton.setImage(#imageLiteral(resourceName: "video-downloaded") , for: .highlighted)
            } else {
                cell.videoButton.setImage(#imageLiteral(resourceName: "video-nat") , for: .normal)
            }
            cell.setHiddenButtonsForLesson(lessonRecord.lesson)
            if self.lessonWatched.count > 0 {
                for lesson in self.lessonWatched {
                    if lesson.lessonId == lessonRecord.lesson.id {
                        let count = lesson.duration / Double(lessonRecord.lesson.duration)
                        Utils.setProgressbar(count: count, view: cell.mainProgressBar, rounded: false, cornerRadius: 0, bottomRadius: true)
                        break
                    }
                }
            }
        } else {
            guard let lessonRecord = gemaraMishnaHistory[indexPath.row] as? JTMishnaLessonRecord else {
                return UICollectionViewCell()
                
            }

            cell.masechetLabel.text = lessonRecord.masechetName
            cell.chapterLabel.text = lessonRecord.chapter
            cell.mishnaOrGemaraLabel.text = Strings.mishnaCapitalized
            cell.isGemara = false
            cell.numberLabel.text = "\(lessonRecord.lesson.mishna)"
            if lessonRecord.lesson.isAudioDownloaded {
                cell.audioButton.setImage(#imageLiteral(resourceName: "audio-downloaded"), for: .normal)
                cell.audioButton.setImage(#imageLiteral(resourceName: "audio-downloaded"), for: .highlighted)
            } else {
                cell.audioButton.setImage(#imageLiteral(resourceName: "audio-nat"), for: .normal)
            }
            if lessonRecord.lesson.isVideoDownloaded{
                cell.videoButton.setImage(#imageLiteral(resourceName: "video-downloaded") , for: .normal)
                cell.videoButton.setImage(#imageLiteral(resourceName: "video-downloaded") , for: .highlighted)
            } else {
                cell.videoButton.setImage(#imageLiteral(resourceName: "video-nat") , for: .normal)
            }
            cell.setHiddenButtonsForLesson(lessonRecord.lesson)
            if self.lessonWatched.count > 0 {
                for lesson in self.lessonWatched {
                    if lesson.lessonId == lessonRecord.lesson.id {
                        let count = lesson.duration / Double(lessonRecord.lesson.duration)
                        Utils.setProgressbar(count: count, view: cell.mainProgressBar, rounded: false, cornerRadius: 0, bottomRadius: true)
                        break
                    }
                }
            }
        }
        
        
        cell.delegate = self
        cell.selectedRow = indexPath.row
        Utils.setViewShape(view: cell.cellView, viewCornerRadius: 18)
        Utils.setViewShape(view: cell.cellViewShadowView, viewCornerRadius: 18)
        let shadowOffset = CGSize(width: 0, height: 5)
        Utils.dropViewShadow(view: cell.cellViewShadowView, shadowColor: Colors.brightShadowColor, shadowRadius: 10, shadowOffset: shadowOffset)
        
        return cell
    }
    
    func setIcons(string: String) {
        self.downloadsLabel.textColor = #colorLiteral(red: 0.4734545946, green: 0.6921172738, blue: 0.9352924824, alpha: 1)
        self.gemaraLabel.textColor = #colorLiteral(red: 0.4734545946, green: 0.6921172738, blue: 0.9352924824, alpha: 1)
        self.mishnaLabel.textColor = #colorLiteral(red: 0.4734545946, green: 0.6921172738, blue: 0.9352924824, alpha: 1)
        self.donationsLabel.textColor = #colorLiteral(red: 0.4734545946, green: 0.6921172738, blue: 0.9352924824, alpha: 1)
        self.gemaraImageView.image = #imageLiteral(resourceName: "GemaraNatural")
        self.mishnaImageView.image = #imageLiteral(resourceName: "MishnaNatural")
        self.donationsImageView.image = #imageLiteral(resourceName: "Donations")
        self.downloadsImageView.image = #imageLiteral(resourceName: "DownloadsNatural")
        if string == "downloads" {
            self.downloadsImageView.image = #imageLiteral(resourceName: "Downloads Natural Blue")
            self.downloadsLabel.textColor = #colorLiteral(red: 0.18, green: 0.17, blue: 0.66, alpha: 1)
        } else if string == "gemara"{
            self.gemaraLabel.textColor = #colorLiteral(red: 0.18, green: 0.17, blue: 0.66, alpha: 1)
            self.gemaraImageView.image = #imageLiteral(resourceName: "Gemara natural Blue")
        } else if string == "mishna" {
            self.mishnaLabel.textColor = #colorLiteral(red: 0.18, green: 0.17, blue: 0.66, alpha: 1)
            self.mishnaImageView.image = #imageLiteral(resourceName: "Mishna natural Blue")
        } else if string == "donations" {
            self.donationsLabel.textColor = #colorLiteral(red: 0.18, green: 0.17, blue: 0.66, alpha: 1)
            self.donationsImageView.image = #imageLiteral(resourceName: "DonationsBlue")
        }
    }
    
    func presentDonation (){
        guard let user = self.user else{ return }
        
        if user.lessonDonated?.donated ?? false || UserDefaultsProvider.shared.donationPending {
            self.presentDonationsNavigationViewController()
        }else {
            self.presentDonationsViewController()
        }
        
    }
    
    //============================================================
    // MARK: - TableView
    //============================================================
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.latestNewsItemsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) ->
    UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "newsItemCell", for: indexPath) as! NewsItemCell

        let post = self.latestNewsItemsList[indexPath.row]
        cell.newsItem = post
        
        cell.imageBox.isHidden = (post.mediaType != .image)
        cell.videoView.isHidden = (post.mediaType != .video)
        cell.audioView.isHidden = (post.mediaType != .audio)
        
        if post.body?.isEmpty ?? true {
            cell.textBox.text = ""
            cell.textBox.isHidden = true
        } else {
            let attributedString = NSMutableAttributedString(string: post.body!)
            // Detect all url's in post body
            let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
            let matches = detector.matches(in: attributedString.string, options: [], range: NSRange(location: 0, length: attributedString.string.count))
            for match in matches {
                guard let checkurl = match.url?.absoluteString else { continue }
                // check range again, because length of attributedString changed after first url replaced.
                let checkTheRange = attributedString.mutableString.range(of: checkurl)
                guard let range = Range(checkTheRange, in: attributedString.string) else { continue }
                let url = attributedString.string[range]
                // create link for url
                let attributedLink = NSMutableAttributedString(string: "Haz clic aquí")
                attributedLink.addAttribute(.link, value: url, range: NSRange(location: 0, length: 13))
                // Get range of text to replace
                guard let range2 = attributedString.string.range(of: url) else { exit(0) }
                let nsRange = NSRange(range2, in: attributedString.string)
                // Replace url with attributed link
                attributedString.replaceCharacters(in: nsRange, with: attributedLink)
            }
            // save font and color
            let font = cell.textBox.font
            let color = cell.textBox.textColor

             // Set attributed string to textView
            cell.textBox.attributedText = attributedString
            // restore font and color
            cell.textBox.font = font
            cell.textBox.textColor = color
            
            cell.textBox.isHidden = false
        }
        
        switch post.mediaType {
        case .image:
            if let imageURL = URL(string: post.mediaLink ?? ""){
                cell.imageBox.loadImage(at: imageURL)
                Utils.setViewShape(view: cell.imageBox, viewCornerRadius: 18, maskedCorners: [.layerMinXMinYCorner, .layerMaxXMinYCorner])

            } else {
                cell.imageBox.isHidden = true
            }
            break
            
        case .video:
            let mediaActivity = Utils.showActivityView(inView: cell.videoView, withFrame: cell.videoView.frame, text: nil)
            if let videoURL = URL(string:post.mediaLink!){
                self.setAudioSession()
                cell.videoPlayer = AVPlayer(url: videoURL)
                cell.playerController = AVPlayerViewController()
                cell.playerController?.player = cell.videoPlayer
                cell.playerController?.showsPlaybackControls = true
                /// disconnect from nowPlaying control center so it won't interfere with player widget.
                cell.playerController?.updatesNowPlayingInfoCenter = false
                cell.playerController?.view.frame = cell.videoView.bounds
                cell.videoView.addSubview(cell.playerController!.view)
                
                Utils.setViewShape(view: cell.videoView, viewCornerRadius: 18, maskedCorners: [.layerMinXMinYCorner, .layerMaxXMinYCorner])
            } else {
                cell.videoView.isHidden = true
            }
            Utils.removeActivityView(mediaActivity)
            break
            
        case .audio:
            self.setAudioSession()
            Utils.setViewShape(view: cell.audioView, viewCornerRadius: 18, maskedCorners: [.layerMinXMinYCorner, .layerMaxXMinYCorner])
        case .noMedia:
            break
        }
        
        // set publish date
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "es_ES")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if let pubDate = dateFormatter.date(from: post.publishDate!){
            dateFormatter.dateStyle = .long
            cell.publishDateLabel.text = dateFormatter.string(from: pubDate)
            
        }
        
        // round cell view and shadows
        Utils.setViewShape(view: cell.newsItemView, viewCornerRadius: 18)
        let shadowOffset = CGSize(width: 0.0, height: 5)
        Utils.dropViewShadow(view: cell.newsItemView, shadowColor: Colors.shadowColor, shadowRadius: 15 , shadowOffset: shadowOffset)
        cell.newsItemView.layoutIfNeeded()
                

        return cell
    }
    
    //========================================
    // MARK: - @IBActions
    //========================================
    
    @IBAction func downloadsButtonTouchedDown(_ sender: UIButton) {
        
    }
    
    @IBAction func downloadsButtonTouchedUp(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3) {
            self.downloadsImageView.alpha = 1.0
            self.downloadsLabel.alpha = 1.0
        }
        self.presentDownloadsViewController()
    }
    
    @IBAction func downloadsButtonTouchedUpOutside(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3) {
            self.downloadsImageView.alpha = 1.0
            self.downloadsLabel.alpha = 1.0
        }
    }
    
    @IBAction func gemaraButtonTouchedDown(_ sender: UIButton) {
        
    }
    
    @IBAction func gemaraButtonTouchedUp(_ sender: UIButton) {
        if self.pressEnable {
            UIView.animate(withDuration: 0.3) {
                self.gemaraImageView.alpha = 1.0
                self.gemaraLabel.alpha = 1.0
            }
            self.presentGemaraViewController()
        } else {
            self.noInternetAlert()
        }
    }
    
    @IBAction func gemaraButtonTouchedUpOutside(_ sender: UIButton) {
        if self.pressEnable {
            UIView.animate(withDuration: 0.3) {
                self.gemaraImageView.alpha = 1.0
                self.gemaraLabel.alpha = 1.0
            }
        } else {
            self.noInternetAlert()
        }
    }
    
    @IBAction func mishnaButtonTouchedDown(_ sender: UIButton) {
        
    }
    
    @IBAction func mishnaButtonTouchedUp(_ sender: UIButton) {
        if self.pressEnable {
            UIView.animate(withDuration: 0.3) {
                self.mishnaImageView.alpha = 1.0
                self.mishnaLabel.alpha = 1.0
            }
            self.presentMishnaViewController()
        } else {
            self.noInternetAlert()
        }
    }
    
    @IBAction func mishnaButtonTouchedUpOutside(_ sender: UIButton) {
        if self.pressEnable {
            UIView.animate(withDuration: 0.3) {
                self.mishnaImageView.alpha = 1.0
                self.mishnaLabel.alpha = 1.0
            }
        } else {
            self.noInternetAlert()
        }
    }
    
    @IBAction func donationsButtonTouchedDown(_ sender: UIButton) {
        
        
    }
    
    @IBAction func donationsButtonTouchedUp(_ sender: UIButton) {
        if self.pressEnable {
            UIView.animate(withDuration: 0.3) {
                self.donationsImageView.alpha = 1.0
                self.donationsLabel.alpha = 1.0
            }
            self.presentDonation()
        } else {
            self.noInternetAlert()
        }
    }
    
    @IBAction func donationsButtonTouchedUpOutside(_ sender: UIButton) {
        if self.pressEnable {
            UIView.animate(withDuration: 0.3) {
                self.donationsImageView.alpha = 1.0
                self.donationsLabel.alpha = 1.0
            }
        } else {
            self.noInternetAlert()
        }
    }
    
    @IBAction func menuButtonPressed(_ sender: UIButton) {
        self.presentMenu()
    }
    
    
    
    @IBAction func todaysDafAudioPressed(_ sender: Any) {
        if self.pressEnable {
            self.showActivityView()
            let todaysDaf = DafYomiRepository.shared.getTodaysDaf()
            guard let data = ContentRepository.shared.getMasechetByName(todaysDaf.masechet) else {
                self.removeActivityView()
                return
            }
            ContentRepository.shared.getGemaraLesson(masechetId: data.masechet.id, page: todaysDaf.daf) { (result: Result<JTGemaraLesson, JTError>) in
                DispatchQueue.main.async {
                    self.removeActivityView()
                    switch result {
                    case .success(let lesson):
                        self.playLesson(lesson, mediaType: .audio, sederId: "\(data.seder.id)", masechetId: "\(data.masechet.id)", chapter: nil, masechetName: todaysDaf.masechet, deepLinkDuration: 0.0)
                    case .failure:
                        break
                    }
                }
            }
        } else {
            self.noInternetAlert()
        }
    }
    
    @IBAction func todaysDafVideoPressed(_ sender: Any) {
        if self.pressEnable {
            presentTodayDafLessonVideo()
        } else {
            self.noInternetAlert()
        }
    }
    
    func presentTodayDafLessonVideo(){
        self.showActivityView()
        let todaysDaf = DafYomiRepository.shared.getTodaysDaf()
        guard let data = ContentRepository.shared.getMasechetByName(todaysDaf.masechet) else {
            self.removeActivityView()
            return
        }
        ContentRepository.shared.getGemaraLesson(masechetId: data.masechet.id, page: todaysDaf.daf) { (result: Result<JTGemaraLesson, JTError>) in
            DispatchQueue.main.async {
                self.removeActivityView()
                switch result {
                case .success(let lesson):
                    self.playLesson(lesson, mediaType: .video, sederId: "\(data.seder.id)", masechetId: "\(data.masechet.id)", chapter: nil, masechetName: todaysDaf.masechet, deepLinkDuration: 0.0)
                case .failure:
                    break
                }
            }
        }
    }
    
    @IBAction func chatPressed(_ sender: Any) {
        self.presentMessages()
    }
    
    @IBAction func unwindToMain(segue:UIStoryboardSegue) {
        self.dismissMainModal()
    }
    
    @IBAction func viewMoreNewsButtonPressed(_ sender: Any) {
        self.optionSelected(option: .newsFeed)
    }
    
    //========================================
    // MARK: - PopUps
    //========================================
    
    private func getPopup() {
        guard let token = UserDefaultsProvider.shared.currentUser?.token else { return }
        API.getPopups(authToken: token, completionHandler: {(result:APIResult<JTPopup>) in
            switch result {
            case .success(let response):
                self.firstOnScreen = false
                DispatchQueue.main.async {
                    self.presentPopup(values: response)
                }
            case .failure( _):
                self.presentFiestaAlert()
            }
        })
    }
    
    //========================================
    // MARK: - Navigation
    //========================================
    
    func navigateToSignIn() {
        let signInViewController = Storyboards.SignIn.signInViewController
        appDelegate.setRootViewController(viewController: signInViewController, animated: true)
    }
    
    private func presentPopup(values: JTPopup) {
        self.performSegue(withIdentifier: "popup", sender: values)
    }
    
    private func presentMenu() {
        self.performSegue(withIdentifier: "presentMenu", sender: nil)
    }
    
    private func presentProfile() {
        self.performSegue(withIdentifier: "presentProfile", sender: self)
    }
    
    private func presentOldProfile() {
        self.performSegue(withIdentifier: "presentOldProfile", sender: self)
    }
    
    private func presentMessages() {
        self.performSegue(withIdentifier: "toMessages", sender: self)
    }
    
    private func presentNewsFeed() {
        self.performSegue(withIdentifier: "presentNewsFeed", sender: self)
    }
    
    //    func presentDonationWalkThrough() {
    //        self.performSegue(withIdentifier: "presentDonationWalkTrough", sender: self)
    //    }
    
    func presentOldDonations() {
        if self.currentPresentedModal != nil && self.currentPresentedModal != .donations {
            self.modalsPresentingVC.dismiss(animated: true) {
                self.modalsPresentingVC.performSegue(withIdentifier: "presentOldDonation", sender: nil)
            }
        }
        else if self.currentPresentedModal == nil{
            self.view.bringSubviewToFront(self.modalsContainer)
            self.modalsPresentingVC.performSegue(withIdentifier: "presentOldDonation", sender: nil)
        }
        self.currentPresentedModal = .donations
        self.setIcons(string: "donations")
        
        // MARK: TODO - shut news audio when goes into background - refresh here is temporary hack.
        self.latestNewsTableView.reloadData()
    }
    
    func presentDownloadsViewController() {
        if self.currentPresentedModal != nil && self.currentPresentedModal != .downloads {
            self.modalsPresentingVC.dismiss(animated: true) {
                self.modalsPresentingVC.performSegue(withIdentifier: "presentDownloads", sender: nil)
            }
        }
        else if self.currentPresentedModal == nil{
            self.view.bringSubviewToFront(self.modalsContainer)
            self.modalsPresentingVC.performSegue(withIdentifier: "presentDownloads", sender: nil)
        }
        self.currentPresentedModal = .downloads
        self.setIcons(string: "downloads")
        
        // MARK: TODO - shut news audio when goes into background - refresh here is temporary hack.
        self.latestNewsTableView.reloadData()
    }
    
    func presentGemaraViewController() {
        if self.currentPresentedModal != nil && self.currentPresentedModal != .gemara {
            self.modalsPresentingVC.dismiss(animated: true) {
                self.modalsPresentingVC.performSegue(withIdentifier: "presentGemara", sender: nil)
            }
        }
        else if self.currentPresentedModal == nil{
            self.view.bringSubviewToFront(self.modalsContainer)
            self.modalsPresentingVC.performSegue(withIdentifier: "presentGemara", sender: nil)
        }
        self.currentPresentedModal = .gemara
        self.setIcons(string: "gemara")
        
        // MARK: TODO - shut news audio when goes into background - refresh here is temporary hack.
        self.latestNewsTableView.reloadData()
    }
    
    func presentMishnaViewController() {
        self.latestNewsTableView.reloadData()
        
        if self.currentPresentedModal != nil && self.currentPresentedModal != .mishna {
            self.modalsPresentingVC.dismiss(animated: true) {
                self.modalsPresentingVC.performSegue(withIdentifier: "presentMishna", sender: nil)
            }
        }
        else if self.currentPresentedModal == nil{
            self.view.bringSubviewToFront(self.modalsContainer)
            self.modalsPresentingVC.performSegue(withIdentifier: "presentMishna", sender: nil)
        }
        self.currentPresentedModal = .mishna
        self.setIcons(string: "mishna")
        
        // MARK: TODO - shut news audio when goes into background - refresh here is temporary hack.
        self.latestNewsTableView.reloadData()
    }
    
    func presentDonationsNavigationViewController() {
        if self.currentPresentedModal != nil && self.currentPresentedModal != .donations {
            self.modalsPresentingVC.dismiss(animated: true) {
                self.modalsPresentingVC.performSegue(withIdentifier: "presentTzedaka", sender: nil)
            }
        }
        else if self.currentPresentedModal == nil{
            self.view.bringSubviewToFront(self.modalsContainer)
            self.modalsPresentingVC.performSegue(withIdentifier: "presentTzedaka", sender: nil)
        }
        self.currentPresentedModal = .donations
        self.setIcons(string: "donations")
        
        // MARK: TODO - shut news audio when goes into background - refresh here is temporary hack.
        self.latestNewsTableView.reloadData()
    }
    
    func presentChatNavigationViewController(chatId: Int){
        let navigationVC = Storyboards.Messages.messagesNavigationController
        navigationVC.modalPresentationStyle = .fullScreen
        if let messageVC = navigationVC.children.first as? MessagesViewController{
            messageVC.presentChat(chatId)
        }
        self.present(navigationVC, animated: false, completion: nil)
        //        appDelegate.setRootViewController(viewController: navigationVC, animated: false)
    }
    
    
    func presentDonationsViewController() {
        self.performSegue(withIdentifier: "presentFirstTimeDonation", sender: self)
        
    }
    
    private func presentInDevelopmentAlert() {
        Utils.showAlertMessage(Strings.inDevelopment, viewControler: self)
        
    }
    
    private func noInternetAlert(){
        let vc = appDelegate.topmostViewController!
        Utils.showAlertMessage(Strings.internetDisconncet, viewControler: vc)
    }
    
    func noInternetActionAlert(){
        let vc = appDelegate.topmostViewController!
        Utils.showAlertMessage(Strings.internetDisconncet, title: Strings.error, viewControler: vc) {(action) in
            UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
            //Comment if you want to minimise app
            Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { (timer) in
                exit(0)
            }
        }
    }
    
    func dismissMainModal() {
        self.modalsPresentingVC.dismiss(animated: true) {
            self.view.bringSubviewToFront(self.mainContainer)
            self.currentPresentedModal = nil
            self.setDefaulteIcons()
            self.setContent()
            self.getLatestNewsItems()
        }
    }
    
    func presentAllGemara() {
        self.presentGemaraViewController()
    }
    
    func presentAllMishna() {
        self.presentMishnaViewController()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "embedModalsVC" {
            self.modalsPresentingVC = segue.destination as? ModalsContainerViewController
            self.modalsPresentingVC?.delegate = self
        }
            
        else if segue.identifier == "presentMenu" {
            let menuVC = segue.destination as? MainMenuViewController
            menuVC?.delegate = self
        }
            
        else if segue.identifier == "presentProfile" {
            let profileVC = segue.destination as? ProfileViewController
            profileVC?.mainViewController = self
        }
        else if segue.identifier == "presentOldProfile" {
            let profileVC = segue.destination as? OldProfileViewController
            profileVC?.mainViewController = self
        }
            
        else if segue.identifier == "popup" {
            let popupVC = segue.destination as? PopUpViewController
            guard let currentPopup = sender as? JTPopup else { return }
            popupVC?.currentPopup = currentPopup
        }
        else if segue.identifier == "presentFirstTimeDonation" {
            let popupVC = segue.destination as? DonateViewController
            popupVC?.isSingelPayment = self.singlePayment
        }
        else if segue.identifier == "presentNewsFeed" {
            let newsFeedVC = segue.destination as? NewsFeedViewController
        }
        
        
        // MARK: TODO - shut news audio when goes into background - refresh here is temporary hack.
        self.latestNewsTableView.reloadData()
        
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

extension MainViewController: MenuDelegate, MainCollectionCellDelegate, AlertViewDelegate {
    
    // MenuDelegate
    func optionSelected(option: MenuOption) {
        switch option {
        case .profile:
            self.pressEnable ? presentProfile() : self.noInternetAlert()
        //            presentOldProfile()
        case .signOut:
            presentLogoutAlert()
        case .mishna:
            self.pressEnable ? presentMishnaViewController() : self.noInternetAlert()
        case .gemara:
            self.pressEnable ? presentGemaraViewController() : self.noInternetAlert()
        case .about:
            presentAboutUs()
        case .messageCenter:
            presentMessages()
        case .donationsCenter:
            self.pressEnable ? self.presentDonation() : self.noInternetAlert()
        case .newsFeed:
            self.pressEnable ? self.presentNewsFeed() : self.noInternetAlert()
            break
        default:
            presentInDevelopmentAlert()
        }
    }
    
    func presentDonationPopUp(){
        self.presentAlert(Storyboards.DonationPopUp.donationPopUpViewController)
    }
    
    func presentLastDonationPopUp(){
        self.presentAlert(Storyboards.DonationPopUp.lastPopUp)
    }
    
    func presentNewVersionAlert(){
        self.presentAlert(Storyboards.AdditionalAlerts.newVersionAlert)
    }
    
    func presentFiestaAlert(){
        let dateFormatte = DateFormatter()
        dateFormatte.dateFormat = "yyyy-MM-dd"
        let now = Date()
        let soon = dateFormatte.date(from: "2020-08-18")!
        let later = dateFormatte.date(from: "2020-09-16")!
        
        if now > soon && now <= later {
            DispatchQueue.main.async {
                guard let detail = UserDefaultsProvider.shared.fiestaPopUpDetail else {
                    return self.presentAlert(Storyboards.AdditionalAlerts.fiestaAlert)
                }
                if detail.agree {
                    return
                } else {
                    let calander = Calendar(identifier: .gregorian)
                    if calander.isDateInToday(detail.currentDate) {
                        return
                    } else {
                        self.presentAlert(Storyboards.AdditionalAlerts.fiestaAlert)
                    }
                }
            }
        }
    }
    
    func presentCouponePopUp(values: JTDeepLinkCoupone){
        self.isCupponAvailable(values: values)
    }
    
    func isCupponAvailable(values: JTDeepLinkCoupone){
        let isAvailable = JTCouponRedemption(coupon: values.couponDistributor)
        isAvailable.commit = false
        DonationManager.shared.createCouponRedemption(isAvailable){ (result) in
            switch result {
            case .success(let success):
                print(success)
                DispatchQueue.main.async {
                    let couponePopUp = Storyboards.Coupons.couponeViewController
                    couponePopUp.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
                    couponePopUp.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
                    couponePopUp.values = values
                    couponePopUp.crowns = values.couponSum
                    self.present(couponePopUp, animated: true, completion: nil)
                }
            case .failure(let error):
                print(error)
                DispatchQueue.main.async {
                    self.presentAlert(Storyboards.Coupons.invalidCouponeViewController)
                }
                Utils.showAlertMessage("No se pudo crear el canje del cupón, inténtelo de nuevo", viewControler: self)
            }
        }
    }
    
    func presentAlert(_ vc: UIViewController){
        DispatchQueue.main.async {
            let vc = vc
            vc.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
            vc.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    func presentAboutUs() {
        let aboutViewController = Storyboards.Main.aboutViewController
        self.present(aboutViewController, animated: true)
    }
    
    func presentLogoutAlert() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let myAlert = storyboard.instantiateViewController(withIdentifier: "alertView") as! AlertViewController
        myAlert.delegate = self
        myAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        myAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        self.present(myAlert, animated: true, completion: nil)
    }
    
    // MainCollectionCellDelegate
    func cellPressed(selectedRow: Int, isGemara: Bool) {
        print("Cell pressed")
        if isGemara {
            
        } else {
            
        }
    }
    
    func lessonFromDeepLink(_ values: JTDeepLinkLesson){
        self.showActivityView()
        if values.gemara == 1 {
            guard let page = values.page else { return }
            ContentRepository.shared.getGemaraLesson(masechetId: values.masechet, page: page) { (result: Result<JTGemaraLesson, JTError>) in
                DispatchQueue.main.async {
                    self.removeActivityView()
                    switch result {
                    case .success(let lesson):
                            self.playLesson(lesson, mediaType: values.video == 1 ? .video : .audio, sederId: "\(values.seder)", masechetId: "\(values.masechet)", chapter: nil, masechetName: values.masechetName, deepLinkDuration: values.duration ?? 0.0)
                    case .failure:
                        break
                    }
                }
            }
        } else {
            if values.gemara == 0 {
                guard let chapter = values.chapter else { return }
                guard let mishna = values.mishna else { return }
                ContentRepository.shared.getMishnaLesson(masechetId: values.masechet, chapter: chapter, mishna: mishna){ (result: Result<JTMishnaLesson, JTError>) in
                    DispatchQueue.main.async {
                        self.removeActivityView()
                        switch result {
                        case .success(let lesson):
                            self.playLesson(lesson, mediaType: values.video == 1 ? .video : .audio , sederId: "\(values.seder)", masechetId: "\(values.masechet)", chapter: "\(chapter)", masechetName: values.masechetName, deepLinkDuration: values.duration ?? 0.0)
                        case .failure:
                            break
                        }
                    }
                }
            }
        }
        self.showActivityView()
    }
    
    func couponeFromDeepLink(values: JTDeepLinkCoupone){
        presentCouponePopUp(values: values)
    }
    
    func audioPressed(selectedRow: Int, isGemara: Bool) {
        DispatchQueue.main.async {
            if isGemara {
                guard let record = self.gemaraMishnaHistory[selectedRow] as? JTGemaraLessonRecord else { return }
                self.playLesson(record.lesson, mediaType: .audio, sederId: record.sederId, masechetId: record.masechetId, chapter: nil, masechetName: record.masechetName, deepLinkDuration: 0.0)
            } else {
                guard let record = self.gemaraMishnaHistory[selectedRow] as? JTMishnaLessonRecord else { return }
                self.playLesson(record.lesson, mediaType: .audio, sederId: record.sederId, masechetId: record.masechetId, chapter: record.chapter, masechetName: record.masechetName, deepLinkDuration: 0.0)
            }
        }
    }
    
    func videoPressed(selectedRow: Int, isGemara: Bool) {
        DispatchQueue.main.async {
            if isGemara {
                guard let record = self.gemaraMishnaHistory[selectedRow] as? JTGemaraLessonRecord else { return }
                self.playLesson(record.lesson, mediaType: .video, sederId: record.sederId, masechetId: record.masechetId, chapter: nil, masechetName: record.masechetName, deepLinkDuration: 0.0)
            } else {
                guard let record = self.gemaraMishnaHistory[selectedRow] as? JTMishnaLessonRecord else { return }
                self.playLesson(record.lesson, mediaType: .video, sederId: record.sederId, masechetId: record.masechetId, chapter: record.chapter, masechetName: record.masechetName, deepLinkDuration: 0.0)
            }
        }
    }
    
    // AlertViewDelegate
    func okPressed() {
        LoginManager.shared.signOut {
            DispatchQueue.main.async {
                self.navigateToSignIn()
            }
        }
    }
    
    //======================================================
    // MARK: - Player
    //======================================================
    
    private func playLesson(_ lesson: JTLesson, mediaType: JTLessonMediaType, sederId: String, masechetId: String, chapter: String?, masechetName: String?, deepLinkDuration: Double) {
//        let playerVC = LessonPlayerViewController(lesson: lesson, mediaType: mediaType, sederId: sederId, masechetId:masechetId, chapter:chapter)
        let playerVC = LessonPlayerViewController(lesson: lesson, mediaType: mediaType, sederId: sederId, masechetId:masechetId, chapter:chapter, shouldDisplayDonationPopUp: lesson.isAudioDownloaded || lesson.isVideoDownloaded ? false : true)
        playerVC.modalPresentationStyle = .fullScreen
        playerVC.masechet = masechetName ?? ""
        playerVC.deepLinkDuration = deepLinkDuration
        if let lesson = lesson as? JTGemaraLesson {
            playerVC.daf = "\(lesson.page)"
        }
        if let lesson = lesson as? JTMishnaLesson {
            playerVC.daf = "\(lesson.chapter)"
        }
        self.present(playerVC, animated: true) {
            
        }
        
        if let gemaraLesson = lesson as? JTGemaraLesson, let _masechetName = masechetName  {
            ContentRepository.shared.lessonWatched(gemaraLesson, masechetName: _masechetName, masechetId: "\(masechetId)", sederId: sederId)
        }
    }
}

extension MainViewController: MessagesRepositoryDelegate{
    func didReciveNewMessage(){
        let unReded = CoreDataManager.shared.getUnReadedChats()
        self.setUnReadedIcon(unReded)
    }
    
    func didSendMessage() {
        //    self.setUnReadedIcon()
    }
    
    
    
}
