//בעזרת ה׳ החונן לאדם דעת
//  MishnaViewController.swift
//  Jabrutouch
//
//  Created by Yoni Reiss on 18/07/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import UIKit

class MishnaViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, HeaderViewDelegate {
    
    //========================================
    // MARK: - @IBOutlets and Fields
    //========================================
    
    @IBOutlet weak var tableView: UITableView!
    
    fileprivate var sedarim: [JTMishnaSeder] = []
    
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
    
    //========================================
    // MARK: - Setup
    //========================================
    
    // Only for Dev function
    fileprivate func fillTableForDev() {
        var downloads1 = [JTLessonDownload]()
        let download1_1 = JTLessonDownload(lessonNumber: "1", isAudioDownloaded: false, isVideoDownloaded: false)
        let download1_2 = JTLessonDownload(lessonNumber: "2", isAudioDownloaded: false, isVideoDownloaded: true)
        let download1_3 = JTLessonDownload(lessonNumber: "3", isAudioDownloaded: true, isVideoDownloaded: true)
        downloads1.append(download1_1)
        downloads1.append(download1_2)
        downloads1.append(download1_3)
        let mishnaChapter1 = JTMishnaChapter(chapterName: "A", lessonsDownloaded: downloads1)
        
        var downloads2 = [JTLessonDownload]()
        let download2_1 = JTLessonDownload(lessonNumber: "1", isAudioDownloaded: false, isVideoDownloaded: false)
        let download2_2 = JTLessonDownload(lessonNumber: "2", isAudioDownloaded: true, isVideoDownloaded: true)
        downloads2.append(download2_1)
        downloads2.append(download2_2)
        let mishnaChapter2 = JTMishnaChapter(chapterName: "B", lessonsDownloaded: downloads2)
        
        var downloads3 = [JTLessonDownload]()
        let download3_1 = JTLessonDownload(lessonNumber: "1", isAudioDownloaded: false, isVideoDownloaded: false)
        let download3_2 = JTLessonDownload(lessonNumber: "2", isAudioDownloaded: false, isVideoDownloaded: true)
        let download3_3 = JTLessonDownload(lessonNumber: "3", isAudioDownloaded: true, isVideoDownloaded: true)
        downloads3.append(download3_1)
        downloads3.append(download3_2)
        downloads3.append(download3_3)
        let mishnaChapter3 = JTMishnaChapter(chapterName: "C", lessonsDownloaded: downloads3)
        
        var downloads4 = [JTLessonDownload]()
        let download4_1 = JTLessonDownload(lessonNumber: "1", isAudioDownloaded: false, isVideoDownloaded: false)
        let download4_2 = JTLessonDownload(lessonNumber: "2", isAudioDownloaded: true, isVideoDownloaded: true)
        downloads4.append(download4_1)
        downloads4.append(download4_2)
        let mishnaChapter4 = JTMishnaChapter(chapterName: "D", lessonsDownloaded: downloads4)
        
        let mishnaMasechet1 = JTMishnaMasechet(name: "Shabbat", chapters: [mishnaChapter1, mishnaChapter2, mishnaChapter3, mishnaChapter4])
        let mishnaMasechet2 = JTMishnaMasechet(name: "Iruvim", chapters: [mishnaChapter1, mishnaChapter2, mishnaChapter3, mishnaChapter4])
        let mishnaMasechet3 = JTMishnaMasechet(name: "Pesachim", chapters: [mishnaChapter1, mishnaChapter2, mishnaChapter3, mishnaChapter4])
        
        let mishnaSeder1 = JTMishnaSeder(sederName: "Moed", masechtot: [mishnaMasechet1, mishnaMasechet2, mishnaMasechet3])
        
        let mishnaMasechet4 = JTMishnaMasechet(name: "Brachot", chapters: [mishnaChapter1, mishnaChapter2, mishnaChapter3, mishnaChapter4])
        let mishnaMasechet5 = JTMishnaMasechet(name: "Peah", chapters: [mishnaChapter1, mishnaChapter2, mishnaChapter3, mishnaChapter4])
        let mishnaMasechet6 = JTMishnaMasechet(name: "Dmai", chapters: [mishnaChapter1, mishnaChapter2, mishnaChapter3, mishnaChapter4])
        
        let mishnaSeder2 = JTMishnaSeder(sederName: "Zraim", masechtot: [mishnaMasechet4, mishnaMasechet5, mishnaMasechet6])
        
        let mishnaMasechet7 = JTMishnaMasechet(name: "Yevamot", chapters: [mishnaChapter1, mishnaChapter2, mishnaChapter3, mishnaChapter4])
        let mishnaMasechet8 = JTMishnaMasechet(name: "Ketubot", chapters: [mishnaChapter1, mishnaChapter2, mishnaChapter3, mishnaChapter4])
        let mishnaMasechet9 = JTMishnaMasechet(name: "Nedarim", chapters: [mishnaChapter1, mishnaChapter2, mishnaChapter3, mishnaChapter4])
        
        let mishnaSeder3 = JTMishnaSeder(sederName: "Nashim", masechtot: [mishnaMasechet7, mishnaMasechet8, mishnaMasechet9])
        
        let mishnaMasechet10 = JTMishnaMasechet(name: "Baba Kama", chapters: [mishnaChapter1, mishnaChapter2, mishnaChapter3, mishnaChapter4])
        let mishnaMasechet11 = JTMishnaMasechet(name: "Baba Metsia", chapters: [mishnaChapter1, mishnaChapter2, mishnaChapter3, mishnaChapter4])
        let mishnaMasechet12 = JTMishnaMasechet(name: "Baba Batra", chapters: [mishnaChapter1, mishnaChapter2, mishnaChapter3, mishnaChapter4])
        
        let mishnaSeder4 = JTMishnaSeder(sederName: "Nezikim", masechtot: [mishnaMasechet10, mishnaMasechet11, mishnaMasechet12])
        
        let mishnaMasechet13 = JTMishnaMasechet(name: "Zvachim", chapters: [mishnaChapter1, mishnaChapter2, mishnaChapter3, mishnaChapter4])
        let mishnaMasechet14 = JTMishnaMasechet(name: "Menachot", chapters: [mishnaChapter1, mishnaChapter2, mishnaChapter3, mishnaChapter4])
        let mishnaMasechet15 = JTMishnaMasechet(name: "Chulin", chapters: [mishnaChapter1, mishnaChapter2, mishnaChapter3, mishnaChapter4])
        
        let mishnaSeder5 = JTMishnaSeder(sederName: "Kedoshim", masechtot: [mishnaMasechet13, mishnaMasechet14, mishnaMasechet15])
        
        let mishnaMasechet16 = JTMishnaMasechet(name: "Kelim", chapters: [mishnaChapter1, mishnaChapter2, mishnaChapter3, mishnaChapter4])
        let mishnaMasechet17 = JTMishnaMasechet(name: "Ohalot", chapters: [mishnaChapter1, mishnaChapter2, mishnaChapter3, mishnaChapter4])
        let mishnaMasechet18 = JTMishnaMasechet(name: "Negaim", chapters: [mishnaChapter1, mishnaChapter2, mishnaChapter3, mishnaChapter4])
        
        let mishnaSeder6 = JTMishnaSeder(sederName: "Taharot", masechtot: [mishnaMasechet16, mishnaMasechet17, mishnaMasechet18])
        
        sedarim.append(mishnaSeder1)
        sedarim.append(mishnaSeder2)
        sedarim.append(mishnaSeder3)
        sedarim.append(mishnaSeder4)
        sedarim.append(mishnaSeder5)
        sedarim.append(mishnaSeder6)
    }
    
    
    //----------------------------------------------------------------
    // MARK: - UITableView Data Source and Delegate section
    //----------------------------------------------------------------

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
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.00001 // Returning 0 does not reduce the footer height!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 67
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCell = tableView.dequeueReusableHeaderFooterView(withIdentifier: "headerCell") as! DownloadsHeaderCellController
        
