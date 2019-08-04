//בס״ד
//  MishnaChapterViewController.swift
//  Jabrutouch
//
//  Created by Aaron Tuil on 31/07/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import UIKit

class MishnaChapterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MishnaChapterCellDelegate {
    
    //========================================
    // MARK: - @IBOutlets and Fields
    //========================================
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var masechetName: UILabel!
    
    var chapters: [JTMishnaChapter] = []
    var masechetString: String?
    fileprivate var selectedRow: Int = 0

    //========================================
    // MARK: - LifeCycle
    //========================================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        masechetName.text = masechetString
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMishnaLessons" {
            let vc = segue.destination as? MishnaLessonsViewController
            vc?.lessons = chapters[selectedRow].lessonsDownloaded
            vc?.masechet = masechetString
            vc?.chapter = chapters[selectedRow].name
        }
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
        return chapters.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 86
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mishnaChapterCell", for: indexPath) as! MishnaChapterCellController
        cell.chapterName.text = chapters[indexPath.row].name
        let mishnaiotCount = chapters[indexPath.row].lessonsDownloaded.count
        cell.mishnaiotCount.text = String(mishnaiotCount)
        cell.mishnaiotText.text = mishnaiotCount > 1 ? "Mishnaiot" : "Mishna"
        cell.delegate = self
        cell.selectedRow = indexPath.row
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
    
    func showMasechetLessons(selectedRow: Int) {
        self.selectedRow = selectedRow
        performSegue(withIdentifier: "showMishnaLessons", sender: self)
    }
    
    
}
