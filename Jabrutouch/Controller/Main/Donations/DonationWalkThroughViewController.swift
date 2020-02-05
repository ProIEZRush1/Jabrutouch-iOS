//
//  DonationWalkThroughViewController.swift
//  Jabrutouch
//
//  Created by Shlomo Carmen on 04/02/2020.
//  Copyright © 2020 Ravtech. All rights reserved.
//

import UIKit

class DonationWalkThroughViewController: UIViewController {
    
    @IBOutlet weak private var collectionView: UICollectionView!
    @IBOutlet weak var barPageIndicator: JTBarPageIndicator!
    @IBOutlet weak var backButton: UIButton!
    
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.portrait]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    private func navigateToDonations() {
        let donateViewController = Storyboards.Donation.donateNavigationController
        donateViewController.modalTransitionStyle = .crossDissolve
        donateViewController.modalPresentationStyle = .fullScreen
        self.present(donateViewController, animated: true)
//        appDelegate.setRootViewController(viewController: donateViewController, animated: true)
    }
    
    @IBAction func backButtonPreesed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension DonationWalkThroughViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "walkThroughCell", for: indexPath) as? WalkThroughCollectionViewCell
            else {
                return UICollectionViewCell()
        }
        cell.setIndex(indexPath.item, "donations")
        return cell
    }
}

extension DonationWalkThroughViewController: UICollectionViewDelegate {
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x > scrollView.bounds.width*3 {
            UserDefaultsProvider.shared.seenWalkThrough = true
            self.navigateToDonations()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x < scrollView.bounds.width*0.5 {
            self.barPageIndicator.selectedIndex = 0
            self.backButton.isHidden = false
        }
        else if scrollView.contentOffset.x < scrollView.bounds.width*1.5 {
            self.barPageIndicator.selectedIndex = 1
            self.backButton.isHidden = true
        }
        else if scrollView.contentOffset.x < scrollView.bounds.width*2.5 {
            self.barPageIndicator.selectedIndex = 2
            self.backButton.isHidden = true
        }
        else {
            self.barPageIndicator.selectedIndex = 3
            self.backButton.isHidden = true
        }
        
    }
}
extension DonationWalkThroughViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
    
}
