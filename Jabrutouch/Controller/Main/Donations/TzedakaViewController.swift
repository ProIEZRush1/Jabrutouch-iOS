//
//  TzedakaViewController.swift
//  Jabrutouch
//
//  Created by Shlomo Carmen on 23/02/2020.
//  Copyright © 2020 Ravtech. All rights reserved.
//

import UIKit
import SwiftWebSocket

enum donationDisplay {
    case noDonation
    case singleDonation
    case subscribe
    case thankYou
    case donatePending
    
}
class TzedakaViewController: UIViewController, DedicationViewControllerDelegate{
    
    
    //========================================
    // MARK: - Properties
    //========================================
    var delegate: MainModalDelegate?
    var userDonation : JTUserDonation?
    var childToPresent: Int?
    var isSubscription: Bool?
    var isPending: Bool = UserDefaultsProvider.shared.donationPending
    var user: JTUser?
    
    var isConnected = false
    var watchCount: Int?
    
    //========================================
    // MARK: - @IBOutlets
    //========================================
    @IBOutlet weak var buttonsView: UIView!
    @IBOutlet weak var myPlanButton: UIButton!
    @IBOutlet weak var historyButton: UIButton!
    @IBOutlet weak var donateButton: UIButton!
    @IBOutlet weak var donateView: UIView!
    @IBOutlet weak var childsContainer: UIView!
    @IBOutlet weak var noDonationContainer: UIView!
    @IBOutlet weak var singleDonationContainer: UIView!
    @IBOutlet weak var subscribeContainer: UIView!
    @IBOutlet weak var thankYouContainer: UIView!
    @IBOutlet weak var donatePendingContainer: UIView!
    
    
    @IBOutlet weak var firstView: HoursView!
    @IBOutlet weak var secondView: HoursView!
    @IBOutlet weak var thirdView: HoursView!
    @IBOutlet weak var fourthView: HoursView!
    @IBOutlet weak var fifthView: HoursView!
    @IBOutlet weak var sixthView: HoursView!
    
    //    weak var noDonationViewController: NoDonationViewController?
    weak var singleDonationViewController: SingleDonationViewController?
    weak var subscribeViewController: SubscribeViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DonationManager.shared.getUserDonation()
        self.setRoundCorners()
        self.setBorders()
        self.setShadows()
        self.userDonation = DonationManager.shared.userDonation
        self.setHoursViews()
        
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(subscribePressed), name: NSNotification.Name(rawValue: "subscribePressed"), object: nil)

       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.watchCount = DonationManager.shared.userDonation?.watchCount
        self.user = UserRepository.shared.getCurrentUser()
        self.setContainerView()
        //        self.setContainerView()
