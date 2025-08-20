//
//  TzedakaViewController.swift
//  Jabrutouch
//
//  Created by Shlomo Carmen on 23/02/2020.
//  Copyright © 2020 Ravtech. All rights reserved.
//

import UIKit
import Starscream

enum donationDisplay {
    case noDonation
    case singleDonation
    case subscription
    case thankYou
    case donatePending
    
}
class TzedakaViewController: UIViewController, DedicationViewControllerDelegate, DonationManagerDelegate, WebSocketDelegate {
    
    //========================================
    // MARK: - Properties
    //========================================
    var delegate: MainModalDelegate?
    var userDonation : JTUserDonation?
    var childToPresent: Int?
    var isSubscription: Bool?
    var isPending: Bool = UserDefaultsProvider.shared.donationPending
    var user: JTUser?
    private var activityView: ActivityView?
    var isConnected = false
    var watchCount: Int?
    
    weak var singleDonationViewController: SingleDonationViewController?
    weak var subscribeViewController: SubscribeViewController?
    
    //========================================
    // MARK: - @IBOutlets
    //========================================
    
    @IBOutlet weak var titleLabel: UILabel!
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
    
    @IBOutlet weak var hoursViewTitleLabel: UILabel!
    @IBOutlet weak var firstView: HoursView!
    @IBOutlet weak var secondView: HoursView!
    @IBOutlet weak var thirdView: HoursView!
    @IBOutlet weak var fourthView: HoursView!
    @IBOutlet weak var fifthView: HoursView!
    @IBOutlet weak var sixthView: HoursView!
    
    //========================================
    // MARK: - LifeCycle
    //========================================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DonationManager.shared.getUserDonation()
        self.setRoundCorners()
        self.setBorders()
        self.setShadows()
        self.userDonation = DonationManager.shared.userDonation
        self.setHoursViews()
        self.setText()
        DonationManager.shared.donationManagerDelegate = self
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(subscribePressed), name: NSNotification.Name(rawValue: "subscribePressed"), object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.watchCount = DonationManager.shared.userDonation?.watchCount
        self.user = UserRepository.shared.getCurrentUser()
        self.setContainerView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.initWebSocket()
        self.watchCount = DonationManager.shared.userDonation?.watchCount
        guard let counter = self.watchCount else { return }
        self.changeValue(counter)
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return [.portrait, .landscapeLeft, .landscapeRight]
        } else {
            return [.portrait]
        }
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
    
    func setText() {
        self.myPlanButton.setTitle(Strings.myPlan, for: .normal)
        self.historyButton.setTitle(Strings.history, for: .normal)
        self.donateButton.setTitle(Strings.donateCapital, for: .normal)
        self.hoursViewTitleLabel.text = Strings.hoursLearnedGlobally
        self.titleLabel.text = Strings.tzedaka
    }
    
    //========================================
    // MARK: - Container View
    //========================================
    
    func setContainerView(){
        guard let userDonation = self.userDonation else {
            self.showActivityView()
            return
        }
        guard let user = self.user else { return }
        let donated = user.lessonDonated?.donated
        if isPending && donated == false {
            self.present(donationDisplay.donatePending)
            return
        }
        if userDonation.donatePerMonth > 0 {
            self.present(donationDisplay.subscription)
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
        else if childToPresent == donationDisplay.subscription {
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
    // MARK: - Delegate Functions
    //========================================
    
    func userDonationDataReceived() {
        DispatchQueue.main.async {
            self.removeActivityView()
            self.view.layoutIfNeeded()
            self.setContainerView()
        }
    }
    
    func createPayment() {
        self.setContainerView()
        //        self.present(donationDisplay.thankYou)
        //        DispatchQueue.main.asyncAfter(deadline: .now() + 10){
        //        }
    }
    
    //========================================
    // MARK: - Actions
    //========================================
    
    @objc func subscribePressed(){
        performSegue(withIdentifier: "presentSetings", sender: self)
    }
    
    @IBAction func backButtonBack(_ sender: Any) {
        self.delegate?.dismissMainModal()
    }
    
    @IBAction func myPlanButtonPressed(_ sender: Any) {
    }
    
    @IBAction func historyButtonPressed(_ sender: Any) {
        Utils.showAlertMessage(Strings.inDevelopment, viewControler: self)
    }
    
    @IBAction func donateButtonPressed(_ sender: Any) {
        //        UserDefaultsProvider.shared.videoWatched = true
        self.performSegue(withIdentifier: "presentDonation", sender: self)
    }
    
    //============================================================
    // MARK: - Web Socket
    //============================================================
    
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
    
    var socket: WebSocket?
    func initWebSocket() {
        var request = URLRequest(url: URL(string: "wss://jabrutouch.bluemango.com.mx/ws/lesson_watch_count")!)
        request.timeoutInterval = 5
        socket = WebSocket(request: request)
        self.socket?.delegate = self
        self.socket?.connect()
    }
    
    func didReceive(event: Starscream.WebSocketEvent, client: any Starscream.WebSocketClient) {
        switch event {
        case .connected(_):
            print("Starscream WebSocket connected")
        case .disconnected(let reason, let code):
            print("WebSocket disconnected: \(reason) (code: \(code))")
        case .text(let text):
            handleWebSocketMessage(text)
        case .error(let error):
            if let error = error {
                print("WebSocket error: \(error.localizedDescription)")
            }
        default:
            break
        }
    }
    
    func handleWebSocketMessage(_ message: String) {
        guard let content = Utils.convertStringToDictionary(message) as? [String: Any] else { return }
        if let watchCount = content["watch_count"] as? Int {
            self.changeValue(watchCount)
        }
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
    
    //============================================================
    // MARK: - Navgation
    //============================================================
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "presentSetings" {
            let changeSettingsVC = segue.destination as? ChangeSettingsViewController
            changeSettingsVC?.userDonation = self.userDonation
        }
    }
    
}

