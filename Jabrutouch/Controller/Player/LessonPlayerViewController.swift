//בעזרת ה׳ החונן לאדם דעת
//  LessonPlayerViewController.swift
//  Jabrutouch
//
//  Created by Yoni Reiss on 22/08/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import UIKit
import WebKit

class LessonPlayerViewController: UIViewController {

    //====================================================
    // MARK: - @IBOutlets
    //====================================================
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var pdfWebView: WKWebView!
    
    //====================================================
    // MARK: - Properties
    //====================================================
    
    var pdfUrl: URL?
    var videoUrl: URL?
    var audioUrl: URL?
    var mediaType: JTLessonMediaType?
    
    //====================================================
    // MARK: - LifeCycle
    //====================================================
    
    init(pdfUrl: URL, videoUrl: URL?, audioUrl: URL?, mediaType: JTLessonMediaType) {
        super.init(nibName: "LessonPlayerViewController", bundle: Bundle.main)
        self.pdfUrl = pdfUrl
        self.videoUrl = videoUrl
        self.audioUrl = audioUrl
        self.mediaType = mediaType
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func loadView() {
        Bundle.main.loadNibNamed("LessonPlayerViewController", owner: self, options: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadPDF()
        
    }
    
    //====================================================
    // MARK: - Setup
    //====================================================
    
    private func loadPDF() {
        guard let url = self.pdfUrl else { return }
        self.pdfWebView.loadFileURL(url, allowingReadAccessTo: url)
    }
    
    //====================================================
    // MARK: - @IBActions
    //====================================================
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
