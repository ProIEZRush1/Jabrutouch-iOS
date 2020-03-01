//
//  TzedakaViewController.swift
//  Jabrutouch
//
//  Created by Shlomo Carmen on 23/02/2020.
//  Copyright © 2020 Ravtech. All rights reserved.
//

import UIKit


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
    
    weak var noDonationViewController: NoDonationViewController?
    weak var singleDonationViewController: SingleDonationViewController?
    weak var subscribeViewController: SubscribeViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setRoundCorners()
        self.setBorders()
        self.setShadows()
        self.userDonation = DonationManager.shared.userDonation
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.user = UserRepository.shared.getCurrentUser()
        //        self.setContainerView()
        self.present(2)
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
        self.present(4)
        DispatchQueue.main.asyncAfter(deadline: .now() + 10){
            self.setContainerView()
        }
    }
    
    func setContainerView(){
        guard let userDonation = self.userDonation else { return }
        guard let user = self.user else { return }
        let donated = user.lessonDonated?.donated
        if isPending && donated == false {
            self.present(5)
            return
        }
        if userDonation.donatePerMonth > 0 {
            self.present(3)
        }
       else if userDonation.donatePerMonth == 0 {
            self.present(2)
        }
        if userDonation.allCrowns == 0 {
            self.present(1)
        }
        
    }
    
    func present(_ childToPresent: Int){
        if childToPresent == 1 {
            self.noDonationContainer.isHidden = false
            self.singleDonationContainer.isHidden = true
            self.subscribeContainer.isHidden = true
            self.thankYouContainer.isHidden = true
            self.donatePendingContainer.isHidden = true
        }
        else if childToPresent == 2 {
            self.noDonationContainer.isHidden = true
            self.singleDonationContainer.isHidden = false
            self.subscribeContainer.isHidden = true
            self.thankYouContainer.isHidden = true
            self.donatePendingContainer.isHidden = true
        }
        else if childToPresent == 3 {
            self.noDonationContainer.isHidden = true
            self.singleDonationContainer.isHidden = true
            self.subscribeContainer.isHidden = false
            self.thankYouContainer.isHidden = true
            self.donatePendingContainer.isHidden = true
        }
        else if childToPresent == 4 {
            self.noDonationContainer.isHidden = true
            self.singleDonationContainer.isHidden = true
            self.subscribeContainer.isHidden = true
            self.thankYouContainer.isHidden = false
            self.donatePendingContainer.isHidden = true
        }
        else if childToPresent == 5 {
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
        if segue.identifier == "noDonation" {
            self.noDonationViewController = segue.destination as? NoDonationViewController
        }
            
        else if segue.identifier == "singleDonation" {
            let singleDonationVC = segue.destination as? SingleDonationViewController
            singleDonationVC?.ketarim = self.userDonation?.allCrowns ?? 0
            self.singleDonationViewController = singleDonationVC
            
        }
        else if segue.identifier == "subscribe" {
            let subscribeDonationVC = segue.destination as? SubscribeViewController
            subscribeDonationVC?.ketarim = self.userDonation?.allCrowns ?? 0
            self.subscribeViewController = subscribeDonationVC
        }
    }
}

