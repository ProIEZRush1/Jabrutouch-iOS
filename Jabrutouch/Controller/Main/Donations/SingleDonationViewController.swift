//
//  SecondChildViewController.swift
//  Jabrutouch
//
//  Created by AviDeutsch on 25/02/2020.
//  Copyright © 2020 Ravtech. All rights reserved.
//

import UIKit

class SingleDonationViewController: UIViewController, DonationManagerDelegate {
    
    @IBOutlet var ketarimLabel: UILabel!
    @IBOutlet weak var progress: UIView!
    @IBOutlet var progressAnimation: UIView!
    @IBOutlet weak var progressAnimationTraiing: NSLayoutConstraint!
    @IBOutlet weak var hearts: UILabel!
    @IBOutlet weak var numberOfKetarimSubTitle: UILabel!
    @IBOutlet weak var yourTzedakaLabel: UILabel!
    @IBOutlet weak var thankedYouLabel: UILabel!
    
    var userDonation : JTUserDonation?
    private var activityView: ActivityView?
    var unUsedCrowns = 120
    var allCrowns = 340
    var likes = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setRoundCorners()
        self.userDonation = DonationManager.shared.userDonation
    }
    
    override func viewWillAppear(_ animated: Bool) {
        DonationManager.shared.delegate = self
        self.setDonationData()
        if self.userDonation == nil {
            self.showActivityView()
        }
        self.setConstraints()
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
        
    }
    
    private func setProgress(_ ratio: CGFloat){
        if ratio > 0.5 {
            progress.linearGradientView(colors: [#colorLiteral(red: 1, green: 0.373, blue: 0.314, alpha: 1), #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)], locations: [0.14, 1], startPoint:CGPoint(x: 0.25, y: 0.5),endPoint: CGPoint(x: 1, y: 0.5))
            
        }else{
            progress.linearGradientView(colors: [#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1), #colorLiteral(red: 0.911535253, green: 0.9137482772, blue: 1, alpha: 1)], locations: [0, 1], startPoint:CGPoint(x: 0, y: 0.2),endPoint: CGPoint(x: 0, y: 1))
            
        }
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
        self.yourTzedakaLabel.text = Strings.yourDonation
        self.thankedYouLabel.text = Strings.thankedYou
    }
    
    private func setDonationData() {
        guard let userDonation = self.userDonation else { return }
        self.allCrowns = userDonation.allCrowns
        self.unUsedCrowns = userDonation.unUsedCrowns
        self.likes = userDonation.likes
        self.setText()
    }
    
    func donationsDataReceived() {
        self.removeActivityView()
        self.setDonationData()
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
