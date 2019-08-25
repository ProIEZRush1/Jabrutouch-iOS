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
    
    var masechetId: Int?
    var masechet: JTMishnaMasechet?
    var sederId: String?
    fileprivate var selectedRow: Int = 0

    //========================================
    // MARK: - LifeCycle
    //========================================
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.portrait]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setContent()
        self.setTableView()
        self.setStrings()
        
    }
    
    //========================================
    // MARK: - Setup
    //========================================
    
    private func setContent() {
        if let id = self.masechetId {
            self.masechet = ContentRepository.shared.getMishanMasechet(masechetId: id)
            self.tableView.reloadData()
        }
    }
    
    private func setTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    private func setStrings() {
        self.masechetName.text = self.masechet?.name
    }
    //=====================================================
    // MARK: - UITableView Data Source and Delegate section
    //=====================================================
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.masechet?.chapters.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 86
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mishnaChapterCell", for: indexPath) as! MishnaChapterCellController
        guard let chapter = self.masechet?.chapters[indexPath.row] else { return cell }
        cell.chapterName.text = chapter.chapter
        let mishnaiotCount = chapter.lessonsCount
        cell.mishnaiotCount.text = String(mishnaiotCount)
        cell.mishnaiotText.text = mishnaiotCount > 1 ? Strings.mishnayot : Strings.mishna
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
        self.navigationController?.popViewController(animated: true)
    }
    
    //====================================================
    // MARK: - Implemented Protocols functions and helpers
    //====================================================
    
    func showMasechetLessons(selectedRow: Int) {
        self.selectedRow = selectedRow
        performSegue(withIdentifier: "showMishnaLessons", sender: self)
    }
    
    //====================================================
    // MARK: - Navigation
    //====================================================
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMishnaLessons" {
            let vc = segue.destination as? MishnaLessonsViewController
            vc?.masechetId = self.masechetId
            vc?.masechetName = self.masechet?.name
            vc?.chapter = Int(self.masechet?.chapters[self.selectedRow].chapter ?? "")
            vc?.sederId = self.sederId
        }
    }
}
