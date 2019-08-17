//בס״ד
//  GemaraLessonsViewController.swift
//  Jabrutouch
//
//  Created by Aaron Tuil on 05/08/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import UIKit

class GemaraLessonsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MishnaLessonCellDelegate {
    
    //========================================
    // MARK: - @IBOutlets and Fields
    //========================================
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var masechetLabel: UILabel!
    @IBOutlet weak var downloadButton: UIButton!
    
    var lessons: [JTGemaraLesson] = []
    var masechetName: String?
    var masechetId: Int?
    var isCurrentlyEditing: Bool = false
    var isFirstLoading: Bool = false
    
    private var activityView: ActivityView?
    //========================================
    // MARK: - LifeCycle
    //========================================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setTableView()
        self.setStrings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setContent()
    }
    //========================================
    // MARK: - Setup
    //========================================
    
    private func setTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func setStrings() {
        masechetLabel.text = self.masechetName
    }
    
    private func setContent() {
        guard let masechetId = self.masechetId else { return }
        self.showActivityView()
        ContentRepository.shared.getGemaraLessons(masechetId: masechetId) { (result:Result<[JTGemaraLesson], JTError>) in
            self.removeActivityView()
            switch result {
            case .success(let lessons):
                self.lessons = lessons
                self.tableView.reloadData()
            case .failure(let error):
                let title = Strings.error
                let message = error.message
                Utils.showAlertMessage(message, title: title, viewControler: self)
            }
        }
    }
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "lessonDownloadCell", for: indexPath) as! LessonDownloadCellController
        setImages(indexPath, cell)
        setEditingIfNeeded(cell)
        let lesson = self.lessons[indexPath.row]
        cell.lessonNumber.text = "\(lesson.page)"
        cell.lessonLength.text = lesson.durationDisplay
        cell.delegate = self
        cell.selectedRow = indexPath.row
        Utils.setViewShape(view: cell.underneathCellView, viewCornerRadius: 18)
        Utils.setViewShape(view: cell.cellView, viewCornerRadius: 18)
        let shadowOffset = CGSize(width: 0.0, height: 12)
        Utils.dropViewShadow(view: cell.underneathCellView, shadowColor: Colors.shadowColor, shadowRadius: 36, shadowOffset: shadowOffset)
        
        cell.underneathCellView.layoutIfNeeded()
        cell.cellView.layoutIfNeeded()
        
        return cell
    }
    
    fileprivate func setImages(_ indexPath: IndexPath, _ cell: LessonDownloadCellController) {
        if lessons[indexPath.row].isAudioDownloaded {
            cell.audioImage?.image = UIImage(named: "RedAudio")
            cell.redAudioVImage.isHidden = false
        } else {
            cell.audioImage?.image = UIImage(named: "Audio")
            cell.redAudioVImage.isHidden = true
        }
        
        cell.underneathAudioDownloadImage.isHidden = lessons[indexPath.row].isAudioDownloaded
        
        if lessons[indexPath.row].isVideoDownloaded {
            cell.videoImage?.image = UIImage(named: "RedVideo")
            cell.redVideoVImage.isHidden = false
        } else {
            cell.videoImage?.image = UIImage(named: "Video")
            cell.redVideoVImage.isHidden = true
        }
        
        cell.underneathVideoDownloadImage.isHidden = lessons[indexPath.row].isVideoDownloaded
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if isFirstLoading {
            if indexPath.row == tableView.numberOfRows(inSection: 0) - 1 {
                isFirstLoading = false
            }
        }
    }
    
    fileprivate func setEditingIfNeeded(_ cell: LessonDownloadCellController) {
        if !isFirstLoading {
            animateImagesVisibiltyIfNeeded(cell)
            UIView.animate(withDuration: 0.3) {
                if self.isCurrentlyEditing {
                    cell.cellViewTrailingConstraint.constant = self.view.frame.size.width / 2 - 20
                } else {
                    cell.cellViewTrailingConstraint.constant = 18
                }
                
                self.view.layoutIfNeeded()
            }
        }
    }
    
    fileprivate func animateImagesVisibiltyIfNeeded(_ cell: LessonDownloadCellController) {
        if (cell.audioImage.alpha == 0) == !isCurrentlyEditing { // Animate only when a change occurred
            UIView.animate(withDuration: 0.2, delay: isCurrentlyEditing ? 0 : 0.1, animations: {
                if cell.redAudioVImage.isHidden == false { // Animate only when suppose to be visible
                    cell.redAudioVImage.alpha = self.isCurrentlyEditing ? 0 : 1
                }
                if cell.redVideoVImage.isHidden == false {
                    cell.redVideoVImage.alpha = self.isCurrentlyEditing ? 0 : 1
                }
                cell.audioImage.alpha = self.isCurrentlyEditing ? 0 : 1
                cell.videoImage.alpha = self.isCurrentlyEditing ? 0 : 1
            })
        }
    }
    
    //========================================
    // MARK: - @IBActions and helpers
    //========================================
    
    @IBAction func backPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func downloadPressed(_ sender: Any) {
        isCurrentlyEditing = !isCurrentlyEditing
        
        if isCurrentlyEditing {
            downloadButton.setImage(nil, for: .normal)
            downloadButton.setTitle("Done", for: .normal)
        } else {
            downloadButton.setImage(UIImage(named: "Download"), for: .normal)
            downloadButton.setTitle("", for: .normal)
        }
        
        tableView.reloadData()
    }
    
    //====================================================
    // MARK: - Implemented Protocols functions and helpers
    //====================================================
    
    func cellPressed(selectedRow: Int) {
        print("Cell Pressed")
        // TODO Send to View mode (Ask Dudi what is it)
    }
    
    func audioPressed(selectedRow: Int) {
        print("Audio Pressed")
        // TODO Send to correct screen
    }
    
    func videoPressed(selectedRow: Int) {
        print("Video Pressed")
        // TODO Send to correct screen
    }
    
    func underneathAudioPressed(selectedRow: Int) {
        if lessons[selectedRow].isAudioDownloaded {
            alreadyDownloadedMediaAlert()
        } else {
            print("Download audio")
        }
    }
    
    fileprivate func alreadyDownloadedMediaAlert() {
        let alert = UIAlertController(title: "", message: "The media already exists in the phone", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func underneathVideoPressed(selectedRow: Int) {
        if lessons[selectedRow].isVideoDownloaded {
            alreadyDownloadedMediaAlert()
        } else {
            print("Download video")
        }
    }
    
    //============================================================
    // MARK: - ActivityView
    //============================================================
    
    private func showActivityView() {
        DispatchQueue.main.async {
            if self.activityView == nil {
                self.activityView = Utils.showActivityView(inView: self.view, withFrame: self.view.frame, text: nil)
            }
        }
    }
    private func removeActivityView() {
        DispatchQueue.main.async {
            if let view = self.activityView {
                Utils.removeActivityView(view)
            }
        }
    }
}
