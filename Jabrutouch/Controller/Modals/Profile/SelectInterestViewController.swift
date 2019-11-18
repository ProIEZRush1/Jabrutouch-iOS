//
//  SelectInterestViewController.swift
//  Jabrutouch
//
//  Created by Shlomo Carmen on 17/11/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import UIKit

class SelectInterestViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var user: JTUser?
    var interests: [String] = []
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        user = UserDefaultsProvider.shared.currentUser
      
    }
    
    @IBAction func backPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        self.user?.interest = self.interests
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 18
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "topicCell", for: indexPath) as? TopicCollectionViewCell
        else {
            return UICollectionViewCell()
        }
        
        cell.topicLabel.text = "Topic \(indexPath.item + 1)"
        cell.shadowView.layer.cornerRadius = cell.shadowView.bounds.height/2
        cell.topicLabel.clipsToBounds = true
        
        let color = #colorLiteral(red: 0.1, green: 0.12, blue: 0.57, alpha: 0.4)
        cell.shadowView.layer.shadowPath = UIBezierPath(roundedRect: cell.shadowView.bounds, cornerRadius: cell.shadowView.bounds.height/2).cgPath

        Utils.dropViewShadow(view: cell.shadowView, shadowColor: color, shadowRadius: 36, shadowOffset: CGSize(width: 0, height: 12))
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? TopicCollectionViewCell else { return }
        cell.shadowView.backgroundColor = #colorLiteral(red: 0.102, green: 0.120, blue: 0.567, alpha: 1)
        cell.topicLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        if let interest = cell.topicLabel.text {
            self.interests.append(interest)
        }
    }
    
}

extension SelectInterestViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let numberofItem: CGFloat = 3
        let collectionViewWidth = self.collectionView.bounds.width
        let extraSpace = (numberofItem - 1) * flowLayout.minimumInteritemSpacing
        let inset = flowLayout.sectionInset.right + flowLayout.sectionInset.left
        let width = Int((collectionViewWidth - extraSpace - inset) / numberofItem)
        return CGSize(width: width, height: width)
    }
}
