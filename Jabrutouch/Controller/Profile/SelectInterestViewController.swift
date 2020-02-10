//
//  SelectInterestViewController.swift
//  Jabrutouch
//
//  Created by Shlomo Carmen on 17/11/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import UIKit

protocol SelectInterestViewControllerDelegate: class {
    func interestsSelected(interests: [JTUserProfileParameter])
}

class SelectInterestViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var user: JTUser?
    var interests: [JTUserProfileParameter] = []
    weak var delegate: SelectInterestViewControllerDelegate?
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.saveButton.setTitle(Strings.save, for: .normal)
//        self.titleLabel.text = Strings.topicOfInterest
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
//        self.user = UserRepository.shared.getCurrentUser()
        self.interests = EditUserParametersRepository.shared.parameters?.interest ?? []
        self.collectionView.allowsMultipleSelection = true
        for (index, interest) in self.interests.enumerated() {
            if user?.interest.contains(interest) ?? false {
                collectionView.selectItem(at: IndexPath(item: index, section: 0), animated: false, scrollPosition: .left)
            }
        }
    }
    
    @IBAction func backPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        self.delegate?.interestsSelected(interests: self.user?.interest ?? [])
        self.dismiss(animated: true, completion: nil)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.interests.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "topicCell", for: indexPath) as? TopicCollectionViewCell
        else {
            return UICollectionViewCell()
        }
        
        cell.topicLabel.text = self.interests[indexPath.item].name
        cell.shadowView.layer.cornerRadius = cell.shadowView.bounds.height/2
        let color = #colorLiteral(red: 0.1, green: 0.12, blue: 0.57, alpha: 0.1)
        Utils.dropViewShadow(view: cell.shadowView, shadowColor: color, shadowRadius: 36, shadowOffset: CGSize(width: 0, height: 12))
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let interest = self.interests[indexPath.item]
        self.user?.interest.append(interest)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let interest = self.interests[indexPath.item]
        self.user?.interest.removeAll { $0 == interest }

    }
}

extension SelectInterestViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
                let collectionViewWidth = collectionView.bounds.width
                let label = UILabel()
                label.font = Fonts.mediumTextFont(size: 14)
                label.text = interests[indexPath.item].name
                let labelWidth = label.sizeThatFits(CGSize(width: collectionViewWidth, height: 30)).width + 40
        //         let scaleFactor = (screenWidth / 3) - 6

                 return CGSize(width: labelWidth, height: 50)
    }
}
