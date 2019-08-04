//בעזרת ה׳ החונן לאדם דעת
//  DownloadsViewController.swift
//  Jabrutouch
//
//  Created by Yoni Reiss on 18/07/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import UIKit

class DownloadsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, HeaderViewDelegate, DownloadsCellDelegate {
    
    @IBOutlet weak var headerShadowBasis: UIView!
    @IBOutlet weak var gemaraButton: UIButton!
    @IBOutlet weak var mishnaButton: UIButton!
    @IBOutlet weak var gemaraViewAllLessonsButton: UIButton!
    @IBOutlet weak var mishnaViewAllLessonsButton: UIButton!
    @IBOutlet weak var grayUpArrow: UIImageView!
    @IBOutlet weak var initialGrayUpArrowXCentererdToGemara: NSLayoutConstraint!
    @IBOutlet weak var gemaraBooksImage: UIImageView!
    @IBOutlet weak var mishnaBooksImage: UIImageView!
    @IBOutlet weak var gemaraNoDownloadedFilesMessage: UILabel!
    @IBOutlet weak var mishnaNoDownloadedFilesMessage: UILabel!
    @IBOutlet weak var gemaraTableView: UITableView!
    @IBOutlet weak var mishnaTableView: UITableView!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var gemaraLeadingConsraint: NSLayoutConstraint!
    
    fileprivate var grayUpArrowXCentererdToGemara: NSLayoutConstraint?
    fileprivate var grayUpArrowXCentererdToMishna: NSLayoutConstraint?
    fileprivate var gemaraDownloads: [JTDownloadGroup] = []
    fileprivate var mishnaDownloads: [JTDownloadGroup] = []
    fileprivate var isGemaraSelected = true
    fileprivate var isDeleting = false
    fileprivate var downloadsMap = [String: [JTDownloadGroup]]()
    fileprivate var tableViewsMap = [String: UITableView]()
    fileprivate let GEMARA = "Gemara"
    fileprivate let MISHNA = "Mishna"
    
    //----------------------------------------------------------------
    // MARK: - @IBActions and their helpers
    //----------------------------------------------------------------
    
    @IBAction func gemaraPressed(_ sender: Any) {
        if !isGemaraSelected {
            switchViews()
        }
    }
    
