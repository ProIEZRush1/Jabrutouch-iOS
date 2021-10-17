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
    var loadingData: Bool = true
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
        NewsFeedRepository.shared.getAllNewsItems(offSet: nil) { newsItemsResponse in
            self.newsItemsList = newsItemsResponse
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.loadingData = false
                self.removeActivityView()
            }
        }
        
        self.setAudioSession()
        
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.portrait]
    }

    //============================================================
    // MARK: - Actions
    //============================================================
    @IBAction func backButtonPressed(_ sender: Any) {
        self.removeSavedImagesFromLoader()
        self.dismiss(animated: true, completion: nil)
    }
    
    //========================================
    // MARK: - Setup
    //========================================
    
    private func setTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func setAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
        }
        catch {
            print("Setting category to AVAudioSessionCategoryPlayback failed.")
        }
    }

    
    //============================================================
    // MARK: - TableView
    //============================================================
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.newsItemsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) ->
    UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "newsItemCell", for: indexPath) as! NewsItemCell

        let post = self.newsItemsList[indexPath.row]
        cell.newsItem = post
        
        cell.imageBox.isHidden = (post.mediaType != .image)
        cell.videoView.isHidden = (post.mediaType != .video)
        cell.audioView.isHidden = (post.mediaType != .audio)
        
        if post.body?.isEmpty ?? true {
            cell.textBox.text = ""
            cell.textBox.isHidden = true
        } else {
                        
            let attributedString = NSMutableAttributedString(string: post.body!)
            // Detect all url's in post body
            let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
            let matches = detector.matches(in: attributedString.string, options: [], range: NSRange(location: 0, length: attributedString.string.count))
            for match in matches {
                guard let checkurl = match.url?.absoluteString else { continue }
                // check range again, because length of attributedString changed after first url replaced.
                let checkTheRange = attributedString.mutableString.range(of: checkurl)
                guard let range = Range(checkTheRange, in: attributedString.string) else { continue }
                let url = attributedString.string[range]
                // create link for url
                let attributedLink = NSMutableAttributedString(string: "Haz clic aquí")
                attributedLink.addAttribute(.link, value: url, range: NSRange(location: 0, length: 13))
                // Get range of text to replace
                guard let range2 = attributedString.string.range(of: url) else { exit(0) }
                let nsRange = NSRange(range2, in: attributedString.string)
                // Replace url with attributed link
                attributedString.replaceCharacters(in: nsRange, with: attributedLink)
            }
            // save font and color
            let font = cell.textBox.font
            let color = cell.textBox.textColor

             // Set attributed string to textView
            cell.textBox.attributedText = attributedString
            // restore font and color
            cell.textBox.font = font
            cell.textBox.textColor = color
            
            cell.textBox.isHidden = false
        }
        
        switch post.mediaType {
        case .image:
            
            if let imageURL = URL(string: post.mediaLink ?? ""){
                cell.imageBox.loadImage(at: imageURL)
                Utils.setViewShape(view: cell.imageBox, viewCornerRadius: 18, maskedCorners: [.layerMinXMinYCorner, .layerMaxXMinYCorner])
            } else {
                cell.imageBox.isHidden = true
            }
            break
            
        case .video:
            let mediaActivity = Utils.showActivityView(inView: cell.videoView, withFrame: cell.videoView.frame, text: nil)
            if let videoURL = URL(string:post.mediaLink!){

                cell.videoPlayer = AVPlayer(url: videoURL)
                cell.playerController = AVPlayerViewController()
                cell.playerController?.player = cell.videoPlayer
                cell.playerController?.showsPlaybackControls = true
                cell.playerController?.view.frame = cell.videoView.bounds
                cell.videoView.addSubview(cell.playerController!.view)
                
                Utils.setViewShape(view: cell.videoView, viewCornerRadius: 18, maskedCorners: [.layerMinXMinYCorner, .layerMaxXMinYCorner])
            } else {
                cell.videoView.isHidden = true
            }
            Utils.removeActivityView(mediaActivity)
            break
            
        case .audio:
                Utils.setViewShape(view: cell.audioView, viewCornerRadius: 18, maskedCorners: [.layerMinXMinYCorner, .layerMaxXMinYCorner])
        case .noMedia:
            break
        }
        
        // set publish date
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "es_ES")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if let pubDate = dateFormatter.date(from: post.publishDate!){
            dateFormatter.dateStyle = .long
            cell.publishDateLabel.text = dateFormatter.string(from: pubDate)
            
        }
        
        // round cell view and shadows
        Utils.setViewShape(view: cell.newsItemView, viewCornerRadius: 18)
        let shadowOffset = CGSize(width: 0.0, height: 5)
        Utils.dropViewShadow(view: cell.newsItemView, shadowColor: Colors.shadowColor, shadowRadius: 15 , shadowOffset: shadowOffset)
        cell.newsItemView.layoutIfNeeded()
                

        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 500
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastElement = self.newsItemsList.count - 1
        if !loadingData && indexPath.row == lastElement && self.newsItemsList.count < NewsFeedRepository.shared.totalPostsInDataBase{
//            indicator.startAnimating()
            print("**** loading more data ***")
            self.loadingData = true
            self.loadMoreData()
        }
    }
    
    func loadMoreData() {
        NewsFeedRepository.shared.getAllNewsItems(offSet: String(self.newsItemsList.count)) { newsItemsResponse in
            self.newsItemsList.append(contentsOf: newsItemsResponse)
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.loadingData = false
                print("**** finished loading more data ***")

            }
        }
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
 
    //============================================================
    // MARK: - Clean up time ;-)
    //============================================================
    
    func removeSavedImagesFromLoader(){
        for post in self.newsItemsList {
            if post.mediaType == .image , let url = URL(string: post.mediaLink ?? ""){
                UIImageLoader.loader.removeSavedImage(url: url)
            }
        }
    }

}
