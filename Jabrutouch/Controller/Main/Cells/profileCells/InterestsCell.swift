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
        
//        let label = UILabel()
//               label.font = UIFont.systemFont(ofSize: 14) //Your font and size
//               label.numberOfLines = 0
//               label.text = "Topic \(indexPath.item + 1)" // Your text
//               let width = label.sizeThatFits(CGSize(width: 300, height: 600)).width

        cell.topicLabel.text = "Topic \(indexPath.item + 1)"
//        cell.topicLabel.frame.size.width = width + 10.0
        cell.topicLabel.layer.cornerRadius = cell.topicLabel.bounds.height/2
        cell.topicLabel.sizeToFit()
        cell.topicLabel.adjustsFontSizeToFitWidth = true
        
//        cell.topicLabel.clipsToBounds = true
        cell.topicLabel.layer.shadowColor = #colorLiteral(red: 0.1, green: 0.12, blue: 0.57, alpha: 0.8).cgColor
        cell.topicLabel.layer.shadowOffset = CGSize(width: 0, height: 12)
        cell.topicLabel.layer.shadowOpacity = 1.0
        cell.topicLabel.layer.shadowRadius = 36
//        cell.topicLabel.layer.masksToBounds = false
//        cell.topicLabel.translatesAutoresizingMaskIntoConstraints = false
        return cell
    }
    

}
