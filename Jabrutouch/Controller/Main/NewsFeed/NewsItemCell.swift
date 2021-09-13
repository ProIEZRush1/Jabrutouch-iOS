//
//  NewsItemCell.swift
//  Jabrutouch
//
//  Created by Avraham Kirsch on 26/08/2021.
//  Copyright © 2021 Ravtech. All rights reserved.
//

import UIKit
import AVKit


class NewsItemCell: UITableViewCell {
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    var newsItem: JTNewsFeedItem?
    var mediaPlayer: AVPlayer?
    var playerController: AVPlayerViewController?
    
    @IBOutlet weak var newsItemView: UIView!
    @IBOutlet weak var mediaView: UIView!
    @IBOutlet weak var imageBox: UIImageView!
    @IBOutlet weak var textContainer: UIView!
    @IBOutlet weak var textBox: UITextView!
    @IBOutlet weak var publishDateLabel: UILabel!

    
    override func prepareForReuse() {
        //this way once user scrolls player will pause
        super.prepareForReuse()
        self.playerController?.player?.pause()
        self.mediaPlayer = nil
        self.playerController?.player = nil
        self.imageBox.image = nil
        self.imageBox.cancelImageLoad()

    }
}



