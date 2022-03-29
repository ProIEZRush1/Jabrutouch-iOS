//בעזרת ה׳ החונן לאדם דעת
//  MishnaViewController.swift
//  Jabrutouch
//
//  Created by Yoni Reiss on 18/07/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import UIKit

class MishnaViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, HeaderViewDelegate, MishnaMasechetCellDelegate {
    
    //========================================
    // MARK: - @IBOutlets and Fields
    //========================================
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var openSections: Set<Int> = []
    var delegate: MainModalDelegate?
    var masechet: JTMishnaMasechet?
    
    fileprivate var sedarim: [JTMishnaSeder] = ContentRepository.shared.getMishnaSeders()
    fileprivate var selectedIndexPath: IndexPath = []
    
    //========================================
    // MARK: - LifeCycle
    //========================================
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return [.portrait, .landscapeLeft, .landscapeRight]
        } else {
            return [.portrait]
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "DownloadsHeaderCell", bundle: nil), forHeaderFooterViewReuseIdentifier: "headerCell")
        tableView.delegate = self
        tableView.dataSource = self
        self.titleLabel.text = Strings.mishna
        self.setInitialOpenSections()
    }
    
    //========================================
    // MARK: - Setup
    //========================================
    
    private func setInitialOpenSections() {
        for i in 0..<self.sedarim.count {
            self.openSections.insert(i)
        }
    }
    
    //=====================================================
    // MARK: - UITableView Data Source and Delegate section
    //=====================================================

    func numberOfSections(in tableView: UITableView) -> Int {
        return sedarim.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.openSections.contains(section) {
            return sedarim[section].masechtot.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.00001 // Returning 0 does not reduce the footer height!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if sedarim[indexPath.section].masechtot.count - 1 == indexPath.row {
            return 80
        }
        return 67
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCell = tableView.dequeueReusableHeaderFooterView(withIdentifier: "headerCell") as! HeaderCellController
        
        if self.openSections.contains(section) {
            headerCell.arrowImage?.image = UIImage(named: "blue_up_arrow")
        } else {
            headerCell.arrowImage?.image = UIImage(named: "blue_down_arrow")
        }
        
        headerCell.titleLabel?.text = "Seder " + sedarim[section].name
        headerCell.section = section
        headerCell.delegate = self
        let background = UIView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: headerCell.bounds.size))
        background.backgroundColor = .clear
        headerCell.backgroundView = background
        
        return headerCell
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mishnaMasechetCell", for: indexPath) as! MishnaMasechetCellController
        self.getMasectChapterContent(indexPath: indexPath, isFirst: true)
        if self.masechet?.chapters.isEmpty ?? true {
            
            cell.masechetName.textColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
            cell.chaptersCount.textColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
            cell.chapterText.textColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
            cell.arrowImageView.isHidden = true
            
            Utils.setViewShape(view: cell.cellView, viewCornerRadius: 18)
            let shadowOffset = CGSize(width: 0.0, height: 0)
            Utils.dropViewShadow(view: cell.cellView, shadowColor: Colors.shadowColor, shadowRadius: 0, shadowOffset: shadowOffset)
            
        } else {
            cell.masechetName.textColor = #colorLiteral(red: 0.2340182662, green: 0.259791255, blue: 0.7208750248, alpha: 1)
            cell.chaptersCount.textColor = #colorLiteral(red: 0.176, green: 0.169, blue: 0.663, alpha: 1)
            cell.chapterText.textColor = #colorLiteral(red: 0.176, green: 0.169, blue: 0.663, alpha: 1)
            cell.arrowImageView.isHidden = false
            Utils.setViewShape(view: cell.cellView, viewCornerRadius: 18)
            let shadowOffset = CGSize(width: 0.0, height: 5)
            Utils.dropViewShadow(view: cell.cellView, shadowColor: Colors.shadowColor, shadowRadius: 15, shadowOffset: shadowOffset)
        }
        
        cell.masechetName.text = sedarim[indexPath.section].masechtot[indexPath.row].name
        let chaptersCount = sedarim[indexPath.section].masechtot[indexPath.row].chaptersCount
        cell.chaptersCount.text = String(chaptersCount)
        cell.chapterText.text = chaptersCount > 1 ? Strings.chapters : Strings.chapter
        cell.indexPath = indexPath
        cell.delegate = self
//        Utils.setViewShape(view: cell.cellView, viewCornerRadius: 18)
//        let shadowOffset = CGSize(width: 0.0, height: 5)
//        Utils.dropViewShadow(view: cell.cellView, shadowColor: Colors.shadowColor, shadowRadius: 15, shadowOffset: shadowOffset)
        cell.cellView.layoutIfNeeded()
        
        return cell
    }
    
    //====================================================
    // MARK: - Implemented Protocols functions and helpers
    //====================================================
    
    func toggleSection(header: HeaderCellController, section: Int) {
        if self.openSections.contains(section) {
            self.openSections.remove(section)
        } else {
            self.openSections.insert(section)
        }
        tableView.reloadSections([section], with: .automatic)
    }

    func showMasechetChapters(indexPath: IndexPath) {
        if self.masechet?.chapters.isEmpty ?? true {
            
            Utils.showAlertMessage(Strings.noLessons, title: nil, viewControler: self)
        } else {
            selectedIndexPath = indexPath
            performSegue(withIdentifier: "showMishnaChapters", sender: self)
        }
    }
    
    func getMasectChapterContent(indexPath: IndexPath, isFirst: Bool) {
        selectedIndexPath = indexPath
        let id = self.sedarim[selectedIndexPath.section].masechtot[selectedIndexPath.row].masechetId
        self.masechet = ContentRepository.shared.getMishanMasechet(masechetId: id)
        if !isFirst{
            self.showMasechetChapters(indexPath: indexPath)
        }
    }
    
    //========================================
    // MARK: - @IBActions
    //========================================
    
    @IBAction func backPressed(_ sender: Any) {
        self.delegate?.dismissMainModal()
    }
    
    //========================================
    // MARK: - Navigation
    //========================================
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMishnaChapters" {
            let vc = segue.destination as? MishnaChapterViewController
            vc?.masechetId = self.sedarim[selectedIndexPath.section].masechtot[selectedIndexPath.row].masechetId
            vc?.sederId = "\(self.sedarim[selectedIndexPath.section].sederId)"
        }
    }
}
