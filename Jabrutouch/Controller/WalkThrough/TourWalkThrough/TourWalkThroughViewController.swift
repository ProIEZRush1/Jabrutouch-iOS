//
//  TourWalkThroughViewController.swift
//  Jabrutouch
//
//  Created by Avraham Deutsch on 20/07/2020.
//  Copyright © 2020 Ravtech. All rights reserved.
//

import UIKit

class TourWalkThroughViewController: UIViewController {

    @IBOutlet weak private var collectionView: UICollectionView!
    @IBOutlet weak var barPageIndicator: JTTourBarPageIndicator!
    @IBOutlet weak var buttonView: UIView!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var ButtonText: UILabel!
    @IBOutlet weak var link: UITextView!
    @IBOutlet weak var exitButton: UIButton!
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.portrait]
    }
    var index = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }
    
    func setup(){
        buttonView.layer.cornerRadius = buttonView.bounds.height / 2
        setItems(index: index)
        let attributedString = NSMutableAttributedString(string: "¿Qué es el Talmud?")
        attributedString.addAttribute(.link, value: "https://www.jabrutouch.com/", range: NSRange(location: 0, length: attributedString.string.count))
        
        link.attributedText = attributedString
        link.textAlignment = .center
    }

    //============================================================
    // MARK: - Actions
    //============================================================
    
    @IBAction func buttonPressed(_ sender: Any) {
        if self.index < 3 {
            let indexPath = IndexPath(item: self.index + 1, section: 0)
            collectionView.scrollToItem(at: indexPath, at: .left, animated: true)
        } else {
            self.performSegue(withIdentifier: "main", sender: self)
        }
    
    }
    @IBAction func exitButtonPressed(_ sender: Any) {
        navigateToMain()
    }
    
    //============================================================
    // MARK: - Navigation
    //============================================================
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "main" {
            let mainVC = segue.destination as? MainViewController
            mainVC?.presentTodayDafLessonVideo()
        }
    }
    
    private func navigateToMain() {
        let mainViewController = Storyboards.Main.mainViewController
        appDelegate.setRootViewController(viewController: mainViewController, animated: true)
    }
}

extension TourWalkThroughViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tourWalkThroughCell", for: indexPath) as? TourWalkThroughCollectionViewCell
        else {
            return UICollectionViewCell()
        }
        cell.setIndex(indexPath.item)
        
        return cell
    }
}

extension TourWalkThroughViewController: UICollectionViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x < scrollView.bounds.width*0.5 {
            self.setItems(index: 0)
        }
        else if scrollView.contentOffset.x < scrollView.bounds.width*1.5 {
            self.setItems(index: 1)
        }
        else if scrollView.contentOffset.x < scrollView.bounds.width*2.5 {
            self.setItems(index: 2)
        }
        else {
           self.setItems(index: 3)
        }
        
    }
    func setItems(index: Int){
        
        self.barPageIndicator.selectedIndex = index
        self.index = index
        if index == 3 {
            self.link.alpha = 1
            self.ButtonText.text = "Ir a una clase"
        } else {
            self.link.alpha = 0
            self.ButtonText.text = "Siguiente"
        }
    }
}

extension TourWalkThroughViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
}

extension TourWalkThroughViewController: UITextViewDelegate{
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        UIApplication.shared.open(URL)
        return false
    }
}
