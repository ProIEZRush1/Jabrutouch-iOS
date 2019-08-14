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
    private var gemaraHistory: [JTDownload] = []
    private var mishnaHistory: [JTDownload] = []
    private var todaysDafToHeaderConstraint: NSLayoutConstraint?
    
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
    @IBOutlet weak var gemaraCollectionView: UICollectionView!
    @IBOutlet weak var mishnaCollectionView: UICollectionView!
    
    //========================================
    // MARK: - LifeCycle
    //========================================
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setStrings()
        self.roundCorners()
        self.setShadows()
        self.setConstraints()
        self.setDataForDev() // Only for Dev
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
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
    }
    
    private func roundCorners() {
        self.todaysDafContainer.layer.cornerRadius = 15
    }
    
    private func setShadows() {
        let shadowOffset = CGSize(width: 0.0, height: 12)
        Utils.dropViewShadow(view: self.todaysDafContainer, shadowColor: Colors.shadowColor, shadowRadius: 36, shadowOffset: shadowOffset)
    }
    
    private func setView() {
        welcomeLabel.isHidden = (gemaraHistory.count != 0 && mishnaHistory.count != 0)
        welcomeImage.isHidden = (gemaraHistory.count != 0 && mishnaHistory.count != 0)
        
        if (gemaraHistory.count == 0 && mishnaHistory.count == 0) {
            todaysDafToHeaderConstraint?.isActive = false
            todaysDafToWelcomeConstraint?.isActive = true
        } else {
            todaysDafToWelcomeConstraint?.isActive = false
            todaysDafToHeaderConstraint?.isActive = true
        }
        
        self.view.layoutIfNeeded()
    }
    
    private func setDataForDev() {
        gemaraHistory.append(JTDownload(book: "Pesachim", chapter: "A", number: "11", hasAudio: true, hasVideo: true))
        gemaraHistory.append(JTDownload(book: "Iruvin", chapter: "C", number: "2", hasAudio: true, hasVideo: true))
        gemaraHistory.append(JTDownload(book: "Brachot", chapter: "D", number: "5", hasAudio: true, hasVideo: true))
        mishnaHistory.append(JTDownload(book: "Rosh Hashana", chapter: "B", number: "12", hasAudio: true, hasVideo: true))
        mishnaHistory.append(JTDownload(book: "Shabbat", chapter: "E", number: "3", hasAudio: true, hasVideo: true))
    }
    
    private func setConstraints() {
        todaysDafToHeaderConstraint = todaysDafContainer.topAnchor.constraint(equalTo: headerContainer.bottomAnchor, constant: 55)
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
        var download: JTDownload
        if collectionView == gemaraCollectionView {
            download = gemaraHistory[indexPath.row]
        } else {
            download = mishnaHistory[indexPath.row]
        }
        
        cell.masechetLabel.text = download.book
        cell.chapterLabel.text = download.chapter
        cell.numberLabel.text = download.number
        cell.audio.isHidden = !download.hasAudio
        cell.video.isHidden = !download.hasVideo
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
        
    }
    
    @IBAction func todaysDafVideoPressed(_ sender: Any) {
        
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
            print(gemaraHistory[selectedRow].book + gemaraHistory[selectedRow].chapter + gemaraHistory[selectedRow].number)
        } else {
            print(mishnaHistory[selectedRow].book + mishnaHistory[selectedRow].chapter + mishnaHistory[selectedRow].number)
        }
    }
    
    func audioPressed(selectedRow: Int, isFirstCollection: Bool) {
        print("Audio pressed")
        if isFirstCollection {
            print(gemaraHistory[selectedRow].book + gemaraHistory[selectedRow].chapter + gemaraHistory[selectedRow].number)
        } else {
            print(mishnaHistory[selectedRow].book + mishnaHistory[selectedRow].chapter + mishnaHistory[selectedRow].number)
        }
    }
    
    func videoPressed(selectedRow: Int, isFirstCollection: Bool) {
        print("Video pressed")
        if isFirstCollection {
            print(gemaraHistory[selectedRow].book + gemaraHistory[selectedRow].chapter + gemaraHistory[selectedRow].number)
        } else {
            print(mishnaHistory[selectedRow].book + mishnaHistory[selectedRow].chapter + mishnaHistory[selectedRow].number)
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
}
