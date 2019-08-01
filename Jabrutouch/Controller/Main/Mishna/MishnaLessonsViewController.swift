//בס״ד
//  MishnaLessonsViewController.swift
//  Jabrutouch
//
//  Created by Aaron Tuil on 01/08/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import UIKit

class MishnaLessonsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //========================================
    // MARK: - @IBOutlets and Fields
    //========================================
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var masechetLabel: UILabel!
    @IBOutlet weak var chapterLabel: UILabel!
    
    var lessons: [JTLessonDownload] = []
    var masechet: String?
    var chapter: String?
    
    //========================================
    // MARK: - LifeCycle
    //========================================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        masechetLabel.text = masechet
    }
    
    //========================================
    // MARK: - Setup
    //========================================
    
    //=====================================================
    // MARK: - UITableView Data Source and Delegate section
    //=====================================================
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lessons.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 89
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mishnaLessonCell", for: indexPath) as! MishnaLessonCellController
        cell.lessonNumber.text = lessons[indexPath.row].number
        cell.lessonLength.text = lessons[indexPath.row].length
        if lessons[indexPath.row].isAudioDownloaded {
            cell.audioImage?.image = UIImage(named: "RedAudioV")
        } else {
            cell.audioImage?.image = UIImage(named: "Audio")
        }
        if lessons[indexPath.row].isVideoDownloaded {
            cell.videoImage?.image = UIImage(named: "RedVideoV")
        } else {
            cell.videoImage?.image = UIImage(named: "Video")
        }
        cell.indexPath = indexPath
        Utils.setViewShape(view: cell.cellView, viewCornerRadius: 18)
        let shadowOffset = CGSize(width: 0.0, height: 12)
        Utils.dropViewShadow(view: cell.cellView, shadowColor: Colors.shadowColor, shadowRadius: 36, shadowOffset: shadowOffset)
        
        cell.cellView.layoutIfNeeded()
        
        return cell
    }
    
    //========================================
    // MARK: - @IBActions
    //========================================
    
    @IBAction func backPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    //====================================================
    // MARK: - Implemented Protocols functions and helpers
    //====================================================
    
    
    
}
