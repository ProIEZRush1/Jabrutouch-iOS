//
//  InterestsCell.swift
//  Jabrutouch
//
//  Created by Shlomo Carmen on 23/10/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import UIKit

class InterestsCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var interests = [JTUserProfileParameter]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.allowsSelection = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.interests.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "topicCell", for: indexPath) as? TopicCollectionViewCell
        else {
            return UICollectionViewCell()
        }
        
        cell.topicLabel.text = interests[indexPath.item].name
        cell.shadowView.layer.cornerRadius = cell.shadowView.bounds.height/2
//        cell.topicLabel.clipsToBounds = true
        
        let color = #colorLiteral(red: 0.102, green: 0.12, blue: 0.567, alpha: 0.1)
//        cell.shadowView.layer.shadowPath = UIBezierPath(roundedRect: cell.shadowView.bounds, cornerRadius: cell.shadowView.bounds.height/2).cgPath

        Utils.dropViewShadow(view: cell.shadowView, shadowColor: color, shadowRadius: 32, shadowOffset: CGSize(width: 0, height: 12))
        
        return cell
    }
     func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let label = UILabel()
        label.font = Fonts.mediumTextFont(size: 14)
        label.text = interests[indexPath.item].name
        label.numberOfLines = 1
        let labelWidth = label.sizeThatFits(CGSize(width: 300, height: 30)).width
//         let scaleFactor = (screenWidth / 3) - 6

         return CGSize(width: labelWidth + 40, height: 32)
     }
     

}
class LeftAlignedCollectionViewFlowLayout: UICollectionViewFlowLayout {

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributes = super.layoutAttributesForElements(in: rect)

        var leftMargin = sectionInset.left
        var maxY: CGFloat = -1.0
        attributes?.forEach { layoutAttribute in
            guard layoutAttribute.representedElementCategory == .cell else {
                return
            }
            if layoutAttribute.frame.origin.y >= maxY {
                leftMargin = sectionInset.left
            }

            layoutAttribute.frame.origin.x = leftMargin

            leftMargin += layoutAttribute.frame.width + minimumInteritemSpacing
            maxY = max(layoutAttribute.frame.maxY , maxY)
        }

        return attributes
    }
}
