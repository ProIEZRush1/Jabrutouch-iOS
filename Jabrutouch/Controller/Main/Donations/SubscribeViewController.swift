//
//  ThirdChildViewController.swift
//  Jabrutouch
//
//  Created by AviDeutsch on 26/02/2020.
//  Copyright © 2020 Ravtech. All rights reserved.
//

import UIKit
import Lottie

class SubscribeViewController: UIViewController {
    
    @IBOutlet weak var ketarimLabel: UILabel!
    @IBOutlet weak var hearts: UILabel!
    @IBOutlet weak var progress: UIView!
    @IBOutlet var progressAnimation: UIView!
    @IBOutlet weak var progressAnimationTraiing: NSLayoutConstraint!
    var unUsedCrowns = 52
    var allCrowns = 189
    var likes = 0
    let animationFileUrl = URL(fileURLWithPath: "/Users/avrahamdeutsch/Workspace/jabrutouch_ios/Jabrutouch/Supporting Files/lf20_QuQgM5.json")
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.ketarimLabel.text = "\(unUsedCrowns) out of \(allCrowns) Ketarim"
        self.hearts.text = "\(likes)"
//        self.progressAnimation = AnimationView.init(filePath: self.animationFileUrl.absoluteString)
        self.setRoundCorners()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.setRoundCorners()
    }
    // Do any additional setup after loading the view.
    
    override func viewDidLayoutSubviews() {
        setConstraints()
    }
    private func setRoundCorners() {
        self.progress.layer.cornerRadius = self.progress.bounds.height / 2
        self.progressAnimation.layer.cornerRadius = self.progressAnimation.bounds.height / 2
        
    }
    private func setConstraints() {
        let ratio = CGFloat(self.allCrowns  / self.unUsedCrowns )
        let width = self.progress.bounds.width
        self.progressAnimationTraiing.constant = width - width * (100 / ratio / 100)
        self.progressAnimation.updateConstraints()
        
    }
}