        if sedarim[section].isExpanded {
            headerCell.arrowImage?.image = UIImage(named: "Black&BlueUpArrow")
        } else {
            headerCell.arrowImage?.image = UIImage(named: "Black&BlueDownArrow")
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
        cell.masechetName.text = sedarim[indexPath.section].masechtot[indexPath.row].name
        let chaptersCount = sedarim[indexPath.section].masechtot[indexPath.row].chapters.count
        cell.chaptersCount.text = String(chaptersCount)
        cell.chapterText.text = chaptersCount > 1 ? "Chapters" : "Chapter"
        Utils.setViewShape(view: cell.cellView, viewCornerRadius: 18)
        let shadowOffset = CGSize(width: 0.0, height: 12)
        Utils.dropViewShadow(view: cell.cellView, shadowColor: Colors.shadowColor, shadowRadius: 36, shadowOffset: shadowOffset)
        
        cell.cellView.layoutIfNeeded()
        
        return cell
    }
    
    //----------------------------------------------------------------
    // MARK: - Implemented Protocols functions and helpers
    //----------------------------------------------------------------
    
    func toggleSection(header: DownloadsHeaderCellController, section: Int) {
        sedarim[section].isExpanded = !sedarim[section].isExpanded
        tableView.reloadSections([section], with: .automatic)
    }
    
    //========================================
    // MARK: - @IBActions
    //========================================
}
