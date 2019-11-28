//
//  GalleryViewController.swift
//  Jabrutouch
//
//  Created by Shlomo Carmen on 28/11/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import UIKit

class GalleryViewController: UIViewController,UICollectionViewDelegate, UICollectionViewDataSource {
    

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    private var activityView: ActivityView?
    var images: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        self.setPageController()
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "galleryCell", for: indexPath) as? GalleryCell else {
            return UICollectionViewCell()
        }
        if self.activityView == nil {
            self.activityView = Utils.showActivityView(inView: cell.imageView, withFrame: cell.imageView.frame, text: nil)
        }
        self.pageControl.currentPage = indexPath.item
        let fileName = "\(self.images[indexPath.item])"
        self.getImage(fileName: fileName) { (_ result: Result<UIImage, Error>) in
            switch result {
            case .success(let image):
                DispatchQueue.main.async {
                    if let view = self.activityView {
                        Utils.removeActivityView(view)
                    }
                    cell.imageView.image = image
                }
            case .failure(let error):
                Utils.showAlertMessage(error.localizedDescription, viewControler: self)
                DispatchQueue.main.async {
                    if let view = self.activityView {
                        Utils.removeActivityView(view)
                    }
                }
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.width - 10
        let height = CGFloat(290)
        return CGSize(width: width, height: height)
    }
    
    
    func getImage(fileName: String, completion: @escaping (_ result: Result<UIImage,Error>)->Void) {
        AWSS3Provider.shared.handleFileDownload(fileName: fileName, bucketName: AWSS3Provider.appS3BucketName, progressBlock: nil) { (result) in
            switch result{
            case .success(let data):
                if let image = UIImage(data: data) {
                    completion(.success(image))
                }
                else {
                    DispatchQueue.main.async {
//                        Utils.showAlertMessage("cant show image", viewControler: self)
                        if let view = self.activityView {
                            Utils.removeActivityView(view)
                        }
                    }
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    func setPageController() {
        self.pageControl.numberOfPages = self.images.count
        
    }
    
}
