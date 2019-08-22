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
    var sederId: String?
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
        setEditingIfNeeded(indexPath, cell)
        let lesson = self.lessons[indexPath.row]
        cell.lessonNumber.text = "\(lesson.page)"
        cell.lessonLength.text = lesson.durationDisplay
        cell.delegate = self
        cell.selectedRow = indexPath.row
        Utils.setViewShape(view: cell.downloadButtonsContainerView, viewCornerRadius: 18)
        Utils.setViewShape(view: cell.cellView, viewCornerRadius: 18)
        let shadowOffset = CGSize(width: 0.0, height: 12)
        Utils.dropViewShadow(view: cell.downloadButtonsContainerView, shadowColor: Colors.shadowColor, shadowRadius: 36, shadowOffset: shadowOffset)
        
        cell.downloadButtonsContainerView.layoutIfNeeded()
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
        
        cell.downloadAudioButtonImageView.isHidden = lessons[indexPath.row].isAudioDownloaded
        
        if lessons[indexPath.row].isVideoDownloaded {
            cell.videoImage?.image = UIImage(named: "RedVideo")
            cell.redVideoVImage.isHidden = false
        } else {
            cell.videoImage?.image = UIImage(named: "Video")
            cell.redVideoVImage.isHidden = true
        }
        
        cell.downloadVideoButtonImageView.isHidden = lessons[indexPath.row].isVideoDownloaded
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if isFirstLoading {
            if indexPath.row == tableView.numberOfRows(inSection: 0) - 1 {
                isFirstLoading = false
            }
        }
    }
    
    fileprivate func setEditingIfNeeded(_ indexPath: IndexPath, _ cell: LessonDownloadCellController) {
        if !isFirstLoading {
            animateImagesVisibiltyIfNeeded(indexPath, cell)
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
    
    fileprivate func animateImagesVisibiltyIfNeeded(_ indexPath: IndexPath, _ cell: LessonDownloadCellController) {
        if (cell.audioImage.isHidden) == !isCurrentlyEditing { // Animate only when a change occurred
            UIView.animate(withDuration: 0.2, delay: isCurrentlyEditing ? 0 : 0.1, animations: {
                if self.lessons[indexPath.row].isAudioDownloaded  { // Animate only when suppose to be visible
                    cell.redAudioVImage.isHidden = self.isCurrentlyEditing ? true : false
                }
                if self.lessons[indexPath.row].isVideoDownloaded {
                    cell.redVideoVImage.isHidden = self.isCurrentlyEditing ? true : false
                }
                cell.audioImage.isHidden = self.isCurrentlyEditing ? true : false
                cell.videoImage.isHidden = self.isCurrentlyEditing ? true : false
                cell.playAudioButton.isHidden = self.isCurrentlyEditing ? true : false
                cell.playVideoButton.isHidden = self.isCurrentlyEditing ? true : false
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
    
    func playAudioPressed(selectedRow: Int) {
        print("Audio Pressed")
        // TODO Send to correct screen
    }
    
    func playVideoPressed(selectedRow: Int) {
        print("Video Pressed")
        // TODO Send to correct screen
    }
    
    func downloadAudioPressed(selectedRow: Int) {
        let lesson = self.lessons[selectedRow]
        if lesson.isAudioDownloaded {
            alreadyDownloadedMediaAlert()
        } else {
            ContentRepository.shared.downloadGemaraLesson(lesson, mediaType: .audio, delegate: self)
        }
    }
    
    func downloadVideoPressed(selectedRow: Int) {
        let lesson = self.lessons[selectedRow]
        if lesson.isVideoDownloaded {
            alreadyDownloadedMediaAlert()
        } else {
            ContentRepository.shared.downloadGemaraLesson(lesson, mediaType: .video, delegate: self)
        }
    }
    
    fileprivate func alreadyDownloadedMediaAlert() {
        let alert = UIAlertController(title: "", message: "The media already exists in the phone", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
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

extension GemaraLessonsViewController: DownloadTaskDelegate {
    func downloadCompleted(downloadId: Int) {
        guard let lesson = (self.lessons.filter{$0.id == downloadId}).first else { return }
        guard let sederId = self.sederId else { return }
        guard let masechetId = self.masechetId else { return }
        ContentRepository.shared.addLessonToDownloaded(lesson, sederId: sederId, masechetId: "\(masechetId)")
        print("GemaraLessonsViewController downloadCompleted, downloadId: \(downloadId)")
    }
    
    func downloadProgress(downloadId: Int, progress: Float) {
        print("GemaraLessonsViewController downloadProgress, progress: \(progress)")
    }
}

