//בעזרת ה׳ החונן לאדם דעת
//  WalkThroughViewController.swift
//  Jabrutouch
//
//  Created by Yoni Reiss on 15/07/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import UIKit

class WalkThroughViewController: UIViewController {

    @IBOutlet weak private var collectionView: UICollectionView!
    @IBOutlet weak var barPageIndicator: JBBarPageIndicator!

    override func viewDidLoad() {
        super.viewDidLoad()
                
    }
    
    private func navigateToSignIn() {
        self.performSegue(withIdentifier: "presentSignIn", sender: nil)
    }

}

extension WalkThroughViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "walkThroughCell", for: indexPath) as? WalkThroughCollectionViewCell
        else {
            return UICollectionViewCell()
        }
        cell.setIndex(indexPath.item)
        return cell
    }
}

extension WalkThroughViewController: UICollectionViewDelegate {
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x > scrollView.bounds.width*3 {
            self.navigateToSignIn()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x < scrollView.bounds.width*0.5 {
            self.barPageIndicator.selectedIndex = 0
        }
        else if scrollView.contentOffset.x < scrollView.bounds.width*1.5 {
            self.barPageIndicator.selectedIndex = 1
        }
        else if scrollView.contentOffset.x < scrollView.bounds.width*2.5 {
            self.barPageIndicator.selectedIndex = 2
        }
        else {
            self.barPageIndicator.selectedIndex = 3
        }
        
    }
}
extension WalkThroughViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
}