//        self.present(donationDisplay.noDonation)
//        self.present(donationDisplay.singleDonation)
//self.present(donationDisplay.subscribe)
//        self.present(donationDisplay.thankYou)
//        self.present(donationDisplay.donatePending)

        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.initSwiftWebSocket()
        guard let counter = self.watchCount else {return}
        self.changeValue(counter)
    }
    //========================================
    // MARK: - LifeCycle
    //========================================
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.portrait]
    }
    
    //========================================
    // MARK: - Setup
    //========================================
    
    private func setRoundCorners() {
        self.donateView.layer.cornerRadius = 10
        self.donateView.clipsToBounds = true
        self.buttonsView.layer.cornerRadius = self.buttonsView.bounds.height / 2
        self.myPlanButton.layer.cornerRadius = self.myPlanButton.bounds.height / 2
        self.historyButton.layer.cornerRadius = self.historyButton.bounds.height / 2
        self.donateButton.layer.cornerRadius = 14
    }
    private func setBorders() {
        self.buttonsView.layer.borderColor = Colors.borderGray.cgColor
        self.buttonsView.layer.borderWidth = 1.0
    }
    
    private func setShadows() {
        let shadowOffset = CGSize(width: 0.0, height: 12)
        let color = #colorLiteral(red: 0.16, green: 0.17, blue: 0.39, alpha: 0.2)
        Utils.dropViewShadow(view: self.buttonsView, shadowColor: color, shadowRadius: 20, shadowOffset: shadowOffset)
        Utils.dropViewShadow(view: self.donateView, shadowColor: color, shadowRadius: 20, shadowOffset: shadowOffset)
        
    }
    
    func createPayment() {
        self.present(donationDisplay.thankYou)
        DispatchQueue.main.asyncAfter(deadline: .now() + 10){
            self.setContainerView()
        }
    }
    
    func setNumberView(view: HoursView) {
        view.layer.cornerRadius = 4
        view.layer.borderColor = Colors.borderGray.cgColor
        view.layer.borderWidth = 1
    }
    
    func setHoursViews() {
        self.setNumberView(view: self.firstView)
        self.setNumberView(view: self.secondView)
        self.setNumberView(view: self.thirdView)
        self.setNumberView(view: self.fourthView)
        self.setNumberView(view: self.fifthView)
        self.setNumberView(view: self.sixthView)
    }
    
    func initSwiftWebSocket() {
        let webSocket = SwiftWebSocket.WebSocket("wss://jabrutouch-dev.ravtech.co.il/ws/lesson_watch_count")
        
        webSocket.event.open = {
            print("SwiftWebSocket opened")
        }
        
        webSocket.event.error = { (error) in
            print("SwiftWebSocket error: \(error)")
        }
        
        webSocket.event.message = self.webSocket(didReceive:)

        webSocket.open()
    }
    
    func webSocket(didReceive message: Any) {
        let contentString = message as! String
        guard let content = Utils.convertStringToDictionary(contentString) as? [String:Any] else { return }

        if let watchCount = content["watch_count"] as? Int {
            self.changeValue(watchCount)
        }
    }

    @objc func subscribePressed(){
        performSegue(withIdentifier: "presentSetings", sender: self)
    }
    
    func changeValue(_ counter: Int) {

        var digits = "\(counter)".compactMap{ $0.wholeNumberValue }
        while digits.count < 6 {
            digits.insert(0, at: 0)
        }
        if self.firstView.currentLabel.text != "\(digits[0])" {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.firstView.changeValue(newValue: "\(digits[0])")
            }
        }
        if self.secondView.currentLabel.text != "\(digits[1])" {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                self.secondView.changeValue(newValue: "\(digits[1])")
            }
        }
        if self.thirdView.currentLabel.text != "\(digits[2])" {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                self.thirdView.changeValue(newValue: "\(digits[2])")
            }
        }
        if self.fourthView.currentLabel.text != "\(digits[3])" {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                self.fourthView.changeValue(newValue: "\(digits[3])")
            }
        }
        if self.fifthView.currentLabel.text != "\(digits[4])" {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.fifthView.changeValue(newValue: "\(digits[4])")
            }
        }
        if self.sixthView.currentLabel.text != "\(digits[5])" {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                self.sixthView.changeValue(newValue: "\(digits[5])")
            }
        }
        
    }
    
    func setContainerView(){
        guard let userDonation = self.userDonation else { return }
        guard let user = self.user else { return }
        let donated = user.lessonDonated?.donated
        if isPending && donated == false {
            self.present(donationDisplay.donatePending)
            return
        }
        if userDonation.donatePerMonth > 0 {
            self.present(donationDisplay.subscribe)
        }
        else if userDonation.donatePerMonth == 0 {
            self.present(donationDisplay.singleDonation)
        }
        if userDonation.allCrowns == 0 {
            self.present(donationDisplay.noDonation)
        }
        
    }
    
    func present(_ childToPresent: donationDisplay){
        if childToPresent == donationDisplay.noDonation {
            self.noDonationContainer.isHidden = false
            self.singleDonationContainer.isHidden = true
            self.subscribeContainer.isHidden = true
            self.thankYouContainer.isHidden = true
            self.donatePendingContainer.isHidden = true
        }
        else if childToPresent == donationDisplay.singleDonation {
            self.noDonationContainer.isHidden = true
            self.singleDonationContainer.isHidden = false
            self.subscribeContainer.isHidden = true
            self.thankYouContainer.isHidden = true
            self.donatePendingContainer.isHidden = true
        }
        else if childToPresent == donationDisplay.subscribe {
            self.noDonationContainer.isHidden = true
            self.singleDonationContainer.isHidden = true
            self.subscribeContainer.isHidden = false
            self.thankYouContainer.isHidden = true
            self.donatePendingContainer.isHidden = true
        }
        else if childToPresent == donationDisplay.thankYou {
            self.noDonationContainer.isHidden = true
            self.singleDonationContainer.isHidden = true
            self.subscribeContainer.isHidden = true
            self.thankYouContainer.isHidden = false
            self.donatePendingContainer.isHidden = true
        }
        else if childToPresent == donationDisplay.donatePending {
            self.noDonationContainer.isHidden = true
            self.singleDonationContainer.isHidden = true
            self.subscribeContainer.isHidden = true
            self.thankYouContainer.isHidden = true
            self.donatePendingContainer.isHidden = false
        }
    }
    
    
    
    
    //========================================
    // MARK: - Actions
    //========================================
    
    
    @IBAction func backButtonBack(_ sender: Any) {
        self.delegate?.dismissMainModal()
    }
    
    @IBAction func myPlanButtonPressed(_ sender: Any) {
    }
    
    @IBAction func historyButtonPressed(_ sender: Any) {
        Utils.showAlertMessage(Strings.inDevelopment, viewControler: self)
    }
    
    @IBAction func donateButtonPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "presentDonation", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       
        if segue.identifier == "singleDonation" {
            let singleDonationVC = segue.destination as? SingleDonationViewController
            singleDonationVC?.unUsedCrowns = 170 //self.userDonation?.unUsedCrowns ?? 0
            singleDonationVC?.allCrowns = 20 //self.userDonation?.allCrowns ?? 0
            singleDonationVC?.likes = self.userDonation?.likes ?? 0
            self.singleDonationViewController = singleDonationVC
            
        }
        else if segue.identifier == "subscribe" {
            let subscribeDonationVC = segue.destination as? SubscribeViewController
            subscribeDonationVC?.unUsedCrowns = 15// self.userDonation?.unUsedCrowns ?? 0
            subscribeDonationVC?.allCrowns = 50 //self.userDonation?.allCrowns ?? 0
            subscribeDonationVC?.likes = self.userDonation?.likes ?? 0
            self.subscribeViewController = subscribeDonationVC
        }
    }
}

