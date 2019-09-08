//בעזת ה׳ החונן לאדם דעת
//  MainViewController.swift
//  Jabrutouch
//
//  Created by Yoni Reiss on 18/07/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import UIKit

enum MainModal {
    case downloads
    case gemara
    case mishna
    case donations
    
}

protocol MainModalDelegate : class {
    func dismissMainModal()
}

class MainViewController: UIViewController, MainModalDelegate, UICollectionViewDataSource {

    //========================================
    // MARK: - Properties
    //========================================
    
    private var modalsPresentingVC: ModalsContainerViewController!
    private var currentPresentedModal: MainModal?
    private var gemaraHistory: [JTGemaraLessonRecord] = []
    private var mishnaHistory: [JTMishnaLessonRecord] = []
    private var todaysDafToHeaderConstraint: NSLayoutConstraint?
    private var isFirstTime: Bool = UserDefaultsProvider.shared.firstTime
    
    private var activityView: ActivityView?
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
    
    // Welcome Views
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var welcomeImage: UIImageView!
    
    // Todays Daf Yomi
    @IBOutlet weak private var todaysDafOuterContainer: UIView!
    @IBOutlet weak private var todaysDafContainer: UIView!
    @IBOutlet weak private var todaysDafTitleLabel: UILabel!
    @IBOutlet weak private var todaysDafLabel: UILabel!
    @IBOutlet weak private var todaysDateLabel: UILabel!
    @IBOutlet weak var todaysDafToWelcomeConstraint: NSLayoutConstraint!
    
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
    
