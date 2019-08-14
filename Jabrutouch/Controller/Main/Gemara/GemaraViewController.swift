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
    
    fileprivate var sedarim: [JTGemaraSeder] = []
    fileprivate var indexPathSelected: IndexPath = []
    
    //========================================
    // MARK: - LifeCycle
    //========================================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fillTableForDev()
        tableView.register(UINib(nibName: "DownloadsHeaderCell", bundle: nil), forHeaderFooterViewReuseIdentifier: "headerCell")
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showGemaraLessons" {
            let vc = segue.destination as? GemaraLessonsViewController
            vc?.lessons = sedarim[indexPathSelected.section].masechtot[indexPathSelected.row].lessons
            vc?.masechet = sedarim[indexPathSelected.section].masechtot[indexPathSelected.row].name
        }
    }
    
    //========================================
    // MARK: - Setup
    //========================================
    
    // Only for Dev function
    fileprivate func fillTableForDev() {
        var downloads1 = [JTLessonDownload]()
        let download1_1 = JTLessonDownload(number: "1", length: "56 min", isAudioDownloaded: false, isVideoDownloaded: false)
        let download1_2 = JTLessonDownload(number: "2", length: "67 min", isAudioDownloaded: false, isVideoDownloaded: true)
        let download1_3 = JTLessonDownload(number: "3", length: "52 min", isAudioDownloaded: true, isVideoDownloaded: true)
        downloads1.append(download1_1)
        downloads1.append(download1_2)
        downloads1.append(download1_3)
        
        var downloads2 = [JTLessonDownload]()
        let download2_1 = JTLessonDownload(number: "1", length: "43 min", isAudioDownloaded: false, isVideoDownloaded: false)
        let download2_2 = JTLessonDownload(number: "2", length: "52 min", isAudioDownloaded: true, isVideoDownloaded: true)
        downloads2.append(download2_1)
        downloads2.append(download2_2)
        
        var downloads3 = [JTLessonDownload]()
        let download3_1 = JTLessonDownload(number: "1", length: "23 min", isAudioDownloaded: false, isVideoDownloaded: false)
        let download3_2 = JTLessonDownload(number: "2", length: "34 min", isAudioDownloaded: false, isVideoDownloaded: true)
        let download3_3 = JTLessonDownload(number: "3", length: "50 min", isAudioDownloaded: true, isVideoDownloaded: true)
        downloads3.append(download3_1)
        downloads3.append(download3_2)
        downloads3.append(download3_3)
        
        var downloads4 = [JTLessonDownload]()
        let download4_1 = JTLessonDownload(number: "1", length: "16 min", isAudioDownloaded: false, isVideoDownloaded: false)
        let download4_2 = JTLessonDownload(number: "2", length: "37 min", isAudioDownloaded: true, isVideoDownloaded: true)
        downloads4.append(download4_1)
        downloads4.append(download4_2)
        
        let mishnaMasechet1 = JTGemaraMasechet(name: "Shabbat", lessons: downloads1)
        let mishnaMasechet2 = JTGemaraMasechet(name: "Iruvin", lessons: downloads2)
        let mishnaMasechet3 = JTGemaraMasechet(name: "Pesachim", lessons: downloads3)
        
        let mishnaSeder1 = JTGemaraSeder(sederName: "Moed", masechtot: [mishnaMasechet1, mishnaMasechet2, mishnaMasechet3])
        
        let mishnaMasechet4 = JTGemaraMasechet(name: "Brachot", lessons: downloads4)
        let mishnaMasechet5 = JTGemaraMasechet(name: "Peah", lessons: downloads1)
        let mishnaMasechet6 = JTGemaraMasechet(name: "Dmai", lessons: downloads2)
        
        let mishnaSeder2 = JTGemaraSeder(sederName: "Zraim", masechtot: [mishnaMasechet4, mishnaMasechet5, mishnaMasechet6])
        
        let mishnaMasechet7 = JTGemaraMasechet(name: "Yevamot", lessons: downloads3)
        let mishnaMasechet8 = JTGemaraMasechet(name: "Ketubot", lessons: downloads4)
        let mishnaMasechet9 = JTGemaraMasechet(name: "Nedarim", lessons: downloads1)
        
        let mishnaSeder3 = JTGemaraSeder(sederName: "Nashim", masechtot: [mishnaMasechet7, mishnaMasechet8, mishnaMasechet9])
        
        let mishnaMasechet10 = JTGemaraMasechet(name: "Baba Kama", lessons: downloads2)
        let mishnaMasechet11 = JTGemaraMasechet(name: "Baba Metsia", lessons: downloads3)
        let mishnaMasechet12 = JTGemaraMasechet(name: "Baba Batra", lessons: downloads4)
        
        let mishnaSeder4 = JTGemaraSeder(sederName: "Nezikim", masechtot: [mishnaMasechet10, mishnaMasechet11, mishnaMasechet12])
        
        let mishnaMasechet13 = JTGemaraMasechet(name: "Zvachim", lessons: downloads1)
        let mishnaMasechet14 = JTGemaraMasechet(name: "Menachot", lessons: downloads2)
        let mishnaMasechet15 = JTGemaraMasechet(name: "Chulin", lessons: downloads3)
        
        let mishnaSeder5 = JTGemaraSeder(sederName: "Kodshim", masechtot: [mishnaMasechet13, mishnaMasechet14, mishnaMasechet15])
        
        let mishnaMasechet16 = JTGemaraMasechet(name: "Kelim", lessons: downloads4)
        let mishnaMasechet17 = JTGemaraMasechet(name: "Ohalot", lessons: downloads1)
        let mishnaMasechet18 = JTGemaraMasechet(name: "Negaim", lessons: downloads2)
        
        let mishnaSeder6 = JTGemaraSeder(sederName: "Taharot", masechtot: [mishnaMasechet16, mishnaMasechet17, mishnaMasechet18])
        
        sedarim.append(mishnaSeder1)
        sedarim.append(mishnaSeder2)
        sedarim.append(mishnaSeder3)
        sedarim.append(mishnaSeder4)
        sedarim.append(mishnaSeder5)
        sedarim.append(mishnaSeder6)
    }
    
    //=====================================================
    // MARK: - UITableView Data Source and Delegate section
    //=====================================================
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sedarim.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if sedarim[section].isExpanded {
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
        
        if sedarim[section].isExpanded {
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
        let lessonsCount = sedarim[indexPath.section].masechtot[indexPath.row].lessons.count
        cell.lessonsCount.text = String(lessonsCount)
        cell.lessonText.text = lessonsCount > 1 ? "Lessons" : "Lesson"
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
        sedarim[section].isExpanded = !sedarim[section].isExpanded
        tableView.reloadSections([section], with: .automatic)
    }
    
    func showMasechetLessons(indexPath: IndexPath) {
        indexPathSelected = indexPath
        performSegue(withIdentifier: "showGemaraLessons", sender: self)
    }
    
    //========================================
    // MARK: - @IBActions
    //========================================
    
    @IBAction func backPressed(_ sender: Any) {
        self.delegate?.dismissMainModal()
    }
}
