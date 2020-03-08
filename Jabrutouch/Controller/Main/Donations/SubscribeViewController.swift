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
    
    
    @IBOutlet weak var ketarimLabel: UILabel!
    @IBOutlet weak var hearts: UILabel!
    @IBOutlet weak var progress: UIView!
    @IBOutlet var progressAnimation: UIView!
    @IBOutlet weak var progressAnimationTraiing: NSLayoutConstraint!
    @IBOutlet weak var subsciptionButton: UIButton!
    
    var userDonation : JTUserDonation?
    
    var unUsedCrowns = 30
    var allCrowns = 189
    var likes = 0
    let animationFileUrl = URL(fileURLWithPath: "/Users/avrahamdeutsch/Workspace/jabrutouch_ios/Jabrutouch/Supporting Files/lf20_QuQgM5.json")
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.ketarimLabel.text = "\(unUsedCrowns) out of \(allCrowns) Ketarim"
//        self.hearts.text = "\(likes)"
//        self.progressAnimation = AnimationView.init(filePath: self.animationFileUrl.absoluteString)
        self.setRoundCorners()
        self.setConstraints()
        self.userDonation = DonationManager.shared.userDonation
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.setRoundCorners()
        self.setDonationData()
        
    }
    
    override func viewDidLayoutSubviews() {
        setConstraints()
    }
    
    private func setRoundCorners() {
        self.progress.layer.cornerRadius = self.progress.bounds.height / 2
        self.progressAnimation.layer.cornerRadius = self.progressAnimation.bounds.height / 2
        
    }
    
    private func setConstraints() {
        if self.unUsedCrowns == 0 || self.allCrowns == 0 {
            return
        }
        let ratio = CGFloat(Float(self.unUsedCrowns) / Float(self.allCrowns))
        let width = self.progress.bounds.width
        self.progressAnimationTraiing.constant = width * ratio
        self.progressAnimation.updateConstraints()
        self.setProgress(ratio)
        
    }
    
    private func setProgress(_ ratio: CGFloat){
        if ratio > 0.5 {
            progress.linearGradientView(colors: [#colorLiteral(red: 1, green: 0.373, blue: 0.314, alpha: 1), #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)], locations: [0.14, 1], startPoint:CGPoint(x: 0.25, y: 0.5),endPoint: CGPoint(x: 1, y: 0.5))
            
        }else{
            progress.linearGradientView(colors: [#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1), #colorLiteral(red: 0.911535253, green: 0.9137482772, blue: 1, alpha: 1)], locations: [0, 1], startPoint:CGPoint(x: 0, y: 0.2),endPoint: CGPoint(x: 0, y: 1))

        }
    }
    
    private func setText() {
        self.ketarimLabel.text = "\(self.unUsedCrowns) out of \(self.allCrowns) ketarim"
        self.hearts.text = "\(self.likes)"
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
    
    func donationsDataReceived() {
        self.setDonationData()
    }
    
}
