//
//  DonationWalkThougthViewController.swift
//  Jabrutouch
//
//  Created by Avraham Deutsch on 26/07/2020.
//  Copyright © 2020 Ravtech. All rights reserved.
//

import UIKit

class DonationsWalkThroughViewController: UIViewController {

    @IBOutlet weak private var collectionView: UICollectionView!
    @IBOutlet weak var barPageIndicator: JTDonationBarPageIndicator!
    @IBOutlet weak var buttonView: UIView!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var ButtonText: UILabel!
    @IBOutlet weak var close: UIButton!
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return [.portrait, .landscapeLeft, .landscapeRight]
        } else {
            return [.portrait]
        }
    }
    var index = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }
    
    func setup(){
        buttonView.layer.cornerRadius = buttonView.bounds.height / 2
        setItems(index: index)
    }

    //============================================================
    // MARK: - Actions
    //============================================================
    
    @IBAction func buttonPressed(_ sender: Any) {
        if self.index < 2 {
            let indexPath = IndexPath(item: self.index + 1, section: 0)
            collectionView.scrollToItem(at: indexPath, at: .left, animated: true)
        } else {
            let mainViewController = Storyboards.Main.mainViewController
            mainViewController.modalPresentationStyle = .fullScreen
            self.present(mainViewController, animated: false, completion: nil)
            mainViewController.presentDonation()
        }
    
    }
    @IBAction func exitButtonPressed(_ sender: Any) {
        navigateToMain()
    }
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        navigateToMain()
    }
    //============================================================
    // MARK: - Navigation
    //============================================================
    
    
    private func navigateToMain() {
        let mainViewController = Storyboards.Main.mainViewController
        appDelegate.setRootViewController(viewController: mainViewController, animated: true)
    }
    
    
}

extension DonationsWalkThroughViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "donationWalkThroughCell", for: indexPath) as? DonationWalkThroughCollectionViewCell
        else {
            return UICollectionViewCell()
        }
        cell.setIndex(indexPath.item)
        
        return cell
    }
}

extension DonationsWalkThroughViewController: UICollectionViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x < scrollView.bounds.width*0.5 {
            self.setItems(index: 0)
        }
        else if scrollView.contentOffset.x < scrollView.bounds.width*1.5 {
            self.setItems(index: 1)
        }
        else {
           self.setItems(index: 2)
        }
        
    }
    func setItems(index: Int){
        self.barPageIndicator.selectedIndex = index
        self.index = index
        if index == 2 {
            self.close.alpha = 1
            self.ButtonText.text = "Quiero regalar ketarim"
        } else {
            self.close.alpha = 0
            self.ButtonText.text = "Siguiente"
        }
    }
}

extension DonationsWalkThroughViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
}

extension DonationsWalkThroughViewController: UITextViewDelegate{
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        UIApplication.shared.open(URL)
        return false
    }
}

