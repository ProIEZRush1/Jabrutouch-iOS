//
//  InterestsCell.swift
//  Jabrutouch
//
//  Created by Shlomo Carmen on 23/10/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import UIKit

class InterestsCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "topicCell", for: indexPath) as? TopicCollectionViewCell
        else {
            return UICollectionViewCell()
        }
        
        cell.topicLabel.text = "Topic \(indexPath.item + 1)"
        cell.topicLabel.layer.cornerRadius = cell.topicLabel.bounds.height/2
        cell.topicLabel.clipsToBounds = true
        
        let color = #colorLiteral(red: 0.1, green: 0.12, blue: 0.57, alpha: 0.4)
        cell.shadowView.layer.shadowPath = UIBezierPath(roundedRect: cell.shadowView.bounds, cornerRadius: cell.shadowView.bounds.height/2).cgPath

        Utils.dropViewShadow(view: cell.shadowView, shadowColor: color, shadowRadius: 36, shadowOffset: CGSize(width: 0, height: 12))


//        cell.shadowView.layer.shadowColor = #colorLiteral(red: 0.1, green: 0.12, blue: 0.57, alpha: 0.5).cgColor
//        cell.shadowView.layer.shadowOffset = CGSize(width: 0, height: 12)
//        cell.shadowView.layer.shadowOpacity = 1.0
//        cell.shadowView.layer.shadowRadius = 36
//        cell.shadowView.clipsToBounds = false
//        cell.shadowView.layer.masksToBounds = false
//        cell.shadowView.translatesAutoresizingMaskIntoConstraints = false
        return cell
    }
    

}
