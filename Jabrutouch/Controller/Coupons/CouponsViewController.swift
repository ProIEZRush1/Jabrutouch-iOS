//
//  CouponsViewController.swift
//  Jabrutouch
//
//  Created by Avraham Deutsch on 02/08/2020.
//  Copyright © 2020 Ravtech. All rights reserved.
//

import UIKit

class CouponsViewController: UIViewController {
    
    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var textWithCrown: UILabel!
    @IBOutlet weak var blueButtonBox: UIView!
    @IBOutlet weak var whiteButtonBox: UIView!
    var values: JTDeepLinkCoupone?
    var crowns: String?
    var userName: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        userName = UserDefaultsProvider.shared.currentUser?.firstName
        setup()
        setDetails()
    }
    
    func setup(){
        alertView.layer.cornerRadius = 15
        blueButtonBox.layer.cornerRadius = 15
        whiteButtonBox.layer.cornerRadius = 15
        whiteButtonBox.layer.borderWidth = 1
        whiteButtonBox.layer.borderColor = #colorLiteral(red: 0.1764705882, green: 0.168627451, blue: 0.662745098, alpha: 1)
    }
    
    func setDetails(){
        
        if let name = userName {
            userNameLabel.text = name
        }
        if let sum = crowns {
            textWithCrown.text = "Se han agregado \(sum) Ketarim a tu cuenta de Jabrutouch."
        }
//
        
    }
    
    @IBAction func blueButtonPressed(_ sender: Any) {
        guard let value = self.values else { return }
        let donation = Storyboards.Donation.dedicationViewController
        donation.fromDeepLink = true
        donation.dedication = DonationManager.shared.dedication
        donation.couponeValue = value
        donation.postDedication = JTPostDedication(sum: Int(self.crowns ?? "0") ?? 0, paymenType: 1, nameToRepresent: "", dedicationText:"", status: "", dedicationTemplate: 1)
        self.present(donation, animated: true, completion: nil)
        
    }
    
    @IBAction func whiteButtonPressed(_ sender: Any) {
        guard let value = self.values else { return }
        let postCoupon = JTCouponRedemption(coupon: value.couponDistributor)
        couponRedemption(postCoupone: postCoupon)
    }
    
    func couponRedemption(postCoupone: JTCouponRedemption){
        DonationManager.shared.createCouponRedemption(postCoupone){ (result) in
            switch result {
            case .success(let success):
                print(success)
                UserDefaultsProvider.shared.donationPending = true
                DispatchQueue.main.async {
                    let mainViewController = Storyboards.Main.mainViewController
                    mainViewController.modalPresentationStyle = .fullScreen
                    self.present(mainViewController, animated: false, completion: nil)
                    mainViewController.presentDonationsNavigationViewController()
                }
            case .failure(let error):
                print(error)
                DispatchQueue.main.async {
                let vc = Storyboards.Coupons.invalidCouponeViewController
                self.present(vc, animated: true, completion: nil)
                }
                Utils.showAlertMessage("No se pudo crear el canje del cupón, inténtelo de nuevo", viewControler: self)
            }
        }
    }
}
