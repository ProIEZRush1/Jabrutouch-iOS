//
//  NewsFeedViewController.swift
//  Jabrutouch
//
//  Created by Avraham Kirsch on 26/08/2021.
//  Copyright © 2021 Ravtech. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

class NewsFeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    //============================================================
    // MARK: - Properties
    //============================================================
    
    var newsItemsList: [JTNewsFeedItem] = []
    private var activityView: ActivityView?
//    private var mediaPlayer: AVPlayer?
//    private var mediaPlayerLayer: AVPlayerLayer?
    
    //============================================================
    // MARK: - Outlets
    //============================================================
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    //============================================================
    // MARK: - LifeCycle
    //============================================================
    override func viewDidLoad() {
        super.viewDidLoad()
        self.showActivityView()
        self.newsItemsList = NewsFeedRepository.shared.getAllNewsItems(offSet: nil)
        self.removeActivityView()
        
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.portrait]
    }

    //============================================================
    // MARK: - Actions
    //============================================================
    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //========================================
    // MARK: - Setup
    //========================================
    
    private func setTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    //============================================================
    // MARK: - TableView
    //============================================================
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.newsItemsList.count
//        10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) ->
    UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "newsItemCell", for: indexPath) as! NewsItemCell

        let post = self.newsItemsList[indexPath.row]
        
        cell.imageBox.isHidden = (post.mediaType != .image)
        cell.audioView.isHidden = (post.mediaType != .audio)
        cell.videoView.isHidden = (post.mediaType != .video)
        
        switch post.mediaType {
        case .audio:
            break
        case .image:
//            if let imageUrl:URL = URL(string: post.mediaLink!){
//                // Start background thread so that image loading does not make app unresponsive
//                  DispatchQueue.global().async {
//
//                    guard let imageData = try? Data(contentsOf: imageUrl) else {
//                        cell.imageBox.isHidden = true
//                        return
//                    }
//
//                    // When from a background thread, UI needs to be updated on main_queue
//                   DispatchQueue.main.async {
//                        let image = UIImage(data: imageData)
//                        cell.imageBox.image = image
//                    cell.imageBox.isHidden = false
//                    }
//                }
//            }
            if let imageURL = URL(string: post.mediaLink ?? ""){
                DispatchQueue.main.async {
                    cell.imageBox.load(url: imageURL)
                    cell.imageBox.isHidden = false
                }
                
            } else {
                cell.imageBox.isHidden = true
            }
            break
        case .video:
            if let videoURL = URL(string:post.mediaLink!){
                cell.setVideo(videoURL: videoURL)
            } else {
                cell.videoView.isHidden = true
            }
            break
        case .noMedia:
            break
        }
        
        if !(post.body?.isEmpty ?? true) {
            cell.textBox.text = post.body
            cell.textBox.isHidden = false
        } else {
            cell.textBox.isHidden = true
        }
        
        Utils.setViewShape(view: cell.newsItemView, viewCornerRadius: 18)
        let shadowOffset = CGSize(width: 0.0, height: 5)
        Utils.dropViewShadow(view: cell.newsItemView, shadowColor: Colors.shadowColor, shadowRadius: 15 , shadowOffset: shadowOffset)
        cell.newsItemView.layoutIfNeeded()
        
        
        

        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 500
    }
    
    
    //============================================================
    // MARK: - ActivityView
    //============================================================
    
    private func showActivityView() {
        DispatchQueue.main.async {
            if self.activityView == nil {
                self.activityView = Utils.showActivityView(inView: self.view, withFrame: self.view.frame, text: nil)
            }
        }
    }
    private func removeActivityView() {
        DispatchQueue.main.async {
            if let view = self.activityView {
                Utils.removeActivityView(view)
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
