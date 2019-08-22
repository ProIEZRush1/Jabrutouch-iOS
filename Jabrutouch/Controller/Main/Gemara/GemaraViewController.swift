//בעזרת ה׳ החונן לאדם דעת
//  GemaraViewController.swift
//  Jabrutouch
//
//  Created by Yoni Reiss on 18/07/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import UIKit

class GemaraViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, HeaderViewDelegate, GemaraMasechetCellDelegate {
    
    //========================================
    // MARK: - @IBOutlets and Fields
    //========================================
    
    @IBOutlet weak var tableView: UITableView!
    
    var delegate: MainModalDelegate?
    var openSections: Set<Int> = []
    fileprivate var sedarim: [JTGemaraSeder] = ContentRepository.shared.getGemaraSeders()
    fileprivate var selectedIndexPath: IndexPath = []
    
    //========================================
    // MARK: - LifeCycle
    //========================================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setTableView()
        self.setInitialOpenSections()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showGemaraLessons" {
            let vc = segue.destination as? GemaraLessonsViewController
            let masechet = self.sedarim[self.selectedIndexPath.section].masechtot[self.selectedIndexPath.row]
            let sederId = "\(self.sedarim[self.selectedIndexPath.section].sederId)"
            vc?.masechetName = masechet.name
            vc?.masechetId = masechet.masechetId
            vc?.sederId = sederId
        }
    }
    
    //========================================
    // MARK: - Setup
    //========================================
    
    private func setTableView() {
        tableView.register(UINib(nibName: "DownloadsHeaderCell", bundle: nil), forHeaderFooterViewReuseIdentifier: "headerCell")
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func setInitialOpenSections() {
        for i in 0..<self.sedarim.count {
            self.openSections.insert(i)
        }
    }
    
    //=====================================================
    // MARK: - UITableView Data Source and Delegate section
    //=====================================================
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sedarim.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if openSections.contains(section) {
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
        return 67
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCell = tableView.dequeueReusableHeaderFooterView(withIdentifier: "headerCell") as! HeaderCellController
        
        if openSections.contains(section) {
            headerCell.arrowImage?.image = UIImage(named: "DarkGrayUpArrow")
        } else {
            headerCell.arrowImage?.image = UIImage(named: "DarkGrayDownArrow")
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "gemaraMasechetCell", for: indexPath) as! GemaraMasechetCellController
        cell.masechetName.text = sedarim[indexPath.section].masechtot[indexPath.row].name
        let pagesCount = sedarim[indexPath.section].masechtot[indexPath.row].pagesCount
        cell.pagesCountLabel.text = String(pagesCount)
        cell.pagesCountTextLabel.text = pagesCount > 1 ? Strings.pages : Strings.page
        cell.indexPath = indexPath
        cell.delegate = self
        Utils.setViewShape(view: cell.cellView, viewCornerRadius: 18)
        let shadowOffset = CGSize(width: 0.0, height: 12)
        Utils.dropViewShadow(view: cell.cellView, shadowColor: Colors.shadowColor, shadowRadius: 36, shadowOffset: shadowOffset)
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
    
    func showMasechetLessons(indexPath: IndexPath) {
        selectedIndexPath = indexPath
        performSegue(withIdentifier: "showGemaraLessons", sender: self)
    }
    
    //========================================
    // MARK: - @IBActions
    //========================================
    
    @IBAction func backPressed(_ sender: Any) {
        self.delegate?.dismissMainModal()
    }
}
