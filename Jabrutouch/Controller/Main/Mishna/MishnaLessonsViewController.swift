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
            if let progress = ContentRepository.shared.getLessonDownloadProgress(self.lessons[i].id, mediaType: .audio) {
                self.lessons[i].isDownloadingAudio = true
                self.lessons[i].audioDownloadProgress = progress
            }
            else if let progress = ContentRepository.shared.getLessonDownloadProgress(self.lessons[i].id, mediaType: .video) {
                self.lessons[i].isDownloadingVideo = true
                self.lessons[i].videoDownloadProgress = progress
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
        
        cell.setLesson(lesson)
        if !isFirstLoading {
            cell.setEditingIfNeeded(lesson: lesson, isCurrentlyEditing: self.isCurrentlyEditing)
            self.view.layoutIfNeeded()
        }
        let count = 10.0
        let progress = CGFloat(count/100)
        cell.lessonProgressBar.progress = progress
        cell.lessonProgressBar.rounded = false
        cell.lessonProgressBar.layer.cornerRadius = 8
        cell.lessonProgressBar.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
       
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
        DispatchQueue.main.async {
            let lesson = self.lessons[selectedRow]
            self.playLesson(lesson, mediaType: .audio)
        }
    }
    
    func playVideoPressed(selectedRow: Int) {
        DispatchQueue.main.async {
            let lesson = self.lessons[selectedRow]
            self.playLesson(lesson, mediaType: .video)
        }
    }
    
    func downloadAudioPressed(selectedRow: Int) {
        let lesson = self.lessons[selectedRow]
        if lesson.isAudioDownloaded {
            alreadyDownloadedMediaAlert()
        } else {
            self.lessons[selectedRow].isDownloadingAudio = true
            self.toggleEditingMode()
            ContentRepository.shared.lessonStartedDownloading(lesson.id, mediaType: .audio)
            ContentRepository.shared.downloadLesson(lesson, mediaType: .audio, delegate: ContentRepository.shared)
        }
    }
    
    func downloadVideoPressed(selectedRow: Int) {
        let lesson = self.lessons[selectedRow]
        if lesson.isVideoDownloaded {
            alreadyDownloadedMediaAlert()
        } else {
            self.lessons[selectedRow].isDownloadingVideo = true
            self.toggleEditingMode()
            ContentRepository.shared.lessonStartedDownloading(lesson.id, mediaType: .audio)
            ContentRepository.shared.downloadLesson(lesson, mediaType: .video, delegate: ContentRepository.shared)
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
        guard let sederId = self.sederId, let masechetId = self.masechetId, let chapter = self.chapter else { return }
        let playerVC = LessonPlayerViewController(lesson: lesson, mediaType: mediaType, sederId: sederId, masechetId: "\(masechetId)", chapter: "\(chapter)")
        playerVC.modalPresentationStyle = .fullScreen
        playerVC.masechet = self.masechetName ?? ""
        playerVC.daf = "\(chapter)"
        self.present(playerVC, animated: true) {
            
        }
        
        if let mishnaLesson = lesson as? JTMishnaLesson, let masechetName = self.masechetName  {
            ContentRepository.shared.lessonWatched(mishnaLesson, masechetName: masechetName, masechetId: "\(masechetId)", chapter: "\(chapter)" ,sederId: sederId)
        }
    }
}

extension MishnaLessonsViewController: ContentRepositoryDownloadDelegate {
    func downloadCompleted(downloadId: Int, mediaType: JTLessonMediaType) {
        guard let index = self.lessons.firstIndex(where: {$0.id == downloadId}) else { return }
        
        switch mediaType {
        case .audio:
            self.lessons[index].isDownloadingAudio = false
            self.lessons[index].audioDownloadProgress = nil
        case .video:
            self.lessons[index].isDownloadingVideo = false
            self.lessons[index].videoDownloadProgress = nil
        }
        
        self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
        print("GemaraLessonsViewController downloadCompleted, downloadId: \(downloadId)")
    }
    
    func downloadProgress(downloadId: Int, progress: Float, mediaType: JTLessonMediaType) {
        guard let index = self.lessons.firstIndex(where: {$0.id == downloadId}) else { return }
        
        switch mediaType {
        case .audio:
            self.lessons[index].audioDownloadProgress = progress
        case .video:
            self.lessons[index].videoDownloadProgress = progress
        }
                
        // Update cell progress
        guard let cell = self.tableView.cellForRow(at:  IndexPath(row: index, section: 0)) as? LessonDownloadCellController else { return }
        cell.setLesson(self.lessons[index])
        if !isFirstLoading {
            cell.setEditingIfNeeded(lesson: self.lessons[index], isCurrentlyEditing: self.isCurrentlyEditing)
            self.view.layoutIfNeeded()
        }
    }
}
