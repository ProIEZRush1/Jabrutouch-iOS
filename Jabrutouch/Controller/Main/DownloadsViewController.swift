//בעזרת ה׳ החונן לאדם דעת
//  DownloadsViewController.swift
//  Jabrutouch
//
//  Created by Yoni Reiss on 18/07/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import UIKit

class DownloadsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, HeaderViewDelegate {

    @IBOutlet weak var headerShadowBasis: UIView!
    @IBOutlet weak var gemaraButton: UIButton!
    @IBOutlet weak var mishnaButton: UIButton!
    @IBOutlet weak var viewAllLessonsButton: UIButton!
    @IBOutlet weak var grayUpArrow: UIImageView!
    @IBOutlet weak var initialGrayUpArrowXCentererdToGemara: NSLayoutConstraint!
    @IBOutlet weak var booksImage: UIImageView!
    @IBOutlet weak var noDownloadedFilesMessage: UILabel!
    @IBOutlet weak var gemaraTableView: UITableView!
    @IBOutlet weak var deleteButton: UIButton!
    
    fileprivate var grayUpArrowXCentererdToGemara: NSLayoutConstraint?
    fileprivate var grayUpArrowXCentererdToMishna: NSLayoutConstraint?
    fileprivate var gemaraDownloads: [JTDownloadGroup] = []
    fileprivate var mishnaDownloads: [JTDownloadGroup] = []
    fileprivate var isGemaraSelected = true
    fileprivate var isDeleting = false
    
    @IBAction func gemaraPressed(_ sender: Any) {
        if !isGemaraSelected {
            switchViews()
        }
    }
    
    fileprivate func switchViews() {
        isGemaraSelected = !isGemaraSelected
        setSelectedPage()
    }
    
    @IBAction func mishnaPressed(_ sender: Any) {
        if isGemaraSelected {
            switchViews()
        }
    }
    
    override func viewDidLoad() {
        initialGrayUpArrowXCentererdToGemara.isActive = false
        grayUpArrowXCentererdToGemara = grayUpArrow.centerXAnchor.constraint(equalTo: gemaraButton.centerXAnchor)
        grayUpArrowXCentererdToMishna = grayUpArrow.centerXAnchor.constraint(equalTo: mishnaButton.centerXAnchor)
        fillTableForDev()
        gemaraTableView.register(UINib(nibName: "DownloadsHeaderCell", bundle: nil), forHeaderFooterViewReuseIdentifier: "downloadsHeaderCell")
        gemaraTableView.delegate = self
        gemaraTableView.dataSource = self
        setViews()
    }
    
    fileprivate func fillTableForDev() {
        var downloads1 = [JTDownload]()
        let download1_1 = JTDownload(book: "Shabbat", chapter: "A", number: "1", hasAudio: true, hasVideo: true)
        let download1_2 = JTDownload(book: "Shabbat", chapter: "A", number: "2", hasAudio: true, hasVideo: true)
        let download1_3 = JTDownload(book: "Shabbat", chapter: "B", number: "12", hasAudio: false, hasVideo: true)
        let download1_4 = JTDownload(book: "Shabbat", chapter: "B", number: "13", hasAudio: false, hasVideo: true)
        let download1_5 = JTDownload(book: "Shabbat", chapter: "B", number: "14", hasAudio: true, hasVideo: false)
        downloads1.append(download1_1)
        downloads1.append(download1_2)
        downloads1.append(download1_3)
        downloads1.append(download1_4)
        downloads1.append(download1_5)
        let downloadGroup1 = JTDownloadGroup(group: "Shabbat", downloads: downloads1)
        
        var downloads2 = [JTDownload]()
        let download2_1 = JTDownload(book: "Iruvim", chapter: "A", number: "2", hasAudio: true, hasVideo: true)
        let download2_2 = JTDownload(book: "Iruvim", chapter: "A", number: "5", hasAudio: true, hasVideo: false)
        let download2_3 = JTDownload(book: "Iruvim", chapter: "C", number: "1", hasAudio: true, hasVideo: true)
        let download2_4 = JTDownload(book: "Iruvim", chapter: "C", number: "3", hasAudio: false, hasVideo: true)
        downloads2.append(download2_1)
        downloads2.append(download2_2)
        downloads2.append(download2_3)
        downloads2.append(download2_4)
        let downloadGroup2 = JTDownloadGroup(group: "Iruvim", downloads: downloads2)
        
        var downloads3 = [JTDownload]()
        let download3_1 = JTDownload(book: "Pesachim", chapter: "B", number: "3", hasAudio: true, hasVideo: false)
        let download3_2 = JTDownload(book: "Pesachim", chapter: "B", number: "4", hasAudio: true, hasVideo: true)
        let download3_3 = JTDownload(book: "Pesachim", chapter: "D", number: "1", hasAudio: true, hasVideo: false)
        let download3_4 = JTDownload(book: "Pesachim", chapter: "E", number: "4", hasAudio: false, hasVideo: true)
        let download3_5 = JTDownload(book: "Pesachim", chapter: "G", number: "2", hasAudio: true, hasVideo: false)
        let download3_6 = JTDownload(book: "Pesachim", chapter: "G", number: "3", hasAudio: true, hasVideo: false)
        downloads3.append(download3_1)
        downloads3.append(download3_2)
        downloads3.append(download3_3)
        downloads3.append(download3_4)
        downloads3.append(download3_5)
        downloads3.append(download3_6)
        let downloadGroup3 = JTDownloadGroup(group: "Pesachim", downloads: downloads3)
        
        gemaraDownloads.append(downloadGroup1)
        gemaraDownloads.append(downloadGroup2)
        gemaraDownloads.append(downloadGroup3)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setSelectedPage()
    }
    