    // Other
    @IBOutlet weak var gemaraCollectionViewTitle: UILabel!
    @IBOutlet weak var gemaraCollectionView: UICollectionView!
    @IBOutlet weak var mishnaCollectionViewTitle: UILabel!
    @IBOutlet weak var mishnaCollectionView: UICollectionView!
    
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
        self.setConstraints()
        UserDefaultsProvider.shared.firstTime = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setContent()
        setView()
    }
    
    //========================================
    // MARK: - Setup
    //========================================
    
    private func setStrings() {
        
        // Todays daf
        self.todaysDafTitleLabel.text = Strings.todaysDafYomi.uppercased()
        self.todaysDafLabel.text = DafYomiRepository.shared.getTodaysDaf().displayString
        let calendar = Calendar(identifier: .hebrew)
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = calendar
        dateFormatter.dateStyle = .long
        self.todaysDateLabel.text = dateFormatter.string(from: Date())
        
        
        // Main tabs
        self.downloadsLabel.text = Strings.downloads
        self.gemaraLabel.text = Strings.gemara
        self.mishnaLabel.text = Strings.mishna
        self.donationsLabel.text = Strings.donations
        self.titleLabel.text = Strings.jabrutouch
        
        self.welcomeLabel.text = Strings.welcomeToTheNewJabrutouch
        self.gemaraCollectionViewTitle.text = Strings.recentPagesOnGemara.uppercased()
        self.mishnaCollectionViewTitle.text = Strings.recentPagesOnMishna.uppercased()
    }
    
    private func roundCorners() {
        self.todaysDafContainer.layer.cornerRadius = 15
    }
    
    private func setShadows() {
        let shadowOffset = CGSize(width: 0.0, height: 12)
        Utils.dropViewShadow(view: self.todaysDafContainer, shadowColor: Colors.shadowColor, shadowRadius: 36, shadowOffset: shadowOffset)
    }
    
    private func setView() {
        welcomeLabel.isHidden = !self.isFirstTime
        welcomeImage.isHidden = !self.isFirstTime
        
        if self.isFirstTime {
            todaysDafToHeaderConstraint?.isActive = false
            todaysDafToWelcomeConstraint?.isActive = true
        } else {
            todaysDafToWelcomeConstraint?.isActive = false
            todaysDafToHeaderConstraint?.isActive = true
        }
        
        self.view.layoutIfNeeded()
    }
    
    private func setConstraints() {
        todaysDafToHeaderConstraint = todaysDafContainer.topAnchor.constraint(equalTo: headerContainer.bottomAnchor, constant: 55)
    }
    
    private func setContent() {
        self.gemaraHistory = ContentRepository.shared.lastWatchedGemaraLessons
        self.mishnaHistory = ContentRepository.shared.lastWatchedMishnaLessons
        self.gemaraCollectionView.reloadData()
        self.mishnaCollectionView.reloadData()
    }
    //========================================
    // MARK: - Collection Views
    //========================================
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == gemaraCollectionView {
            return gemaraHistory.count
        } else {
            return mishnaHistory.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "mainCollectionCell",
                                                            for: indexPath) as? MainCollectionCellViewController else { return UICollectionViewCell() }
        if collectionView == gemaraCollectionView {
            let lessonRecord = gemaraHistory[indexPath.row]
            
            cell.masechetLabel.text = lessonRecord.masechetName
            cell.chapterLabel.text = nil
            cell.numberLabel.text = "\(lessonRecord.lesson.page)"
            cell.audio.image = lessonRecord.lesson.isAudioDownloaded ? #imageLiteral(resourceName: "RedAudio") : #imageLiteral(resourceName: "Audio")
            cell.video.image = lessonRecord.lesson.isVideoDownloaded ? #imageLiteral(resourceName: "RedVideo") : #imageLiteral(resourceName: "Video")
        } else {
            let lessonRecord = mishnaHistory[indexPath.row]
            
            cell.masechetLabel.text = lessonRecord.masechetName
            cell.chapterLabel.text = lessonRecord.chapter
            cell.numberLabel.text = "\(lessonRecord.lesson.mishna)"
            cell.audio.isHidden = !lessonRecord.lesson.isAudioDownloaded
            cell.video.isHidden = !lessonRecord.lesson.isVideoDownloaded
        }
        
        
        cell.delegate = self
        cell.selectedRow = indexPath.row
        cell.isFirstCollection = collectionView == gemaraCollectionView
        Utils.setViewShape(view: cell.cellView, viewCornerRadius: 18)
        let shadowOffset = CGSize(width: 0, height: 5)
        Utils.dropViewShadow(view: cell.cellView, shadowColor: Colors.brightShadowColor, shadowRadius: 10, shadowOffset: shadowOffset)
        
        return cell
    }
    
    
    //========================================
    // MARK: - @IBActions
    //========================================
    
    @IBAction func downloadsButtonTouchedDown(_ sender: UIButton) {
        self.downloadsImageView.alpha = 0.3
        self.downloadsLabel.alpha = 0.3
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
        self.gemaraImageView.alpha = 0.3
        self.gemaraLabel.alpha = 0.3
    }
    
    @IBAction func gemaraButtonTouchedUp(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3) {
            self.gemaraImageView.alpha = 1.0
            self.gemaraLabel.alpha = 1.0
        }
        self.presentGemaraViewController()
    }
    
    @IBAction func gemaraButtonTouchedUpOutside(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3) {
            self.gemaraImageView.alpha = 1.0
            self.gemaraLabel.alpha = 1.0
        }
    }
    
    @IBAction func mishnaButtonTouchedDown(_ sender: UIButton) {
        self.mishnaImageView.alpha = 0.3
        self.mishnaLabel.alpha = 0.3
    }
    
    @IBAction func mishnaButtonTouchedUp(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3) {
            self.mishnaImageView.alpha = 1.0
            self.mishnaLabel.alpha = 1.0
        }
        self.presentMishnaViewController()
    }
    
    @IBAction func mishnaButtonTouchedUpOutside(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3) {
            self.mishnaImageView.alpha = 1.0
            self.mishnaLabel.alpha = 1.0
        }
    }
    
    @IBAction func donationsButtonTouchedDown(_ sender: UIButton) {
        self.donationsImageView.alpha = 0.3
        self.donationsLabel.alpha = 0.3
    }
    
    @IBAction func donationsButtonTouchedUp(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3) {
            self.donationsImageView.alpha = 1.0
            self.donationsLabel.alpha = 1.0
        }
        self.presentDonationsViewController()
    }
    
    @IBAction func donationsButtonTouchedUpOutside(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3) {
            self.donationsImageView.alpha = 1.0
            self.donationsLabel.alpha = 1.0
        }
    }
    
    @IBAction func menuButtonPressed(_ sender: UIButton) {
        self.presentMenu()
    }
    
    @IBAction func todaysDafAudioPressed(_ sender: Any) {
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
                    self.playLesson(lesson, mediaType: .audio, sederId: "\(data.seder.id)", masechetId: "\(data.masechet.id)", chapter: nil)
                case .failure:
                    break
                }
            }
        }
    }
    
    @IBAction func todaysDafVideoPressed(_ sender: Any) {
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
                    self.playLesson(lesson, mediaType: .video, sederId: "\(data.seder.id)", masechetId: "\(data.masechet.id)", chapter: nil)
                case .failure:
                    break
                }
            }
        }
    }
    
    //========================================
    // MARK: - Navigation
    //========================================
    
    func navigateToSignIn() {
        let signInViewController = Storyboards.SignIn.signInViewController
        appDelegate.setRootViewController(viewController: signInViewController, animated: true)
    }
    
    private func presentMenu() {
        self.performSegue(withIdentifier: "presentMenu", sender: nil)
    }
    
    private func presentProfile() {
        self.performSegue(withIdentifier: "presentProfile", sender: self)
    }
    
    private func presentDownloadsViewController() {
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
    }
    
    private func presentGemaraViewController() {
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
    }
    
    private func presentMishnaViewController() {
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
    }
    
    private func presentDonationsViewController() {
        if self.currentPresentedModal != nil && self.currentPresentedModal != .donations {
            self.modalsPresentingVC.dismiss(animated: true) {
                self.modalsPresentingVC.performSegue(withIdentifier: "presentDonations", sender: nil)
            }
        }
        else if self.currentPresentedModal == nil{
            self.view.bringSubviewToFront(self.modalsContainer)
            self.modalsPresentingVC.performSegue(withIdentifier: "presentDonations", sender: nil)
        }
        self.currentPresentedModal = .donations
    }
    
    func dismissMainModal() {
        self.modalsPresentingVC.dismiss(animated: true) {
            self.view.bringSubviewToFront(self.mainContainer)
            self.currentPresentedModal = nil
        }
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
            presentProfile()
        case .signOut:
            presentLogoutAlert()
        case .mishna:
            presentMishnaViewController()
        case .gemara:
            presentGemaraViewController()
        default:
            break
        }
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
    func cellPressed(selectedRow: Int, isFirstCollection: Bool) {
        print("Cell pressed")
        if isFirstCollection {

        } else {

        }
    }
    
    func audioPressed(selectedRow: Int, isFirstCollection: Bool) {
        DispatchQueue.main.async {
            if isFirstCollection {
                let record = self.gemaraHistory[selectedRow]
                self.playLesson(record.lesson, mediaType: .audio, sederId: record.sederId, masechetId: record.masechetId, chapter: nil)
            } else {
                let record = self.mishnaHistory[selectedRow]
                self.playLesson(record.lesson, mediaType: .audio, sederId: record.sederId, masechetId: record.masechetId, chapter: record.chapter)
            }
        }
    }
    
    func videoPressed(selectedRow: Int, isFirstCollection: Bool) {
        DispatchQueue.main.async {
            if isFirstCollection {
                let record = self.gemaraHistory[selectedRow]
                self.playLesson(record.lesson, mediaType: .video, sederId: record.sederId, masechetId: record.masechetId, chapter: nil)
            } else {
                let record = self.mishnaHistory[selectedRow]
                self.playLesson(record.lesson, mediaType: .video, sederId: record.sederId, masechetId: record.masechetId, chapter: record.chapter)
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
    
    private func playLesson(_ lesson: JTLesson, mediaType: JTLessonMediaType, sederId: String, masechetId: String, chapter: String?) {
        let playerVC = LessonPlayerViewController(lesson: lesson, mediaType: mediaType, sederId: sederId, masechetId:masechetId, chapter:chapter)
        self.present(playerVC, animated: true) {
            
        }
    }
}