    fileprivate func switchViews() {
        isGemaraSelected = !isGemaraSelected
        setSelectedPage()
        UIView.animate(withDuration: 0.3) {
            if self.isGemaraSelected {
                self.gemaraLeadingConsraint.constant = 0
            } else {
                self.gemaraLeadingConsraint.constant = -self.view.frame.width
            }
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func mishnaPressed(_ sender: Any) {
        if isGemaraSelected {
            switchViews()
        }
    }
    
    
    @IBAction func deletePressed(_ sender: Any) {
        isDeleting = !isDeleting
        
        if isDeleting {
            deleteButton.setTitle("Done",for: .normal)
        } else {
            deleteButton.setTitle("Delete",for: .normal)
        }
        
        gemaraTableView.reloadData()
        mishnaTableView.reloadData()
    }
    
    //----------------------------------------------------------------
    // MARK: - Main functions
    //----------------------------------------------------------------
    
    override func viewDidLoad() {
        initialGrayUpArrowXCentererdToGemara.isActive = false
        grayUpArrowXCentererdToGemara = grayUpArrow.centerXAnchor.constraint(equalTo: gemaraButton.centerXAnchor)
        grayUpArrowXCentererdToMishna = grayUpArrow.centerXAnchor.constraint(equalTo: mishnaButton.centerXAnchor)
        fillTableForDev() // Only for Dev
        gemaraTableView.register(UINib(nibName: "DownloadsHeaderCell", bundle: nil), forHeaderFooterViewReuseIdentifier: "headerCell")
        mishnaTableView.register(UINib(nibName: "DownloadsHeaderCell", bundle: nil), forHeaderFooterViewReuseIdentifier: "headerCell")
        gemaraTableView.delegate = self
        gemaraTableView.dataSource = self
        mishnaTableView.delegate = self
        mishnaTableView.dataSource = self
        downloadsMap[GEMARA] = gemaraDownloads
        downloadsMap[MISHNA] = mishnaDownloads
        tableViewsMap[GEMARA] = gemaraTableView
        tableViewsMap[MISHNA] = mishnaTableView
        setViews()
    }
    
    // Only for Dev function
    fileprivate func fillTableForDev() {
        var downloads1 = [JTDownload]()
        var downloads4 = [JTDownload]()
        let download1_1 = JTDownload(book: "Shabbat", chapter: "A", number: "1", hasAudio: true, hasVideo: true)
        let download1_2 = JTDownload(book: "Shabbat", chapter: "A", number: "2", hasAudio: true, hasVideo: true)
        let download1_3 = JTDownload(book: "Shabbat", chapter: "B", number: "12", hasAudio: false, hasVideo: true)
        let download1_4 = JTDownload(book: "Shekalim", chapter: "B", number: "13", hasAudio: false, hasVideo: true)
        let download1_5 = JTDownload(book: "Shekalim", chapter: "B", number: "14", hasAudio: true, hasVideo: false)
        downloads1.append(download1_1)
        downloads1.append(download1_2)
        downloads1.append(download1_3)
        downloads4.append(download1_4)
        downloads4.append(download1_5)
        let downloadGroup1 = JTDownloadGroup(group: "Shabbat", downloads: downloads1)
        let downloadGroup4 = JTDownloadGroup(group: "Shekalim", downloads: downloads4)
        
        var downloads2 = [JTDownload]()
        var downloads5 = [JTDownload]()
        let download2_1 = JTDownload(book: "Iruvim", chapter: "A", number: "2", hasAudio: true, hasVideo: true)
        let download2_2 = JTDownload(book: "Iruvim", chapter: "A", number: "5", hasAudio: true, hasVideo: false)
        let download2_3 = JTDownload(book: "Yoma", chapter: "C", number: "1", hasAudio: true, hasVideo: true)
        let download2_4 = JTDownload(book: "Yoma", chapter: "C", number: "3", hasAudio: false, hasVideo: true)
        downloads2.append(download2_1)
        downloads2.append(download2_2)
        downloads5.append(download2_3)
        downloads5.append(download2_4)
        let downloadGroup2 = JTDownloadGroup(group: "Iruvim", downloads: downloads2)
        let downloadGroup5 = JTDownloadGroup(group: "Yoma", downloads: downloads5)
        
        var downloads3 = [JTDownload]()
        var downloads6 = [JTDownload]()
        let download3_1 = JTDownload(book: "Pesachim", chapter: "B", number: "3", hasAudio: true, hasVideo: false)
        let download3_2 = JTDownload(book: "Pesachim", chapter: "B", number: "4", hasAudio: true, hasVideo: true)
        let download3_3 = JTDownload(book: "Pesachim", chapter: "D", number: "1", hasAudio: true, hasVideo: false)
        let download3_4 = JTDownload(book: "Succah", chapter: "E", number: "4", hasAudio: false, hasVideo: true)
        let download3_5 = JTDownload(book: "Succah", chapter: "G", number: "2", hasAudio: true, hasVideo: false)
        let download3_6 = JTDownload(book: "Succah", chapter: "G", number: "3", hasAudio: true, hasVideo: false)
        downloads3.append(download3_1)
        downloads3.append(download3_2)
        downloads3.append(download3_3)
        downloads6.append(download3_4)
        downloads6.append(download3_5)
        downloads6.append(download3_6)
        let downloadGroup3 = JTDownloadGroup(group: "Pesachim", downloads: downloads3)
        let downloadGroup6 = JTDownloadGroup(group: "Succah", downloads: downloads6)
        
        gemaraDownloads.append(downloadGroup1)
        gemaraDownloads.append(downloadGroup2)
        gemaraDownloads.append(downloadGroup3)
        
        mishnaDownloads.append(downloadGroup4)
        mishnaDownloads.append(downloadGroup5)
        mishnaDownloads.append(downloadGroup6)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setSelectedPage()
    }
    
    fileprivate func setSelectedPage() {
        setButtonsColorAndFont()
        setGrayUpArrowPosition()
        checkIfTableViewEmpty(gemaraDownloads, gemaraTableView)
        checkIfTableViewEmpty(mishnaDownloads, mishnaTableView)
    }
    
    fileprivate func checkIfTableViewEmpty(_ downloads: [JTDownloadGroup], _ tableView: UITableView) {
        if downloads.count == 0 {
            setNoDownloadMessage(isHidden: false, table: tableView)
        } else {
            setNoDownloadMessage(isHidden: true, table: tableView)
        }
    }
    
    fileprivate func setNoDownloadMessage(isHidden: Bool, table: UITableView) {
        table.isHidden = !isHidden
        
        if table == gemaraTableView {
            if isGemaraSelected {
                deleteButton.isHidden = !isHidden
            }
            gemaraBooksImage.isHidden = isHidden
            gemaraNoDownloadedFilesMessage.isHidden = isHidden
            gemaraViewAllLessonsButton.isHidden = isHidden
        } else {
            if !isGemaraSelected {
                deleteButton.isHidden = !isHidden
            }
            mishnaBooksImage.isHidden = isHidden
            mishnaNoDownloadedFilesMessage.isHidden = isHidden
            mishnaViewAllLessonsButton.isHidden = isHidden
        }
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
        Utils.setViewShape(view: gemaraViewAllLessonsButton, viewBorderWidht: 0.57, viewBorderColor: UIColor(red: 0.18, green: 0.17, blue: 0.66, alpha: 1), viewCornerRadius: 10.32)
        gemaraViewAllLessonsButton.translatesAutoresizingMaskIntoConstraints = false
    }
    
    fileprivate func setViewsShadow() {
        let borderColor = UIColor(red: 0.93, green: 0.94, blue: 0.96, alpha: 1)
        let headerShadowColor = UIColor(red: 0.1, green: 0.12, blue: 0.57, alpha: 0.07)
        let shadowOffset = CGSize(width: 0.0, height: 10)
        let headerShadowOffset = CGSize(width: 0, height: 4)
        let cornerRadius = gemaraButton.layer.frame.height / 2
        Utils.setViewShape(view: gemaraButton, viewBorderWidht: 1, viewBorderColor: borderColor, viewCornerRadius: cornerRadius)
        Utils.dropViewShadow(view: gemaraButton, shadowColor: Colors.shadowColor, shadowRadius: 20, shadowOffset: shadowOffset)
        Utils.setViewShape(view: mishnaButton, viewBorderWidht: 1, viewBorderColor: borderColor, viewCornerRadius: cornerRadius)
        Utils.dropViewShadow(view: mishnaButton, shadowColor: Colors.shadowColor, shadowRadius: 20, shadowOffset: shadowOffset)
        Utils.dropViewShadow(view: headerShadowBasis, shadowColor: headerShadowColor, shadowRadius: 22, shadowOffset: headerShadowOffset)
    }
    
    //----------------------------------------------------------------
    // MARK: - UITableView Data Source and Delegate section
    //----------------------------------------------------------------
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == gemaraTableView {
            return gemaraDownloads.count
        } else {
            return mishnaDownloads.count
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == gemaraTableView {
            if gemaraDownloads[section].isExpanded {
                return gemaraDownloads[section].downloads.count
            } else {
                return 0
            }
        } else {
            if mishnaDownloads[section].isExpanded {
                return mishnaDownloads[section].downloads.count
            } else {
                return 0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.00001 // Returning 0 does not reduce the footer height!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 89
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var sectionName: String = ""
        let headerCell = tableView.dequeueReusableHeaderFooterView(withIdentifier: "headerCell") as! DownloadsHeaderCellController
        initHeaderCell(headerCell, tableView, section, &sectionName)
        headerCell.titleLabel?.text = sectionName
        headerCell.section = section
        headerCell.delegate = self
        let background = UIView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: headerCell.bounds.size))
        background.backgroundColor = .clear
        headerCell.backgroundView = background
        
        return headerCell
    }
    
    fileprivate func initHeaderCell(_ headerCell: DownloadsHeaderCellController, _ tableView: UITableView, _ section: Int, _ sectionName: inout String) {
        var isExpanded: Bool
        
        if tableView == gemaraTableView {
            headerCell.isFirstTable = true
            isExpanded = gemaraDownloads[section].isExpanded
            sectionName = self.gemaraDownloads[section].name
        } else {
            headerCell.isFirstTable = false
            isExpanded = mishnaDownloads[section].isExpanded
            sectionName = self.mishnaDownloads[section].name
        }
        
        if isExpanded {
            headerCell.arrowImage?.image = UIImage(named: "Black&BlueUpArrow")
        } else {
            headerCell.arrowImage?.image = UIImage(named: "Black&BlueDownArrow")
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "downloadsCell", for: indexPath) as! DownloadsCellController
        var download: JTDownload
        if tableView == gemaraTableView {
            cell.isFirstTable = true
            download = self.gemaraDownloads[indexPath.section].downloads[indexPath.row]
        } else {
            cell.isFirstTable = false
            download = self.mishnaDownloads[indexPath.section].downloads[indexPath.row]
        }

        cell.book.text = download.book
        cell.chapter.text = download.chapter
        cell.number.text = download.number
        cell.delegate = self
        cell.audioButton.isHidden = !download.hasAudio
        cell.videoButton.isHidden = !download.hasVideo
        Utils.setViewShape(view: cell.cellView, viewCornerRadius: 18)
        let shadowOffset = CGSize(width: 0.0, height: 12)
        Utils.dropViewShadow(view: cell.cellView, shadowColor: Colors.shadowColor, shadowRadius: 36, shadowOffset: shadowOffset)

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
    
    //----------------------------------------------------------------
    // MARK: - Implemented Protocols functions and helpers
    //----------------------------------------------------------------
    
    func toggleSection(header: DownloadsHeaderCellController, section: Int) {
        if header.isFirstTable {
            gemaraDownloads[section].isExpanded = !gemaraDownloads[section].isExpanded
            gemaraTableView.reloadSections([section], with: .automatic)
        } else {
            mishnaDownloads[section].isExpanded = !mishnaDownloads[section].isExpanded
            mishnaTableView.reloadSections([section], with: .automatic)
        }
    }
    
    // Note: coudln't avoid code reuse by writing help function or dictionaries
    func cellDeletePressed(_ cell: DownloadsCellController) {
        let alert = UIAlertController(title: "Please Confirm", message: "Delete this download(s)?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler: { action in
            if cell.isFirstTable {
                if let indexPath = self.gemaraTableView.indexPath(for: cell) {
                    self.gemaraDownloads[indexPath.section].downloads.remove(at: indexPath.row)
                    if self.gemaraDownloads[indexPath.section].downloads.count == 0 {
                        self.gemaraDownloads.remove(at: indexPath.section)
                        self.gemaraTableView.deleteSections([indexPath.section], with: .bottom)
                        self.reloadRelevantSections(indexPath.section, self.gemaraDownloads, self.gemaraTableView)
                    } else {
                        self.gemaraTableView.deleteRows(at: [indexPath], with: .bottom)
                    }
                }
            } else {
                if let indexPath = self.mishnaTableView.indexPath(for: cell) {
                    self.mishnaDownloads[indexPath.section].downloads.remove(at: indexPath.row)
                    if self.mishnaDownloads[indexPath.section].downloads.count == 0 {
                        self.mishnaDownloads.remove(at: indexPath.section)
                        self.mishnaTableView.deleteSections([indexPath.section], with: .bottom)
                        self.reloadRelevantSections(indexPath.section, self.mishnaDownloads, self.mishnaTableView)
                    } else {
                        self.mishnaTableView.deleteRows(at: [indexPath], with: .bottom)
                    }
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // Update the "section" field in the header cells that are after the deleted section.
    fileprivate func reloadRelevantSections(_ deletedSection: Int, _ downloadGroups: [JTDownloadGroup], _ tableView: UITableView) {
        var sections: IndexSet = []
        
        for section in deletedSection..<downloadGroups.count {
            sections.insert(section)
        }
        
        tableView.reloadSections(sections, with: .automatic)
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