    fileprivate func setSelectedPage() {
        setButtonsColorAndFont()
        setGrayUpArrowPosition()
        showNoDownloadMessageIfNeeded()
    }
    
    fileprivate func showNoDownloadMessageIfNeeded() {
        if isGemaraSelected {
            if gemaraDownloads.count == 0 {
                setNoDownloadMessage(isHidden: false, table: gemaraTableView)
            } else {
                setNoDownloadMessage(isHidden: true, table: gemaraTableView)
            }
        } else {
            if mishnaDownloads.count == 0 {
                setNoDownloadMessage(isHidden: false, table: gemaraTableView) //TODO change gemaraTableView to mishnaTableView when created
            } else {
                setNoDownloadMessage(isHidden: true, table: gemaraTableView) //TODO change gemaraTableView to mishnaTableView when created
            }
        }
    }
    
    fileprivate func setNoDownloadMessage(isHidden: Bool, table: UITableView) {
        table.isHidden = !isHidden
        deleteButton.isHidden = !isHidden
        booksImage.isHidden = isHidden
        noDownloadedFilesMessage.isHidden = isHidden
        viewAllLessonsButton.isHidden = isHidden
    }
    
    fileprivate func setButtonsColorAndFont() {
        gemaraButton.backgroundColor = isGemaraSelected ? .white : UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1)
        mishnaButton.backgroundColor = !isGemaraSelected ? .white : UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1)
        gemaraButton.titleLabel?.font = isGemaraSelected ? UIFont(name: "SFProDisplay-Heavy", size: 18) : UIFont(name: "SFProDisplay-Medium", size: 18)
        mishnaButton.titleLabel?.font = !isGemaraSelected ? UIFont(name: "SFProDisplay-Heavy", size: 18) : UIFont(name: "SFProDisplay-Medium", size: 18)
        gemaraButton.setTitleColor(isGemaraSelected ? UIColor(red: 0.29, green: 0.27, blue: 0.57, alpha: 1) : UIColor(red: 0.29, green: 0.27, blue: 0.57, alpha: 0.55), for: .normal)
        mishnaButton.setTitleColor(!isGemaraSelected ? UIColor(red: 0.29, green: 0.27, blue: 0.57, alpha: 1) : UIColor(red: 0.29, green: 0.27, blue: 0.57, alpha: 0.55), for: .normal)
    }
    
    fileprivate func setGrayUpArrowPosition() {
        if isGemaraSelected {
            grayUpArrowXCentererdToMishna?.isActive = false
            grayUpArrowXCentererdToGemara?.isActive = true
        } else {
            grayUpArrowXCentererdToGemara?.isActive = false
            grayUpArrowXCentererdToMishna?.isActive = true
        }
        
        grayUpArrow.layoutIfNeeded()
    }
    
    fileprivate func setViews() {
        setViewsShadow()
        setViewAllButtonShape()
    }
    
    fileprivate func setViewAllButtonShape() {
        viewAllLessonsButton.layer.cornerRadius = 10.32
        viewAllLessonsButton.layer.borderWidth = 0.57
        viewAllLessonsButton.layer.borderColor = UIColor(red: 0.18, green: 0.17, blue: 0.66, alpha: 1).cgColor
        viewAllLessonsButton.translatesAutoresizingMaskIntoConstraints = false
    }
    
    fileprivate func setViewsShadow() {
        let borderColor = UIColor(red: 0.93, green: 0.94, blue: 0.96, alpha: 1)
        let shadowColor = UIColor(red: 0.1, green: 0.12, blue: 0.57, alpha: 0.1)
        let headerShadowColor = UIColor(red: 0.1, green: 0.12, blue: 0.57, alpha: 0.07)
        let shadowOffset = CGSize(width: 0.0, height: 10)
        let headerShadowOffset = CGSize(width: 0, height: 4)
        let cornerRadius = gemaraButton.layer.frame.height / 2
        dropViewShadow(view: gemaraButton, borderWidht: 1, borderColor: borderColor, cornerRadius: cornerRadius, shadowColor: shadowColor, shadowRadius: 20, shadowOffset: shadowOffset)
        dropViewShadow(view: mishnaButton, borderWidht: 1, borderColor: borderColor, cornerRadius: cornerRadius, shadowColor: shadowColor, shadowRadius: 20, shadowOffset: shadowOffset)
        dropViewShadow(view: headerShadowBasis, shadowColor: headerShadowColor, shadowRadius: 22, shadowOffset: headerShadowOffset)
    }
    
    fileprivate func dropViewShadow(view: UIView, borderWidht: CGFloat = 0, borderColor: UIColor = .white, cornerRadius: CGFloat = 0, shadowColor: UIColor, shadowRadius: CGFloat, shadowOffset: CGSize) {
        view.layer.cornerRadius = cornerRadius
        view.layer.borderWidth = borderWidht
        view.layer.borderColor = borderColor.cgColor
        view.layer.shadowColor = shadowColor.cgColor
        view.layer.shadowOffset = shadowOffset
        view.layer.shadowOpacity = 1.0
        view.layer.shadowRadius = shadowRadius
        view.layer.masksToBounds = false
        view.translatesAutoresizingMaskIntoConstraints = false
    }
    
    //----------------------------------------------------------------
    // MARK: - UITableView Data Source and Delegate section
    //----------------------------------------------------------------
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return gemaraDownloads.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if gemaraDownloads[section].isExpanded {
            return gemaraDownloads[section].downloads.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 200
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCell = tableView.dequeueReusableHeaderFooterView(withIdentifier: "downloadsHeaderCell") as! DownloadsHeaderCellController
        headerCell.titleLabel?.text = self.gemaraDownloads[section].name
        headerCell.section = section
        headerCell.delegate = self
        
        return headerCell
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "downloadsCell", for: indexPath) as! DownloadsCellController
        let download = self.gemaraDownloads[indexPath.section].downloads[indexPath.row]

        cell.book.text = download.book
        cell.chapter.text = download.chapter
        cell.number.text = download.number
        cell.audioButton.isHidden = !(download.hasAudio ?? false)
        cell.videoButton.isHidden = !(download.hasVideo ?? false)
        
        if isDeleting {
            cell.deleteButton.isHidden = false
            cell.cellTrailingConstraint.constant = 45
        } else {
            cell.deleteButton.isHidden = true
            cell.cellTrailingConstraint.constant = 21
        }
        
        cell.cellView.layoutIfNeeded()
        
        return cell
    }
    
    func toggleSection(header: DownloadsHeaderCellController, section: Int) {
        gemaraDownloads[section].isExpanded = !gemaraDownloads[section].isExpanded
        gemaraTableView.reloadSections([section], with: .automatic)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
