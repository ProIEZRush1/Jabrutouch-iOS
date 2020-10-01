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
    private var lessonWatched: [JTLessonWatched] = []
    
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
        self.lessonWatched = UserDefaultsProvider.shared.lessonWatched
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
        
        let lesson = self.lessons[indexPath.row]
        cell.lessonNumber.text = "\(lesson.page)"
        cell.lessonLength.text = lesson.durationDisplay
        cell.delegate = self
        cell.selectedRow = indexPath.row
        Utils.setViewShape(view: cell.downloadButtonsContainerView, viewCornerRadius: 18)
        Utils.setViewShape(view: cell.cellView, viewCornerRadius: 18)
        let shadowOffset = CGSize(width: 0.0, height: 12)
        Utils.dropViewShadow(view: cell.downloadButtonsContainerView, shadowColor: Colors.shadowColor, shadowRadius: 36, shadowOffset: shadowOffset)
        
        cell.setLesson(lesson)
        cell.setDownloadModeForLesson(lesson, isCurrentlyEditing: self.isCurrentlyEditing)
        if !isFirstLoading {
            cell.setEditingIfNeeded(lesson: lesson, isCurrentlyEditing: self.isCurrentlyEditing)
            self.view.layoutIfNeeded()
        }
        if self.lessonWatched.count > 0 {
            for lessonWatched in self.lessonWatched {
                if lessonWatched.lessonId == lesson.id {
                    let count = lessonWatched.duration / Double(lesson.duration)
                    Utils.setProgressbar(count: count, view: cell.lessonProgressBar, rounded: false, cornerRadius: 0, bottomRadius: true)
                    break
                }
                Utils.setProgressbar(count: 0.0, view: cell.lessonProgressBar, rounded: false, cornerRadius: 0, bottomRadius: true)
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if isFirstLoading {
            if indexPath.row == tableView.numberOfRows(inSection: 0) - 1 {
                isFirstLoading = false
            }
        }
    }
        
    private func toggleEditingMode() {
        isCurrentlyEditing = !isCurrentlyEditing
        
        if isCurrentlyEditing {
            downloadButton.setImage(nil, for: .normal)
            downloadButton.setTitle(Strings.done, for: .normal)
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
        print("Cell Pressed")
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
            ContentRepository.shared.lessonStartedDownloading(lesson.id, mediaType: .video)
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
    
    //======================================================
    // MARK: - Player
    //======================================================
    
    private func playLesson(_ lesson: JTLesson, mediaType: JTLessonMediaType) {
        guard let sederId = self.sederId, let masechetId = self.masechetId else { return }
        let shouldDisplayDonationPopUp = mediaType == .audio ? !lesson.isAudioDownloaded : !lesson.isVideoDownloaded
        let playerVC = LessonPlayerViewController(lesson: lesson, mediaType: mediaType, sederId: sederId, masechetId: "\(masechetId)", chapter: nil, shouldDisplayDonationPopUp: shouldDisplayDonationPopUp)
        playerVC.modalPresentationStyle = .fullScreen
        playerVC.masechet = self.masechetName ?? ""
        if let lesson = lesson as? JTGemaraLesson {
            playerVC.daf = "\(lesson.page)"
        }
        self.present(playerVC, animated: true) {
            
        }
        
        if let gemaraLesson = lesson as? JTGemaraLesson, let masechetName = self.masechetName  {
            ContentRepository.shared.lessonWatched(gemaraLesson, masechetName: masechetName, masechetId: "\(masechetId)", sederId: sederId)
        }

    }
}

extension GemaraLessonsViewController: ContentRepositoryDownloadDelegate {
    func downloadCompleted(downloadId: Int, mediaType: JTLessonMediaType) {
        guard let index = self.lessons.firstIndex(where: {$0.id == downloadId}) else { return }
//        guard let sederId = self.sederId else { return }
//        guard let masechetId = self.masechetId else { return }
//
//        let lesson = self.lessons[index]
        switch mediaType {
        case .audio:
            self.lessons[index].isDownloadingAudio = false
            self.lessons[index].audioDownloadProgress = nil
        case .video:
            self.lessons[index].isDownloadingVideo = false
            self.lessons[index].videoDownloadProgress = nil
        }
        
        self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
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
        cell.setDownloadModeForLesson(self.lessons[index], isCurrentlyEditing: self.isCurrentlyEditing)
        if !isFirstLoading {
            cell.setEditingIfNeeded(lesson: self.lessons[index], isCurrentlyEditing: self.isCurrentlyEditing)
            self.view.layoutIfNeeded()
        }
        //        self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
    }
}

