//
//  ThirdChildViewController.swift
//  Jabrutouch
//
//  Created by AviDeutsch on 26/02/2020.
//  Copyright © 2020 Ravtech. All rights reserved.
//

import UIKit
import Lottie

class SubscribeViewController: UIViewController, DonationManagerDelegate {
    
    //========================================
    // MARK: - Properties
    //========================================
    var userDonation : JTUserDonation?
    var unUsedCrowns = 0
    var allCrowns = 0
    var likes = 0
    
    //========================================
    // MARK: - @IBOutlets
    //========================================
    
    @IBOutlet weak var yourTzedakaLabel: UILabel!
    @IBOutlet weak var ketarimLabel: UILabel!
    @IBOutlet weak var hearts: UILabel!
    @IBOutlet weak var progress: UIView!
    @IBOutlet var progressAnimation: UIView!
    @IBOutlet weak var progressAnimationTraiing: NSLayoutConstraint!
    @IBOutlet weak var subsciptionButton: UIButton!
    @IBOutlet weak var numberOfKetarimSubTitle: UILabel!
    @IBOutlet weak var thankedYouLabel: UILabel!
    
    //========================================
    // MARK: - Setup
    //========================================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.userDonation = DonationManager.shared.userDonation
//        DonationManager.shared.delegate = self
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.setRoundCorners()
        self.setDonationData()
    }
    
    override func viewDidLayoutSubviews() {
        self.setConstraints()

    }
   
    private func setRoundCorners() {
        self.progress.layer.cornerRadius = self.progress.bounds.height / 2
        self.progressAnimation.layer.cornerRadius = self.progressAnimation.bounds.height / 2
        
    }
    
    private func setConstraints() {
        if self.unUsedCrowns == 0 || self.allCrowns == 0 {
            return
        }        
        let ratio = CGFloat(1 - (Float(self.unUsedCrowns) / Float(self.allCrowns)))
        self.setProgress(ratio)
        let width = self.progress.bounds.width
        self.progressAnimationTraiing.constant = width * ratio
        self.progressAnimation.updateConstraints()
        self.view.layoutIfNeeded()
        self.setAnimation()
        
    }
    
    private func setProgress(_ ratio: CGFloat){
        if ratio > 0.5 {
            progress.linearGradientView(colors: [#colorLiteral(red: 1, green: 0.373, blue: 0.314, alpha: 1), #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)], locations: [0.14, 1], startPoint:CGPoint(x: 0.25, y: 0.5),endPoint: CGPoint(x: 1, y: 0.5))
            
        }else{
            progress.linearGradientView(colors: [#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1), #colorLiteral(red: 0.911535253, green: 0.9137482772, blue: 1, alpha: 1)], locations: [0, 1], startPoint:CGPoint(x: 0, y: 0.2),endPoint: CGPoint(x: 0, y: 1))
        }
    }
    
    func setAnimation() {
        let animationView = AnimationView()
        let animation = Animation.named("animation", bundle: Bundle.main)
        animationView.animation = animation
        animationView.loopMode = .loop
        animationView.frame = self.progressAnimation.frame
        animationView.layer.cornerRadius = animationView.bounds.height / 2
        progressAnimation.addSubview(animationView)
        self.view.layoutIfNeeded()
        
        animationView.play()
    }
    
    private func setText() {
        let string = String(format: Strings.numberOfKetarimLeft, arguments: ["\(self.unUsedCrowns)", "\(self.allCrowns)"])
        let attributedString = NSMutableAttributedString(string: string, attributes: [NSAttributedString.Key.font: Fonts.mediumDisplayFont(size:18)])
        let range = (string as NSString).range(of: "\(self.unUsedCrowns)")
        attributedString.addAttributes([NSAttributedString.Key.font: Fonts.boldFont(size:27)], range: range)
        self.numberOfKetarimSubTitle.attributedText = attributedString
        self.ketarimLabel.text = Strings.numberOfKetarimSubTitle
        self.ketarimLabel.font = Fonts.regularFont(size: 14)
        self.hearts.text = "\(self.likes)"
        self.thankedYouLabel.text = Strings.thankedYou
        self.subsciptionButton.setTitle(Strings.yourSubscription, for: .normal)
        self.yourTzedakaLabel.text = Strings.yourDonation
    }
    
    private func setDonationData() {
        guard let userDonation = self.userDonation else { return }
        self.allCrowns = userDonation.allCrowns
        self.unUsedCrowns = userDonation.unUsedCrowns
        self.likes = userDonation.likes
        self.setText()
    }
    
    @IBAction func subsciptionPressed(_ sender: Any) {
        let nc = NotificationCenter.default
        nc.post(name: NSNotification.Name(rawValue: "subscribePressed"), object: nil)
    }
    
    func userDonationDataReceived() {
        self.setDonationData()
    }
    
}
