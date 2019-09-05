//בעזרת ה׳ החונן לאדם דעת
//  DownloadsViewController.swift
//  Jabrutouch
//
//  Created by Yoni Reiss on 18/07/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import UIKit

class DownloadsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, HeaderViewDelegate, DownloadsCellDelegate {
   
    
    
    //========================================
    // MARK: - @IBOutlets and Fields
    //========================================
    
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
    
    var delegate: MainModalDelegate?
    fileprivate var grayUpArrowXCentererdToGemara: NSLayoutConstraint?
    fileprivate var grayUpArrowXCentererdToMishna: NSLayoutConstraint?
    fileprivate var gemaraDownloads: [JTSederDownloadedGemaraLessons] = []
    fileprivate var mishnaDownloads: [JTSederDownloadedMishnaLessons] = []
    fileprivate var isGemaraSelected = true
    fileprivate var isDeleting = false
    fileprivate var tableViewsMap = [String: UITableView]()
    fileprivate let GEMARA = "Gemara"
    fileprivate let MISHNA = "Mishna"
    fileprivate var isReloadingSection =  false
    
    fileprivate var gemaraOpenSections: Set<Int> = []
    fileprivate var mishnaOpenSections: Set<Int> = []
    
    //=======================================
    // MARK: - LifeCycle
    //=======================================
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.portrait]
    }
    
    override func viewDidLoad() {
        initialGrayUpArrowXCentererdToGemara.isActive = false
        grayUpArrowXCentererdToGemara = grayUpArrow.centerXAnchor.constraint(equalTo: gemaraButton.centerXAnchor)
        grayUpArrowXCentererdToMishna = grayUpArrow.centerXAnchor.constraint(equalTo: mishnaButton.centerXAnchor)
        gemaraTableView.register(UINib(nibName: "DownloadsHeaderCell", bundle: nil), forHeaderFooterViewReuseIdentifier: "headerCell")
        mishnaTableView.register(UINib(nibName: "DownloadsHeaderCell", bundle: nil), forHeaderFooterViewReuseIdentifier: "headerCell")
        gemaraTableView.delegate = self
        gemaraTableView.dataSource = self
        mishnaTableView.delegate = self
        mishnaTableView.dataSource = self
        
        tableViewsMap[GEMARA] = gemaraTableView
        tableViewsMap[MISHNA] = mishnaTableView
        setViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setContent()
        setSelectedPage()

    }
    
    //========================================
    // MARK: - Setup
    //========================================
    
    
    fileprivate func setSelectedPage() {
        setButtonsColorAndFont()
        setGrayUpArrowPosition()
        checkIfTableViewEmpty(gemaraDownloads, gemaraTableView)
        checkIfTableViewEmpty(mishnaDownloads, mishnaTableView)
    }
    
    fileprivate func checkIfTableViewEmpty(_ downloads: [Any], _ tableView: UITableView) {
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
    
    fileprivate func setContent() {
        self.gemaraDownloads = ContentRepository.shared.getDownloadedGemaraLessons()
        self.mishnaDownloads = ContentRepository.shared.getDownloadedMishnaLessons()
        self.gemaraTableView.reloadData()
        self.mishnaTableView.reloadData()
    }
    //=======================================================
    // MARK: - UITableView Data Source and Delegate section
    //=======================================================
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == gemaraTableView {
            return gemaraDownloads.count
        } else {
            return mishnaDownloads.count
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == gemaraTableView {
            if gemaraOpenSections.contains(section) {
                return gemaraDownloads[section].records.count
            } else {
                return 0
            }
        } else {
            if mishnaOpenSections.contains(section) {
                return mishnaDownloads[section].records.count
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
        let headerCell = tableView.dequeueReusableHeaderFooterView(withIdentifier: "headerCell") as! HeaderCellController
        initHeaderCell(headerCell, tableView, section, &sectionName)
        headerCell.titleLabel?.text = sectionName
        headerCell.section = section
        headerCell.delegate = self
        let background = UIView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: headerCell.bounds.size))
        background.backgroundColor = .clear
        headerCell.backgroundView = background
        
        return headerCell
    }
    
    fileprivate func initHeaderCell(_ headerCell: HeaderCellController, _ tableView: UITableView, _ section: Int, _ sectionName: inout String) {
        var isExpanded: Bool
        var sectionRowsCount: Int
        
        if tableView == gemaraTableView {
            headerCell.isFirstTable = true
            isExpanded = gemaraOpenSections.contains(section)
            sectionName = self.gemaraDownloads[section].sederName
            sectionRowsCount = self.gemaraDownloads[section].records.count
        } else {
            headerCell.isFirstTable = false
            isExpanded = mishnaOpenSections.contains(section)
            sectionName = self.mishnaDownloads[section].sederName
            sectionRowsCount = self.mishnaDownloads[section].records.count
        }
        
        if isExpanded {
            headerCell.arrowImage?.image = UIImage(named: "Black&BlueUpArrow")
            headerCell.sectionRowsCountLabel.isHidden = true
        } else {
            headerCell.arrowImage?.image = UIImage(named: "Black&BlueDownArrow")
            headerCell.sectionRowsCountLabel.text = String(sectionRowsCount)
            headerCell.sectionRowsCountLabel.isHidden = false
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "downloadsCell", for: indexPath) as! DownloadsCellController
        cell.indexPath = indexPath
        if tableView == gemaraTableView {
            cell.isFirstTable = true
            let lesson = self.gemaraDownloads[indexPath.section].records[indexPath.row]
            cell.book.text = lesson.masechetName
            cell.chapter.text = ""
            cell.number.text = "\(lesson.lesson.page)"
            cell.delegate = self
            cell.audioButton.isHidden = !lesson.lesson.isAudioDownloaded
            cell.videoButton.isHidden = !lesson.lesson.isVideoDownloaded
        } else {
            cell.isFirstTable = false
            let lesson = self.mishnaDownloads[indexPath.section].records[indexPath.row]
            cell.book.text = lesson.masechetName
            cell.chapter.text = lesson.chapter
            cell.number.text = "\(lesson.lesson.mishna)"
            cell.delegate = self
            cell.audioButton.isHidden = !lesson.lesson.isAudioDownloaded
            cell.videoButton.isHidden = !lesson.lesson.isVideoDownloaded
        }

        
        Utils.setViewShape(view: cell.cellView, viewCornerRadius: 18)
        let shadowOffset = CGSize(width: 0.0, height: 12)
        Utils.dropViewShadow(view: cell.cellView, shadowColor: Colors.shadowColor, shadowRadius: 36, shadowOffset: shadowOffset)
        animateSizeChangeWhenNeeded(cell)
        
        cell.cellView.layoutIfNeeded()
        
        return cell
    }
    
    fileprivate func animateSizeChangeWhenNeeded(_ cell: DownloadsCellController) {
        UIView.animate(withDuration: 0.3, delay: isDeleting ? 0.15 : 0, animations: {
            if self.isDeleting {
                cell.deleteButton.alpha = 1
            } else {
                cell.deleteButton.alpha = 0
            }
            
            self.view.layoutIfNeeded()
        })
        
        if isReloadingSection {
            setCellTrailingConstraint(cell)
        } else {
            UIView.animate(withDuration: 0.3, delay: isDeleting ? 0 : 0.15, animations: {
                self.setCellTrailingConstraint(cell)
            })
        }
    }
    
    fileprivate func setCellTrailingConstraint(_ cell: DownloadsCellController) {
        if self.isDeleting {
            cell.cellTrailingConstraint.constant = 45
        } else {
            cell.cellTrailingConstraint.constant = 21
        }
        
        self.view.layoutIfNeeded()
    }
    
    //======================================================
    // MARK: - Implemented Protocols functions and helpers
    //======================================================
    
    func toggleSection(header: HeaderCellController, section: Int) {
        if header.isFirstTable {
            if gemaraOpenSections.contains(section) {
                gemaraOpenSections.remove(section)
            }
            else {
                gemaraOpenSections.insert(section)
            }
            reloadSection(GEMARA, section)
        } else {
            if mishnaOpenSections.contains(section) {
                mishnaOpenSections.remove(section)
            }
            else {
                mishnaOpenSections.insert(section)
            }
            reloadSection(MISHNA, section)
        }
    }
    
    fileprivate func reloadSection(_ table: String, _ section: Int) {
        isReloadingSection = true
        CATransaction.begin()
        tableViewsMap[table]?.beginUpdates()
        CATransaction.setCompletionBlock {
            self.isReloadingSection = false
        }
        tableViewsMap[table]?.reloadSections([section], with: .automatic)
        tableViewsMap[table]?.endUpdates()
        CATransaction.commit()
    }
    
    // Note: coudln't avoid code reuse by writing help function or dictionaries
    func cellDeletePressed(_ cell: DownloadsCellController) {
        let alert = UIAlertController(title: "Please Confirm", message: "Delete this download(s)?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler: { action in
            if cell.isFirstTable {
                if let indexPath = self.gemaraTableView.indexPath(for: cell) {
                   
                    // Remove from storage
                    let downloadedLesson = self.gemaraDownloads[indexPath.section].records[indexPath.row]
                    ContentRepository.shared.removeLessonFromDownloaded(downloadedLesson.lesson, sederId: "\(self.gemaraDownloads[indexPath.section].sederId)", masechetId: downloadedLesson.masechetId)
                    
                    // Refresh local data and view
                    self.gemaraDownloads[indexPath.section].records.remove(at: indexPath.row)
                    if self.gemaraDownloads[indexPath.section].records.count == 0 {
                        self.gemaraDownloads.remove(at: indexPath.section)
                        self.gemaraTableView.deleteSections([indexPath.section], with: .bottom)
                        self.reloadRelevantSections(indexPath.section, self.gemaraDownloads, self.gemaraTableView)
                    } else {
                        self.gemaraTableView.deleteRows(at: [indexPath], with: .bottom)
                    }
                }
            } else {
                if let indexPath = self.mishnaTableView.indexPath(for: cell) {
                   // Remove from storage
                    let downloadedLesson = self.mishnaDownloads[indexPath.section].records[indexPath.row]
                    ContentRepository.shared.removeLessonFromDownloaded(downloadedLesson.lesson, sederId: "\(self.mishnaDownloads[indexPath.section].sederId)", masechetId: downloadedLesson.masechetId, chapter: downloadedLesson.chapter)

                    // Refresh local data and view
                    self.mishnaDownloads[indexPath.section].records.remove(at: indexPath.row)
                    if self.mishnaDownloads[indexPath.section].records.count == 0 {
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
    
    func playAudioPressed(atIndexPath indexPath: IndexPath, lessonType: JTLessonType) {
        var lesson: JTLesson!
        var masechetName: String?
        var masechetId: String!
        var chapter: String?
        var sederId: String!
        
        switch lessonType {
        case .gemara:
            lesson = self.gemaraDownloads[indexPath.section].records[indexPath.row].lesson
            masechetName = self.gemaraDownloads[indexPath.section].records[indexPath.row].masechetName
            masechetId = self.gemaraDownloads[indexPath.section].records[indexPath.row].masechetId
            sederId = self.mishnaDownloads[indexPath.section].records[indexPath.row].sederId
            
        case .mishna:
            lesson = self.mishnaDownloads[indexPath.section].records[indexPath.row].lesson
            masechetName = self.mishnaDownloads[indexPath.section].records[indexPath.row].masechetName
            masechetId = self.mishnaDownloads[indexPath.section].records[indexPath.row].masechetId
            chapter = self.mishnaDownloads[indexPath.section].records[indexPath.row].chapter
            sederId = self.mishnaDownloads[indexPath.section].records[indexPath.row].sederId
        }
        
        DispatchQueue.main.async {
            self.playLesson(lesson, mediaType: .audio, masechetName: masechetName, sederId: sederId, masechetId: masechetId, chapter: chapter)
        }
    }
    
    func playVideoPressed(atIndexPath indexPath: IndexPath, lessonType: JTLessonType) {
        var lesson: JTLesson!
        var masechetName: String?
        var masechetId: String!
        var chapter: String?
        var sederId: String!
        
        switch lessonType {
        case .gemara:
            lesson = self.gemaraDownloads[indexPath.section].records[indexPath.row].lesson
            masechetName = self.gemaraDownloads[indexPath.section].records[indexPath.row].masechetName
            masechetId = self.gemaraDownloads[indexPath.section].records[indexPath.row].masechetId
            sederId = self.gemaraDownloads[indexPath.section].records[indexPath.row].sederId
        case .mishna:
            lesson = self.mishnaDownloads[indexPath.section].records[indexPath.row].lesson
            masechetName = self.mishnaDownloads[indexPath.section].records[indexPath.row].masechetName
            masechetId = self.mishnaDownloads[indexPath.section].records[indexPath.row].masechetId
            chapter = self.mishnaDownloads[indexPath.section].records[indexPath.row].chapter
            sederId = self.mishnaDownloads[indexPath.section].records[indexPath.row].sederId

        }
        
        DispatchQueue.main.async {
            self.playLesson(lesson, mediaType: .video, masechetName: masechetName, sederId: sederId, masechetId: masechetId, chapter: chapter)
        }
    }
    
    // Help function attempted to avoid code reuse in cellDeletePressed() (Crashes app when deleting first a row in the middle of a section and then deleting all the rows of this section)
    fileprivate func deleteCell(_ cell: DownloadsCellController, _ tableView: inout UITableView, _ downloads: inout [JTDownloadGroup]) {
        if let indexPath = tableView.indexPath(for: cell) {
            downloads[indexPath.section].downloads.remove(at: indexPath.row)
            tableView.beginUpdates()
            if downloads[indexPath.section].downloads.count == 0 {
                downloads.remove(at: indexPath.section)
                tableView.deleteSections([indexPath.section], with: .bottom)
                self.reloadRelevantSections(indexPath.section, downloads, tableView)
            } else {
                tableView.deleteRows(at: [indexPath], with: .bottom)
            }
            tableView.endUpdates()
        }
    }
    
    // Update the "section" field in the header cells that are after the deleted section.
    fileprivate func reloadRelevantSections(_ deletedSection: Int, _ downloadGroups: [Any], _ tableView: UITableView) {
        var sections: IndexSet = []
        
        for section in deletedSection..<downloadGroups.count {
            sections.insert(section)
        }
        
        tableView.reloadSections(sections, with: .automatic)
    }
    
    //======================================================
    // MARK: - @IBActions and Helpers
    //======================================================
    
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
    
    @IBAction func backPressed(_ sender: Any) {
        self.delegate?.dismissMainModal()
    }
    
    //======================================================
    // MARK: - Player
    //======================================================
    
    private func playLesson(_ lesson: JTLesson, mediaType: JTLessonMediaType, masechetName: String?, sederId: String, masechetId: String, chapter: String? ) {
        let playerVC = LessonPlayerViewController(lesson: lesson, mediaType: mediaType, sederId: sederId, masechetId: masechetId, chapter: chapter)
        self.present(playerVC, animated: true) {
            
        }
        
        if let mishnaLesson = lesson as? JTMishnaLesson, let masechetName = masechetName, let chapter = chapter  {
            ContentRepository.shared.lessonWatched(mishnaLesson, masechetName: masechetName, masechetId: "\(masechetId)", chapter: "\(chapter)", sederId: sederId)
        }
        
        else if let gemaraLesson = lesson as? JTGemaraLesson, let masechetName = masechetName  {
            ContentRepository.shared.lessonWatched(gemaraLesson, masechetName: masechetName, masechetId: "\(masechetId)", sederId: sederId)
        }
    }
    
}
