//בס״ד
//  MishnaLessonsViewController.swift
//  Jabrutouch
//
//  Created by Aaron Tuil on 01/08/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import UIKit

class MishnaLessonsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MishnaLessonCellDelegate {
    
    //========================================
    // MARK: - @IBOutlets and Fields
    //========================================
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var masechetLabel: UILabel!
    @IBOutlet weak var chapterLabel: UILabel!
    @IBOutlet weak var downloadButton: UIButton!
    
    var lessons: [JTMishnaLesson] = []
    var masechetName: String?
    var chapter: Int?
    var sederId: String?
    var masechetId: Int?
    var isCurrentlyEditing: Bool = false
    var isFirstLoading: Bool = false
    
    private var activityView: ActivityView?
    //========================================
    // MARK: - LifeCycle
    //========================================
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.portrait]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setTableView()
        self.setStrings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setContent()
        ContentRepository.shared.addDelegate(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        ContentRepository.shared.removeDelegate(self)
    }
    //========================================
    // MARK: - Setup
    //========================================
    
    private func setTableView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    private func setStrings() {
        self.masechetLabel.text = self.masechetName
        self.chapterLabel.text = "\(self.chapter ?? 1)"
    }
    
    private func setContent() {
        guard let masechetId = self.masechetId, let chapter = self.chapter else { return }
        self.showActivityView()
        ContentRepository.shared.getMishnaLessons(masechetId: masechetId, chapter: chapter) { (result:
            Result<[JTMishnaLesson], JTError>) in
            self.removeActivityView()
            switch result {
            case .success(let lessons):
                self.lessons = lessons
                self.syncDownloadData()
                self.tableView.reloadData()
            case .failure(let error):
                let title = Strings.error
                let message = error.message
                Utils.showAlertMessage(message, title: title, viewControler: self)
            }
        }
        
    }
    
    func syncDownloadData() {
        for i in 0..<self.lessons.count {
            if let progress = ContentRepository.shared.getLessonDownloadProgress(self.lessons[i].id) {
                self.lessons[i].isDownloading = true
                self.lessons[i].downloadProgress = progress
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
        
        let lesson = lessons[indexPath.row]
        cell.lessonNumber.text = "\(lesson.mishna)"
        cell.lessonLength.text = lesson.durationDisplay
        cell.delegate = self
        cell.selectedRow = indexPath.row
        Utils.setViewShape(view: cell.downloadButtonsContainerView, viewCornerRadius: 18)
        Utils.setViewShape(view: cell.cellView, viewCornerRadius: 18)
        let shadowOffset = CGSize(width: 0.0, height: 12)
        Utils.dropViewShadow(view: cell.downloadButtonsContainerView, shadowColor: Colors.shadowColor, shadowRadius: 36, shadowOffset: shadowOffset)
        
        // Set playing buttons enablity according to downloading state
        setCellImages(cell, lesson: lesson)
        setEditingIfNeeded(cell, lesson: lesson)
        setCellDownloadMode(cell, lesson: lesson)
        
        cell.downloadButtonsContainerView.layoutIfNeeded()
        cell.cellView.layoutIfNeeded()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if isFirstLoading {
            if indexPath.row == tableView.numberOfRows(inSection: 0) - 1 {
                isFirstLoading = false
            }
        }
    }
    
    //=====================================================
    // MARK: - LessonDownloadCellController setup methods
    //=====================================================
    
    fileprivate func setCellImages(_ cell: LessonDownloadCellController, lesson: JTLesson) {
        if lesson.isAudioDownloaded {
            cell.audioImage?.image = UIImage(named: "RedAudio")
            cell.redAudioVImage.isHidden = false
        } else {
            cell.audioImage?.image = UIImage(named: "Audio")
            cell.redAudioVImage.isHidden = true
        }
        
        cell.downloadAudioButtonImageView.isHidden = lesson.isAudioDownloaded
        
        if lesson.isVideoDownloaded {
            cell.videoImage?.image = UIImage(named: "RedVideo")
            cell.redVideoVImage.isHidden = false
        } else {
            cell.videoImage?.image = UIImage(named: "Video")
            cell.redVideoVImage.isHidden = true
        }
        
        cell.downloadVideoButtonImageView.isHidden = lesson.isVideoDownloaded
    }
    
    fileprivate func setCellDownloadMode(_ cell: LessonDownloadCellController, lesson: JTLesson) {
        let downloadProgress = "\(Int((lesson.downloadProgress ?? 0.0) * 100))%"
        cell.downloadProgressPercentageLabel.text = downloadProgress
        cell.downloadProgressPercentageLabel.isHidden = !lesson.isDownloading
        cell.playAudioButton.isEnabled = !lesson.isDownloading
        cell.playVideoButton.isEnabled = !lesson.isDownloading
        cell.audioImage.alpha = lesson.isDownloading ? 0.3 : 1.0
        cell.videoImage.alpha = lesson.isDownloading ? 0.3 : 1.0
    }
    
    fileprivate func setEditingIfNeeded(_ cell: LessonDownloadCellController, lesson: JTLesson) {
        if !isFirstLoading {
            animateImagesVisibiltyIfNeeded(cell, lesson: lesson)            
            UIView.animate(withDuration: 0.3) {
                if self.isCurrentlyEditing && !lesson.isDownloading {
                    cell.cellViewTrailingConstraint.constant = self.view.frame.size.width / 2 - 20
                } else {
                    cell.cellViewTrailingConstraint.constant = 18
                }
                
                self.view.layoutIfNeeded()
            }
        }
    }
    
    fileprivate func animateImagesVisibiltyIfNeeded(_ cell: LessonDownloadCellController, lesson: JTLesson) {
        if (cell.audioImage.isHidden) == !isCurrentlyEditing { // Animate only when a change occurred
            UIView.animate(withDuration: 0.2, delay: isCurrentlyEditing ? 0 : 0.1, animations: {
                if lesson.isAudioDownloaded  { // Animate only when suppose to be visible
                    cell.redAudioVImage.isHidden = self.isCurrentlyEditing ? true : false
                }
                if lesson.isVideoDownloaded {
                    cell.redVideoVImage.isHidden = self.isCurrentlyEditing ? true : false
                }
                cell.audioImage.isHidden = self.isCurrentlyEditing ? true : false
                cell.videoImage.isHidden = self.isCurrentlyEditing ? true : false
                cell.playAudioButton.isHidden = self.isCurrentlyEditing ? true : false
                cell.playVideoButton.isHidden = self.isCurrentlyEditing ? true : false

            })
        }
    }
    
    private func toggleEditingMode() {
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
    
    //========================================
    // MARK: - @IBActions and helpers
    //========================================
    
    @IBAction func backPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func downloadPressed(_ sender: Any) {
        self.toggleEditingMode()
    }
    
    //====================================================
    // MARK: - Implemented Protocols functions and helpers
    //====================================================
    
    func cellPressed(selectedRow: Int) {
        // TODO Send to View mode (Ask Dudi what is it)
    }
    
    func playAudioPressed(selectedRow: Int) {
        let lesson = self.lessons[selectedRow]
        self.playLesson(lesson, mediaType: .audio)
    }
    
    func playVideoPressed(selectedRow: Int) {
        let lesson = self.lessons[selectedRow]
        self.playLesson(lesson, mediaType: .video)
    }
    
    func downloadAudioPressed(selectedRow: Int) {
        let lesson = self.lessons[selectedRow]
        if lesson.isAudioDownloaded {
            alreadyDownloadedMediaAlert()
        } else {
            self.lessons[selectedRow].isDownloading = true
            self.toggleEditingMode()
            ContentRepository.shared.lessonStartedDownloading(lesson.id)
            ContentRepository.shared.downloadMishnaLesson(lesson, mediaType: .audio, delegate: ContentRepository.shared)
        }
    }
    
    func downloadVideoPressed(selectedRow: Int) {
        let lesson = self.lessons[selectedRow]
        if lesson.isVideoDownloaded {
            alreadyDownloadedMediaAlert()
        } else {
            self.lessons[selectedRow].isDownloading = true
            self.toggleEditingMode()
            ContentRepository.shared.lessonStartedDownloading(lesson.id)
            ContentRepository.shared.downloadMishnaLesson(lesson, mediaType: .video, delegate: ContentRepository.shared)
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
    
    private func playLesson(_ lesson: JTLesson, mediaType: JTLessonMediaType) {
        guard let pdfUrl = lesson.textURL else { return    }
        let audioUrl = lesson.audioURL
        let videoUrl = lesson.videoURL
        let playerVC = LessonPlayerViewController(pdfUrl: pdfUrl, videoUrl: videoUrl, audioUrl: audioUrl, mediaType: mediaType)
        self.present(playerVC, animated: true) {
            
        }
        
        if let mishnaLesson = lesson as? JTMishnaLesson, let masechetName = self.masechetName, let masechetId = self.masechetId, let chapter = self.chapter  {
            ContentRepository.shared.lessonWatched(mishnaLesson, masechetName: masechetName, masechetId: "\(masechetId)", chapter: "\(chapter)")
        }
    }
}

extension MishnaLessonsViewController: ContentRepositoryDownloadDelegate {
    func downloadCompleted(downloadId: Int) {
        guard let index = self.lessons.firstIndex(where: {$0.id == downloadId}) else { return }
        guard let sederId = self.sederId else { return }
        guard let masecetId = self.masechetId else { return }
        guard let chapter = self.chapter else { return }
        
        let lesson = self.lessons[index]
        self.lessons[index].isDownloading = false
        self.lessons[index].downloadProgress = nil
        self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
        ContentRepository.shared.lessonEndedDownloading(lesson.id)
        ContentRepository.shared.addLessonToDownloaded(lesson, sederId: sederId, masechetId: "\(masecetId)", chapter: "\(chapter)")
        print("GemaraLessonsViewController downloadCompleted, downloadId: \(downloadId)")
    }
    
    func downloadProgress(downloadId: Int, progress: Float) {
        guard let index = self.lessons.firstIndex(where: {$0.id == downloadId}) else { return }
        self.lessons[index].downloadProgress = progress
        ContentRepository.shared.lessonDownloadProgress(downloadId, progress: progress)
        
        // Update cell progress
        guard let cell = self.tableView.cellForRow(at:  IndexPath(row: index, section: 0)) as? LessonDownloadCellController else { return }
        setCellImages(cell, lesson: self.lessons[index])
        setEditingIfNeeded(cell, lesson: self.lessons[index])
        setCellDownloadMode(cell, lesson: self.lessons[index])
        
        print("GemaraLessonsViewController downloadProgress, progress: \(progress)")
    }
}
