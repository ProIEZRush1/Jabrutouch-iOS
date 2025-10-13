//בעזרת ה׳ החונן לאדם דעת
//  ContentRepository.swift
//  Jabrutouch
//
//  Created by Yoni Reiss on 14/08/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import Foundation

typealias SederId = String
typealias MasechetId = String
typealias Chapter = String
typealias LessonId = String

enum JTLessonMediaType: String {
    case audio = "audio"
    case video = "video"
}

protocol ContentRepositoryDownloadDelegate: class {
    func downloadCompleted(downloadId: Int, mediaType: JTLessonMediaType)
    func downloadProgress(downloadId: Int, progress: Float, mediaType: JTLessonMediaType)
}

enum ContentFileSource {
    case s3
    case vimeo
}

class ContentRepository {
    
    
    //========================================
    // MARK: - Properties
    //========================================
    private var lessonsInAudioDownload: [Int: Float] = [:]
    private var lessonsInVideoDownload: [Int: Float] = [:]
    private var shas: [JTSeder] = []
    
    private var gemaraLessons: [String:[String:JTGemaraLesson]] = [:]
    private var mishnaLessons: [String:[String:[String:JTMishnaLesson]]] = [:]
    
    private var downloadedGemaraLessons: [SederId:[MasechetId:Set<JTGemaraLesson>]] = [:]
    private var downloadedMasechetGemaraLessons: [MasechetId:Set<JTGemaraLesson>] = [:]
    private var downloadedMishnaLessons: [SederId:[MasechetId:[Chapter:Set<JTMishnaLesson>]]] = [:]
    private var downloadDelegates: [ContentRepositoryDownloadDelegate] = []
    
    var lastWatchedGemaraLessons: [JTGemaraLessonRecord] = []
    var lastWatchedMishnaLessons: [JTMishnaLessonRecord] = []
    
    private static var repository: ContentRepository?
    
    class var shared: ContentRepository {
        if self.repository == nil {
            self.repository = ContentRepository()
        }
        return self.repository!
    }
    
    var gemaraLessonsStorageUrl: URL? {
        guard let directoryUrl = FileDirectory.cache.url else { return nil }
        let filename = "gemaraLessons.json"
        let url = directoryUrl.appendingPathComponent(filename)
        return url
    }
    
    var mishnaLessonsStorageUrl: URL? {
        guard let directoryUrl = FileDirectory.cache.url else { return nil }
        let filename = "mishnaLessons.json"
        let url = directoryUrl.appendingPathComponent(filename)
        return url
    }
    
    var downloadedLessonsStorageUrl: URL? {
        // Changed from .cache to .documents for persistent storage
        // Registry file must be in Documents alongside the actual media files
        guard let directoryUrl = FileDirectory.documents.url else { return nil }
        let filename = "downloadedLessons.json"
        let url = directoryUrl.appendingPathComponent(filename)
        return url
    }
    
    var lastWatchedLessonsStorageUrl: URL? {
        guard let directoryUrl = FileDirectory.cache.url else { return nil }
        let filename = "lastWatchedLessons.json"
        let url = directoryUrl.appendingPathComponent(filename)
        return url
    }
    
    var shasStorageUrl: URL? {
        guard let directoryUrl = FileDirectory.cache.url else { return nil }
        let filename = "shas.json"
        let url = directoryUrl.appendingPathComponent(filename)
        return url
    }
    //========================================
    // MARK: - Initializer
    //========================================
    
    private init() {
        self.loadShas()
        self.loadDownloadedLessonsFromStorage()
        self.gemaraLessons = self.loadGemaraLessonsFromStorage()
        self.mishnaLessons = self.loadMishnaLessonsFromStorage()
        
        let lastWatchedLessons = self.loadLastWatchedLessonsStorage()
        self.lastWatchedGemaraLessons = lastWatchedLessons.gemaraLessons
        self.lastWatchedMishnaLessons = lastWatchedLessons.mishnaLessons
    }
    
    //========================================
    // MARK: - Delegates
    //========================================
    
    func addDelegate(_ delegate: ContentRepositoryDownloadDelegate) {
        self.downloadDelegates.append(delegate)
    }
    
    func removeDelegate(_ delegate: ContentRepositoryDownloadDelegate) {
        for i in 0..<self.downloadDelegates.count {
            if self.downloadDelegates[i] === delegate {
                self.downloadDelegates.remove(at: i)
                return
            }
        }
    }
    //========================================
    // MARK: - Main Methods
    //========================================
    
    func getLessonFromLocalStorage(withId id: Int) -> (lesson:JTLesson, sederId: String, masechetId: String, chapter: String?)? {
        for seder in self.getGemaraSeders() {
            for masechet in seder.masechtot {
                if let lessonsDict = self.gemaraLessons["\(masechet.masechetId)"] {
                    let lessons = Array(lessonsDict.values)
                    for lesson in lessons {
                        if lesson.id == id {
                            return (lesson, "\(seder.sederId)", "\(masechet.masechetId)", nil)
                        }
                    }
                }
            }
        }
        
        for seder in self.getMishnaSeders() {
            for masechetItem in seder.masechtot {
                if let masechet = self.getMishanMasechet(masechetId: masechetItem.masechetId) {
                    for chapter in masechet.chapters {
                        if let lessonsDict = self.mishnaLessons["\(masechet.masechetId)"]?["\(chapter.chapter)"] {
                            let lessons = Array(lessonsDict.values)
                            for lesson in lessons {
                                if lesson.id == id {
                                    return (lesson, "\(seder.sederId)", "\(masechet.masechetId)", chapter.chapter)
                                }
                            }
                        }
                    }
                }
            }
        }
        
        return nil
    }
    
    func getGemaraSeders()-> [JTGemaraSeder] {
        var seders: [JTGemaraSeder] = []
        for seder in self.shas {
            let masechtot = seder.masechtot.map{JTGemaraMasechetItem(name: $0.name, masechetId: $0.id, pagesCount: $0.pagesCount)}.filter{$0.pagesCount > 0}
            seders.append(JTGemaraSeder(sederId: seder.id, name: seder.name, masechtot: masechtot))
        }
        return seders
    }
    
    func getMishnaSeders()-> [JTMishnaSeder] {
        var seders: [JTMishnaSeder] = []
        for seder in self.shas {
            let masechtot = seder.masechtot.map{JTMishnaMasechetItem(name: $0.name, masechetId: $0.id, chaptersCount: $0.chaptersCount)}
            seders.append(JTMishnaSeder(name: seder.name, sederId: seder.id, masechtot: masechtot))
        }
        return seders
    }
    
    func getMishanMasechet(masechetId: Int)-> JTMishnaMasechet? {
        for seder in self.shas {
            for masechet in seder.masechtot {
                if masechet.id == masechetId {
                    let chapters = masechet.mishnaShiurimCountPerChapter.map{JTMishnaChapterItem(chapter: $0.key, lessonsCount: $0.value)}.sorted{$0.chapter < $1.chapter}
                    let mishnaMasechet = JTMishnaMasechet(masechetId: masechet.id, name: masechet.name, chapters: chapters)
                    return mishnaMasechet
                }
            }
        }
        return nil
    }
    
    func getGemaraLesson(masechetId: Int, page:Int, forceRefresh:Bool = true, completion: @escaping (_ result:
        Result<JTGemaraLesson,JTError>)->Void) {
        
        
        //        if let lessonsDict = self.gemaraLessons["\(masechetId)"] {
        //
        //        }
        
        self.loadGemaraLesson(masechetId: masechetId, page: page) { (result:Result<JTGemaraLesson, JTError>) in
            switch result {
            case .success(let lesson):
                DispatchQueue.main.async {
                    completion(.success(lesson))
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func getGemaraLessons(masechetId: Int, forceRefresh:Bool = true, completion: @escaping (_ result:
        Result<[JTGemaraLesson],JTError>)->Void) {
        
        
        if let lessonsDict = self.gemaraLessons["\(masechetId)"] {
            if forceRefresh == false {
                let lessons = Array(lessonsDict.values)
                completion(.success(lessons))
                return
            }
        }
        
        self.loadGemaraLessons(masechetId: masechetId) { (result:Result<[JTGemaraLesson], JTError>) in
            switch result {
            case .success(let lessons):
                let lessonsDict = Dictionary(uniqueKeysWithValues: lessons.map{("\($0.id)", $0)})
                self.gemaraLessons.updateValue(lessonsDict, forKey: "\(masechetId)")
                do {try self.updateGemaraLessonsStorage(content: self.gemaraLessons)}
                catch {}
                DispatchQueue.main.async {
                    completion(.success(lessons))
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
        
    }
    
    func getMishnaLesson(masechetId: Int, chapter: Int, mishna: Int, forceRefresh:Bool = true, completion: @escaping (_ result:
        Result<JTMishnaLesson,JTError>)->Void) {
        
        self.loadMishnaLesson(masechetId: masechetId, chapter: chapter, mishna: mishna) { (result:Result<JTMishnaLesson, JTError>) in
            switch result {
            case .success(let lesson):
                DispatchQueue.main.async {
                    completion(.success(lesson))
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func getMishnaLessons(masechetId: Int, chapter: Int, forceRefresh:Bool = true, completion: @escaping (_ result: Result<[JTMishnaLesson],JTError>)->Void) {
        
        if let lessonsDict = self.mishnaLessons["\(masechetId)"]?["\(chapter)"] {
            if forceRefresh == false {
                let lessons = Array(lessonsDict.values)
                completion(.success(lessons))
                return
            }
        }
        
        
        self.loadMishnaLessons(masechetId: masechetId, chapter: chapter) { (result:Result<[JTMishnaLesson], JTError>) in
            switch result {
            case .success(let lessons):
                let lessonsDict = Dictionary(uniqueKeysWithValues: lessons.map{("\($0.id)", $0)})
                if let _ = self.mishnaLessons["\(masechetId)"] {
                    self.mishnaLessons["\(masechetId)"]?.updateValue(lessonsDict, forKey: "\(chapter)")
                }
                else {
                    self.mishnaLessons.updateValue(["\(chapter)":lessonsDict], forKey: "\(masechetId)")
                }
                do {try self.updateMishnaLessonsStorage(content: self.mishnaLessons)}
                catch {}
                DispatchQueue.main.async {
                    completion(.success(lessons))
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
        self.loadGemaraLessons(masechetId: masechetId) { (result:Result<[JTGemaraLesson], JTError>) in
            
        }
        
    }
    //    func getMasechetDownloadedGemaraLessons() -> [JTMasechetDownloadedGemaraLessons] {
    //        var downloadedLessons:[JTMasechetDownloadedGemaraLessons] = []
    //        for (sederId,masechtotDict) in self.downloadedGemaraLessons {
    //            guard let masechet = self.getMasechetById(sederId: sederId, masechetId: <#T##String#>) else {continue}
    //            var lessons: [JTGemaraLessonRecord] = []
    //            for (masechetId, _lessons) in masechtotDict {
    //                guard let masechet = self.getMasechetById(sederId: sederId, masechetId: masechetId) else { continue }
    //                for lesson in _lessons {
    //                    lessons.append(JTGemaraLessonRecord(lesson: lesson, masechetName: masechet.name, masechetId: masechetId, sederId: sederId))
    //                }
    //            }
    //            downloadedLessons.append(JTMasechetDownloadedGemaraLessons(masechetName: "", records: lessons, order: masechet.order))
    //        }
    //        downloadedLessons.sort{$0.order < $1.order}
    //        return downloadedLessons
    //    }
    
    func getDownloadedGemaraLessons() -> [JTSederDownloadedGemaraLessons] {
        var downloadedLessons:[JTSederDownloadedGemaraLessons] = []
        for (sederId,masechtotDict) in self.downloadedGemaraLessons {
            guard let seder = self.getSederById(sederId: sederId) else {continue}
            var lessons: [JTGemaraLessonRecord] = []
            for (masechetId, _lessons) in masechtotDict {
                guard let masechet = self.getMasechetById(sederId: sederId, masechetId: masechetId) else { continue }
                for lesson in _lessons {
                    lessons.append(JTGemaraLessonRecord(lesson: lesson, masechetName: masechet.name, masechetId: masechetId, sederId: sederId))
                }
            }
            downloadedLessons.append(JTSederDownloadedGemaraLessons(sederId: sederId, sederName: seder.name, records: lessons, order: seder.order))
        }
        downloadedLessons.sort{$0.order < $1.order}
        return downloadedLessons
    }
    
    func getDownloadedMishnaLessons() -> [JTSederDownloadedMishnaLessons] {
        var downloadedLessons:[JTSederDownloadedMishnaLessons] = []
        for (sederId,masechtotDict) in self.downloadedMishnaLessons {
            guard let seder = self.getSederById(sederId: sederId) else {continue}
            var lessons: [JTMishnaLessonRecord] = []
            for (masechetId, chapters) in masechtotDict {
                guard let masechet = self.getMasechetById(sederId: sederId, masechetId: masechetId) else { continue }
                for (chapter,_lessons) in chapters {
                    for lesson in _lessons {
                        lessons.append(JTMishnaLessonRecord(lesson: lesson, masechetName: masechet.name, masechetId: masechetId, chapter: chapter, sederId: sederId))
                    }
                }
            }
            downloadedLessons.append(JTSederDownloadedMishnaLessons(sederId: sederId, sederName: seder.name, records: lessons, order: seder.order))
        }
        downloadedLessons.sort{$0.order < $1.order}
        return downloadedLessons
    }
    
    func getMasechetByName(_ masechetName: String) -> (masechet: JTMasechet, seder: JTSeder)? {
        for seder in self.shas {
            for masechet in seder.masechtot {
                if masechet.name == masechetName {
                    return (masechet, seder)
                }
            }
        }
        return nil
    }
    //========================================
    // MARK: - Watch History
    //========================================
    func lessonWatched(_ gemaraLesson: JTGemaraLesson, masechetName: String, masechetId: String, sederId: String) {
        let record = JTGemaraLessonRecord(lesson: gemaraLesson, masechetName: masechetName, masechetId: masechetId, sederId: sederId)
        if self.lastWatchedGemaraLessons.contains(record) == false {
            self.lastWatchedGemaraLessons.insert(record, at: 0)
            if self.lastWatchedGemaraLessons.count > 4 {
                self.lastWatchedGemaraLessons.removeLast()
            }
        }
        else {
            for i in 0..<self.lastWatchedGemaraLessons.count {
                if self.lastWatchedGemaraLessons[i] == record {
                    self.lastWatchedGemaraLessons.remove(at: i)
                    self.lastWatchedGemaraLessons.insert(record, at: 0)
                    break
                }
                else {
                    continue
                }
            }
        }
        
        self.updateLastWatchedLessonsStorage()
    }
    
    func lessonWatched(_ mishnaLesson: JTMishnaLesson, masechetName: String, masechetId: String, chapter: String, sederId: String) {
        let record = JTMishnaLessonRecord(lesson: mishnaLesson, masechetName: masechetName, masechetId: masechetId, chapter: chapter, sederId: sederId)
        
        if self.lastWatchedMishnaLessons.contains(record) == false {
            self.lastWatchedMishnaLessons.insert(record, at: 0)
            if self.lastWatchedMishnaLessons.count > 4 {
                self.lastWatchedMishnaLessons.removeLast()
            }
        }
        else {
            for i in 0..<self.lastWatchedMishnaLessons.count {
                if self.lastWatchedMishnaLessons[i] == record {
                    self.lastWatchedMishnaLessons.remove(at: i)
                    self.lastWatchedMishnaLessons.insert(record, at: 0)
                    break
                }
                else {
                    continue
                }
            }
        }
        
        self.updateLastWatchedLessonsStorage()
    }
    //========================================
    // MARK: - Download content methods
    //========================================
    func getLessonDownloadProgress(_ lessonId: Int, mediaType: JTLessonMediaType) -> Float? {
        switch mediaType {
        case .audio:
            return self.lessonsInAudioDownload[lessonId]
        case .video:
            return self.lessonsInVideoDownload[lessonId]
        }
        
    }
    func lessonStartedDownloading(_ lessonId: Int, mediaType: JTLessonMediaType) {
        switch mediaType {
        case .audio:
            self.lessonsInAudioDownload[lessonId] = 0.0
        case .video:
            self.lessonsInVideoDownload[lessonId] = 0.0
        }
        
    }
    
    func lessonEndedDownloading(_ lessonId: Int, mediaType: JTLessonMediaType) {
        switch mediaType {
        case .audio:
            self.lessonsInAudioDownload.removeValue(forKey: lessonId)
        case .video:
            self.lessonsInVideoDownload.removeValue(forKey: lessonId)
        }
        
    }
    
    func lessonDownloadProgress(_ lessonId: Int, progress: Float, mediaType: JTLessonMediaType) {
        switch mediaType {
        case .audio:
            self.lessonsInAudioDownload[lessonId] = progress
        case .video:
            self.lessonsInVideoDownload[lessonId] = progress
        }
        
    }
    func addLessonToDownloaded(_ lesson: JTGemaraLesson, sederId: String, masechetId: String) {
        if let _ = self.downloadedGemaraLessons[sederId] {
            if let _ = self.downloadedGemaraLessons[sederId]?[masechetId] {
                self.downloadedGemaraLessons[sederId]?[masechetId]?.insert(lesson)
            }
            else {
                self.downloadedGemaraLessons[sederId]?[masechetId] = [lesson]
            }
        }
        else {
            self.downloadedGemaraLessons[sederId] = [masechetId:[lesson]]
        }
        self.updateDownloadedLessonsStorage()
    }
    
    func addLessonToDownloaded(_ lesson: JTMishnaLesson, sederId: String, masechetId: String, chapter: String) {
        if let _ = self.downloadedMishnaLessons[sederId] {
            if let _ = self.downloadedMishnaLessons[sederId]?[masechetId] {
                if let _ = self.downloadedMishnaLessons[sederId]?[masechetId]?[chapter] {
                    self.downloadedMishnaLessons[sederId]?[masechetId]?[chapter]?.insert(lesson)
                }
                else {
                    self.downloadedMishnaLessons[sederId]?[masechetId]?[chapter] = [lesson]
                }
            }
            else {
                self.downloadedMishnaLessons[sederId]?[masechetId] = [chapter:[lesson]]
            }
        }
        else {
            self.downloadedMishnaLessons[sederId] = [masechetId:[chapter:[lesson]]]
        }
        self.updateDownloadedLessonsStorage()
    }
    
    func removeOldDownloadedFiles(){
        
        for (sederId, masechet) in downloadedGemaraLessons {
            for (masechetId, value) in masechet {
                for lesson in value {
                    
                    self.removedOldFiles(gemara: lesson, mishna: nil, sederId: sederId, masechetId: masechetId ,chapter: nil)
                    
                }
            }
        }
        
        for (sederId, masechet) in downloadedMishnaLessons {
            for (masechetId, chapter) in masechet {
                for (chapterId, value) in chapter {
                    for lesson in value {
                        
                        self.removedOldFiles(gemara: nil, mishna: lesson, sederId: sederId, masechetId: masechetId ,chapter: chapterId)
                    }
                }
            }
        }
    }
    
    func removedOldFiles(gemara: JTGemaraLesson?, mishna: JTMishnaLesson? , sederId: String, masechetId: String, chapter: String?){
        var lessonId = 0
        gemara?.id != nil ? lessonId = gemara!.id : mishna?.id != nil ? lessonId = mishna!.id : nil

        let fileManager = FileManager.default
        let files = ["\(lessonId)_aud.mp3", "\(lessonId)_vid.mp4", "\(lessonId)_text.pdf"]
        var isRemovedAll = [false, false]

        for (i, file) in files.enumerated() {
            // FIXED: Changed from .cache to .documents - files are now in Documents directory!
            guard let currentFile = FileDirectory.documents.url?.appendingPathComponent(file) else { return }
            do{
                if i == files.count-1 {
                    if !isRemovedAll.allSatisfy({$0}) {
                        return
                    }
                }
                let attributes = try fileManager.attributesOfItem(atPath: currentFile.path)

                if let creationDate = attributes[FileAttributeKey.creationDate] as? Date {

                    if Date().timeIntervalSince(creationDate) >= 60*60*24*30 {

                        FilesManagementProvider.shared.removeFiles(currentFile) { (url, result) in

                            switch result {
                            case .success:
                                i < files.count-1 ? isRemovedAll[i] = true :
                                    print("Success in removing file: \(url.absoluteString)")
                            case .failure(let error):
                                i < files.count-1 ? isRemovedAll[i] = false :
                                print("Failed removing file: \(url.absoluteString), with error: \(error)")
                            }}}}
            } catch {
                print("Error while enumerating files \(currentFile.path): \(error.localizedDescription)")
                i < files.count-1 ? isRemovedAll[i] = true : nil
            }
        }

        if isRemovedAll.allSatisfy({$0}) {
            if mishna != nil && chapter != nil {
                self.removeMishnaLessonFromArray(mishna!, sederId: sederId, masechetId: masechetId, chapter: chapter!)
            } else if gemara != nil{
                self.removeGemaraLessonFromArray(gemara!, sederId: sederId, masechetId: masechetId)
            }
            self.updateDownloadedLessonsStorage()
        }
    }
    
    func removeGemaraLessonFromArray(_ lesson: JTGemaraLesson, sederId: String, masechetId: String){
        self.downloadedGemaraLessons[sederId]?[masechetId]?.remove(lesson)
        if self.downloadedGemaraLessons[sederId]?[masechetId]?.count == 0 {
            self.downloadedGemaraLessons[sederId]?.removeValue(forKey: masechetId)
        }
        if self.downloadedGemaraLessons[sederId]?.count == 0 {
            self.downloadedGemaraLessons.removeValue(forKey: sederId)
        }
    }
    
    func removeMishnaLessonFromArray(_ lesson: JTMishnaLesson, sederId: String, masechetId: String, chapter: String) {
        self.downloadedMishnaLessons[sederId]?[masechetId]?[chapter]?.remove(lesson)
        if self.downloadedMishnaLessons[sederId]?[masechetId]?[chapter]?.count == 0 {
            self.downloadedMishnaLessons[sederId]?[masechetId]?.removeValue(forKey: chapter)
        }
        if self.downloadedMishnaLessons[sederId]?[masechetId]?.count == 0 {
            self.downloadedMishnaLessons[sederId]?.removeValue(forKey: masechetId)
        }
        if self.downloadedMishnaLessons[sederId]?.count == 0 {
            self.downloadedMishnaLessons.removeValue(forKey: sederId)
        }
    }
    
    func removeLessonFromDownloaded(_ lesson: JTGemaraLesson, sederId: String, masechetId: String) {
        self.downloadedGemaraLessons[sederId]?[masechetId]?.remove(lesson)
        if self.downloadedGemaraLessons[sederId]?[masechetId]?.count == 0 {
            self.downloadedGemaraLessons[sederId]?.removeValue(forKey: masechetId)
        }
        if self.downloadedGemaraLessons[sederId]?.count == 0 {
            self.downloadedGemaraLessons.removeValue(forKey: sederId)
        }
        let urls: [URL] = lesson.localFileUrls
        FilesManagementProvider.shared.removeFiles(urls) { (url, result) in
            switch result {
            case .success:
                self.updateDownloadedLessonsStorage()
                print("Success in removing file: \(url.absoluteString)")
            case .failure(let error):
                print("Failed removing file: \(url.absoluteString), with error: \(error)")
            }
        }
        
    }
    
    func removeLessonFromDownloaded(_ lesson: JTMishnaLesson, sederId: String, masechetId: String, chapter: String) {
        self.downloadedMishnaLessons[sederId]?[masechetId]?[chapter]?.remove(lesson)
        if self.downloadedMishnaLessons[sederId]?[masechetId]?[chapter]?.count == 0 {
            self.downloadedMishnaLessons[sederId]?[masechetId]?.removeValue(forKey: chapter)
        }
        if self.downloadedMishnaLessons[sederId]?[masechetId]?.count == 0 {
            self.downloadedMishnaLessons[sederId]?.removeValue(forKey: masechetId)
        }
        if self.downloadedMishnaLessons[sederId]?.count == 0 {
            self.downloadedMishnaLessons.removeValue(forKey: sederId)
        }
        let urls: [URL] = lesson.localFileUrls
        FilesManagementProvider.shared.removeFiles(urls){ (url, result) in
            switch result {
            case .success:
                self.updateDownloadedLessonsStorage()
                print("Success in removing file: \(url.absoluteString)")
            case .failure(let error):
                print("Failed removing file: \(url.absoluteString), with error: \(error)")
            }
        }
        
    }
    
    
    func downloadLesson(_ lesson: JTLesson, mediaType: JTLessonMediaType, delegate: DownloadTaskDelegate?) {
        let downloadTask = DownloadTask(id: lesson.id, delegate: delegate, mediaType: mediaType)
        switch mediaType {
        case .audio:
            downloadTask.filesToDownload.append((lesson.audioLink ?? "", .s3, lesson.audioLocalFileName))
        case .video:
            downloadTask.filesToDownload.append((lesson.videoLink ?? "", .vimeo, lesson.videoLocalFileName))
        }
        
        if lesson.isTextFileDownloaded == false {
            downloadTask.filesToDownload.append((lesson.textLink ?? "", .s3, lesson.textLocalFileName))
        }
        
        downloadTask.execute()
    }
    
    //========================================
    // MARK: - Stored content private methods
    //========================================
    
    private func updateGemaraLessonsStorage(content: [String:[String:JTGemaraLesson]]) throws {
        guard let url = self.gemaraLessonsStorageUrl else {
            throw JTError.invalidUrl
        }
        let mappedContent = content.mapValues{$0.mapValues{$0.values}}
        try self.saveContentToFile(content: mappedContent, url: url)
    }
    
    private func updateMishnaLessonsStorage(content: [String:[String:[String:JTMishnaLesson]]]) throws {
        guard let url = self.mishnaLessonsStorageUrl else {
            throw JTError.invalidUrl
        }
        let mappedContent = content.mapValues{$0.mapValues{$0.mapValues{$0.values}}}
        try self.saveContentToFile(content: mappedContent, url: url)
    }
    
    private func loadGemaraLessonsFromStorage() -> [String:[String:JTGemaraLesson]] {
        guard let url = self.gemaraLessonsStorageUrl else { return [:] }
        do {
            let contentString = try String(contentsOf: url)
            guard let content = Utils.convertStringToDictionary(contentString) as? [String:[String:[String:Any]]] else { return [:] }
            let mappedContent = content.mapValues{$0.compactMapValues{JTGemaraLesson(values: $0)}}
            return mappedContent
        }
        catch {
            return [:]
        }
    }
    
    private func loadMishnaLessonsFromStorage() -> [String:[String:[String: JTMishnaLesson]]] {
        guard let url = self.mishnaLessonsStorageUrl else { return [:] }
        do {
            let contentString = try String(contentsOf: url)
            guard let content = Utils.convertStringToDictionary(contentString) as? [String:[String:[String:[String:Any]]]] else { return [:] }
            let mappedContent = content.mapValues{$0.mapValues{$0.compactMapValues{JTMishnaLesson(values: $0)}}}
            return mappedContent
        }
        catch {
            return [:]
        }
    }
    
    private func loadDownloadedLessonsFromStorage() {
        guard let url = self.downloadedLessonsStorageUrl else {
            print("❌ Cannot load registry: Invalid storage URL")
            return
        }

        let fileManager = FileManager.default
        let fileExists = fileManager.fileExists(atPath: url.path)

        print("📖 Loading downloads registry from: \(url.path)")
        print("   File exists: \(fileExists)")

        if !fileExists {
            print("ℹ️  Registry file does not exist - no downloads to load")
            return
        }

        do {
            let contentString = try String(contentsOf: url)
            print("   File size: \(contentString.count) characters")

            guard let content = Utils.convertStringToDictionary(contentString) as? [String:Any] else {
                print("❌ Failed to parse registry JSON")
                print("   First 200 chars: \(String(contentString.prefix(200)))")
                return
            }

            print("   JSON parsed successfully")
            print("   Keys found: \(content.keys.joined(separator: ", "))")

            if let gemaraLessonsValues = content["gemara"] as? [SederId:[MasechetId:[[String:Any]]]]{
                let lessonsArray = gemaraLessonsValues.flatMap { $0.value.flatMap { $0.value } }
                let allLessons: [[String:Any]] = lessonsArray.flatMap { $0 }
                let initializedLessons: [JTGemaraLesson] = allLessons.compactMap{ JTGemaraLesson(values:$0) }
                let initializedCount = initializedLessons.count
                let failedCount = allLessons.count - initializedCount

                self.downloadedGemaraLessons = gemaraLessonsValues.mapValues{$0.mapValues{Set($0.compactMap{JTGemaraLesson(values:$0)})}}
                print("   ✅ Loaded \(initializedCount) Gemara lessons")
                if failedCount > 0 {
                    print("   ⚠️  \(failedCount) Gemara lessons failed to initialize")
                }
            } else {
                print("   ⚠️  'gemara' key not found or wrong type")
                if let gemaraData = content["gemara"] {
                    print("      Actual type: \(type(of: gemaraData))")
                }
            }

            if let mishnaLessonsValues = content["mishna"] as? [SederId:[MasechetId:[Chapter : [[String:Any]]]]]{
                let lessonsArray = mishnaLessonsValues.flatMap { $0.value.flatMap { $0.value.flatMap { $0.value } } }
                let allLessons: [[String:Any]] = lessonsArray.flatMap { $0 }
                let initializedLessons: [JTMishnaLesson] = allLessons.compactMap{ JTMishnaLesson(values:$0) }
                let initializedCount = initializedLessons.count
                let failedCount = allLessons.count - initializedCount

                self.downloadedMishnaLessons = mishnaLessonsValues.mapValues{$0.mapValues{$0.mapValues{Set($0.compactMap{JTMishnaLesson(values: $0)})}}}
                print("   ✅ Loaded \(initializedCount) Mishna lessons")
                if failedCount > 0 {
                    print("   ⚠️  \(failedCount) Mishna lessons failed to initialize")
                }
            } else {
                print("   ⚠️  'mishna' key not found or wrong type")
                if let mishnaData = content["mishna"] {
                    print("      Actual type: \(type(of: mishnaData))")
                }
            }

            let totalGemara = downloadedGemaraLessons.flatMap { $0.value.flatMap { $0.value } }.count
            let totalMishna = downloadedMishnaLessons.flatMap { $0.value.flatMap { $0.value.flatMap { $0.value } } }.count
            print("📖 Loaded downloads registry: \(totalGemara) Gemara + \(totalMishna) Mishna lessons")
        }
        catch {
            print("❌ ERROR loading downloads registry: \(error)")
            print("   File path: \(url.path)")
            print("   Error details: \(error.localizedDescription)")
        }
    }
    
    private func updateDownloadedLessonsStorage() {
        guard let url = self.downloadedLessonsStorageUrl else {
            print("❌ Cannot save registry: Invalid storage URL")
            return
        }

        let gemaraCount = downloadedGemaraLessons.flatMap { $0.value.flatMap { $0.value } }.count
        let mishnaCount = downloadedMishnaLessons.flatMap { $0.value.flatMap { $0.value.flatMap { $0.value } } }.count
        print("💾 Saving downloads registry: \(gemaraCount) Gemara + \(mishnaCount) Mishna lessons to \(url.path)")
        print("   Gemara structure: \(downloadedGemaraLessons.keys.count) seders")
        for (sederId, masechtot) in downloadedGemaraLessons {
            print("     Seder \(sederId): \(masechtot.keys.count) masechtot, \(masechtot.flatMap{$0.value}.count) lessons")
        }
        print("   Mishna structure: \(downloadedMishnaLessons.keys.count) seders")
        for (sederId, masechtot) in downloadedMishnaLessons {
            let lessonCount = masechtot.flatMap { $0.value.flatMap { $0.value } }.count
            print("     Seder \(sederId): \(masechtot.keys.count) masechtot, \(lessonCount) lessons")
        }

        let mappedGemaraLessons = self.downloadedGemaraLessons.mapValues{$0.mapValues{$0.map{$0.values}}}
        let mappedMishnaLessons = self.downloadedMishnaLessons.mapValues{$0.mapValues{$0.mapValues{$0.map{$0.values}}}}

        print("   📦 After mapping Gemara: \(mappedGemaraLessons.keys.count) seders")
        for (sederId, masechtot) in mappedGemaraLessons {
            let totalArrays = masechtot.values.reduce(0) { $0 + $1.count }
            print("     Seder \(sederId): \(masechtot.keys.count) masechtot, \(totalArrays) lesson dictionaries")
        }

        let content: [String : Any] = ["gemara": mappedGemaraLessons, "mishna": mappedMishnaLessons]

        // Log the content being serialized
        if let jsonData = try? JSONSerialization.data(withJSONObject: content, options: []),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            print("   📄 JSON content size: \(jsonString.count) characters")
            print("   📄 JSON preview (first 500 chars): \(String(jsonString.prefix(500)))")
        }

        do {
            try self.saveContentToFile(content: content, url: url)
            print("✅ Downloads registry saved successfully")
        }
        catch {
            print("❌ CRITICAL ERROR saving downloads registry: \(error)")
            print("   This means downloads will NOT persist after app restart!")
        }

    }
    
    private func updateLastWatchedLessonsStorage() {
        guard let url = self.lastWatchedLessonsStorageUrl else { return }
        let mappedGemaraLessons = self.lastWatchedGemaraLessons.map{$0.values}
        let mappedMishnaLessons = self.lastWatchedMishnaLessons.map{$0.values}
        let content: [String : Any] = ["gemara": mappedGemaraLessons, "mishna": mappedMishnaLessons]
        do {
            try self.saveContentToFile(content: content, url: url)
        }
        catch {
            
        }
        
    }
    
    private func updateShasStorage(shas: [JTSeder]) {
        guard let url = self.shasStorageUrl else { return }
        let content = ["shas":shas.map{$0.values}]
        do {
            try self.saveContentToFile(content: content, url: url)
        }
        catch {
            
        }
    }
    
    private func loadShasStorage() -> [JTSeder] {
        guard let url = self.shasStorageUrl else { return [] }
        do {
            let contentString = try String(contentsOf: url)
            guard let content = Utils.convertStringToDictionary(contentString) as? [String:Any] else { return [] }
            guard let shasValues = content["shas"] as? [[String:Any]] else { return [] }
            let shas = shasValues.compactMap{JTSeder(values: $0)}
            return shas
        }
        catch {
            return []
        }
        
    }
    
    private func loadLastWatchedLessonsStorage() -> (gemaraLessons: [JTGemaraLessonRecord], mishnaLessons: [JTMishnaLessonRecord]) {
        guard let url = self.lastWatchedLessonsStorageUrl else { return ([],[]) }
        do {
            let contentString = try String(contentsOf: url)
            guard let content = Utils.convertStringToDictionary(contentString) as? [String:Any] else { return ([],[]) }
            var gemaraLessons: [JTGemaraLessonRecord] = []
            var mishnaLessons: [JTMishnaLessonRecord] = []
            if let gemaraLessonsValues = content["gemara"] as? [[String:Any]] {
                gemaraLessons = gemaraLessonsValues.compactMap{JTGemaraLessonRecord(values: $0)}
            }
            if let mishnaLessonsValues = content["mishna"] as? [[String:Any]] {
                mishnaLessons = mishnaLessonsValues.compactMap{JTMishnaLessonRecord(values: $0)}
            }
            return (gemaraLessons, mishnaLessons)
        }
        catch {
            return ([],[])
        }
        
    }
    //========================================
    // MARK: - Private methods
    //========================================
    
    
    private func loadShas() {
        API.getMasechtot { (result: APIResult<GetMasechtotResponse>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self.shas = response.shas
                    self.updateShasStorage(shas: response.shas)
                    NotificationCenter.default.post(name: .shasLoaded, object: nil, userInfo: nil)
                case .failure(let error):
                    self.shas = self.loadShasStorage()
                    let userInfo: [String:Any] = ["errorMessage": error.message]
                    NotificationCenter.default.post(name: .failedLoadingShas, object: nil, userInfo: userInfo)
                    break
                }
            }            
        }
    }
    
    private func loadGemaraLessons(masechetId: Int, completion: @escaping (_ result: Result<[JTGemaraLesson],JTError>)->Void) {
        guard let authToken = UserDefaultsProvider.shared.currentUser?.token else {
            completion(.failure(.authTokenMissing))
            return
        }
        API.getGemarahMasechetLessons(masechetId: masechetId, authToken: authToken) { (result: APIResult<GetGemaraLessonsResponse>) in
            switch result {
            case .success(let response):
                completion(.success(response.lessons))
            case .failure(let error):
                switch error {
                case .invalidToken:
                    self.logOut()
                default:
                    completion(.failure(error))
                }
            }
        }
    }
    
    private func loadGemaraLesson(masechetId: Int, page: Int, completion: @escaping (_ result: Result<JTGemaraLesson,JTError>)->Void) {
        guard let authToken = UserDefaultsProvider.shared.currentUser?.token else {
            completion(.failure(.authTokenMissing))
            return
        }
        API.getGemarahLesson(masechetId: masechetId, page: page, authToken: authToken) { (result: APIResult<GetGemaraLessonResponse>) in
            switch result {
            case .success(let response):
                completion(.success(response.lesson))
            case .failure(let error):
                switch error {
                case .invalidToken:
                    self.logOut()
                default:
                    completion(.failure(error))
                }
            }
        }
    }
    
    private func loadMishnaLesson(masechetId: Int, chapter: Int, mishna: Int, completion: @escaping (_ result: Result<JTMishnaLesson,JTError>)->Void) {
        guard let authToken = UserDefaultsProvider.shared.currentUser?.token else {
            completion(.failure(.authTokenMissing))
            return
        }
        API.getMishnaLesson(masechetId: masechetId, chapter: chapter, mishna: mishna, authToken: authToken) { (result: APIResult<GetMishnaLessonResponse>) in
            switch result {
            case .success(let response):
                completion(.success(response.lesson))
            case .failure(let error):
                switch error {
                case .invalidToken:
                    self.logOut()
                default:
                    completion(.failure(error))
                }
            }
        }
    }
    
    private func loadMishnaLessons(masechetId: Int, chapter: Int, completion: @escaping (_ result: Result<[JTMishnaLesson],JTError>)->Void) {
        guard let authToken = UserDefaultsProvider.shared.currentUser?.token else {
            completion(.failure(.authTokenMissing))
            return
        }
        API.getMishnaLessons(masechetId: masechetId, chapter: chapter, authToken: authToken) { (result:APIResult<GetMishnaLessonsResponse>) in
            switch result {
            case .success(let response):
                completion(.success(response.lessons))
            case .failure(let error):
                switch error {
                case .invalidToken:
                    self.logOut()
                default:
                    completion(.failure(error))
                }
            }
        }
    }
    
    private func saveContentToFile(content: [String:Any], url: URL) throws{
        guard let contentString = Utils.convertDictionaryToString(content) else {
            throw JTError.unableToConvertDictionaryToString
        }
        guard let data = contentString.data(using: .utf8) else {
            throw JTError.unableToConvertStringToData
        }
        do {
            try FilesManagementProvider.shared.overwriteFile(path:url, data: data)
        }
        catch let error {
            throw error
        }
    }
    
    private func getSederById(sederId: String) -> JTSeder? {
        for seder in self.shas {
            if "\(seder.id)" == sederId {
                return seder
            }
        }
        return nil
    }
    
    private func getMasechetById(sederId: String, masechetId: String) -> JTMasechet? {
        for seder in self.shas {
            for masechet in seder.masechtot {
                if "\(masechet.id)" == masechetId && "\(seder.id)" == sederId {
                    return masechet
                }
            }
        }
        return nil
    }
}

extension ContentRepository: DownloadTaskDelegate {
    
    func downloadCompleted(downloadId: Int, mediaType: JTLessonMediaType, success: Bool) {
        self.lessonEndedDownloading(downloadId, mediaType: mediaType)
        if let (lesson,sederId,masechetId,chapter) = self.getLessonFromLocalStorage(withId: downloadId) {
            switch mediaType {
            case .audio:
                lesson.audioDownloadProgress = 0.0
                lesson.isDownloadingAudio = false
            case .video:
                lesson.videoDownloadProgress = 0.0
                lesson.isDownloadingVideo = false
            }
            if success {
                if let gemaraLesson = lesson as? JTGemaraLesson {
                    self.addLessonToDownloaded(gemaraLesson, sederId: sederId, masechetId: masechetId)
                }
                if let mishnaLesson = lesson as? JTMishnaLesson, let _chapter = chapter {
                    self.addLessonToDownloaded(mishnaLesson, sederId: sederId, masechetId: masechetId, chapter: _chapter)
                }
                self.getLessonDonation(lesson: lesson)
            } else {
                let VC = appDelegate.topmostViewController
                Utils.showAlertMessage("Error al descargar la lección", viewControler: VC!)
            }
        }
        
        DispatchQueue.main.async {
            for delegate in self.downloadDelegates {
                delegate.downloadCompleted(downloadId: downloadId, mediaType: mediaType)
            }
        }
    }
    
    func getLessonDonation(lesson: JTLesson){
        var isGemara = false
        if let _ = lesson as? JTGemaraLesson {isGemara = true}
        DonationManager.shared.getDonationAllertData(lessonId:lesson.id, isGemara: isGemara, downloaded: true) { (result) in
            switch result {
            case .success(var response):
                if response.donatedBy.count > 0 {
                    response.isgemara = isGemara
                    response.lessId = lesson.id
                    UserDefaultsProvider.shared.lessonDonation?.append(response)
                } else {
                    
                }
                
            case .failure( let error):
                print(error)
            }
        }
    }
    
    func downloadProgress(downloadId: Int, progress: Float, mediaType: JTLessonMediaType) {        
        self.lessonDownloadProgress(downloadId, progress: progress, mediaType: mediaType)
        
        DispatchQueue.main.async {
            for delegate in self.downloadDelegates {
                delegate.downloadProgress(downloadId: downloadId, progress: progress, mediaType: mediaType )
            }
        }
    }
    
    func logOut() {
        let titel = "Token inválido"
        let message = "Debes iniciar sesión de nuevo"
        let vc = appDelegate.topmostViewController
        DispatchQueue.main.async {
            Utils.showAlertMessage(message, title: titel, viewControler: vc!) { (action) in
                LoginManager.shared.signOut {
                    let signInViewController = Storyboards.SignIn.signInViewController
                    appDelegate.setRootViewController(viewController: signInViewController, animated: true)
                }
            }
        }
    }

    //========================================
    // MARK: - Storage Migration
    //========================================

    /**
     Migrates the downloads registry file from Caches to Documents
     This is critical because the registry file must be in the same persistent storage as the media files
     */
    private func migrateRegistryFile() {
        let fileManager = FileManager.default

        guard let cacheURL = FileDirectory.cache.url,
              let documentsURL = FileDirectory.documents.url else {
            print("❌ Registry migration failed: Could not access directories")
            return
        }

        let oldRegistryPath = cacheURL.appendingPathComponent("downloadedLessons.json")
        let newRegistryPath = documentsURL.appendingPathComponent("downloadedLessons.json")

        // Check if old registry exists in Caches
        if fileManager.fileExists(atPath: oldRegistryPath.path) {
            // Check if new registry already exists in Documents
            if fileManager.fileExists(atPath: newRegistryPath.path) {
                print("📋 Registry already exists in Documents, removing old cache version")
                try? fileManager.removeItem(at: oldRegistryPath)
            } else {
                // Move registry from Caches to Documents
                do {
                    try fileManager.moveItem(at: oldRegistryPath, to: newRegistryPath)
                    print("✅ Migrated registry file from Caches to Documents")
                } catch {
                    print("❌ Error migrating registry file: \(error)")
                    // If move fails, try copying
                    do {
                        try fileManager.copyItem(at: oldRegistryPath, to: newRegistryPath)
                        try? fileManager.removeItem(at: oldRegistryPath)
                        print("✅ Copied registry file from Caches to Documents")
                    } catch {
                        print("❌ Error copying registry file: \(error)")
                    }
                }
            }
        } else {
            print("ℹ️  No registry file found in Caches (may already be in Documents or no downloads exist)")
        }
    }

    /**
     Migrates downloaded lesson files from ~/Library/Caches/ to ~/Library/Documents/
     This is a one-time migration needed because:
     - Old downloads were saved to Caches (can be deleted by iOS)
     - New code expects files in Documents (persistent storage)
     - Without migration, lessons show as downloaded but files are not found

     Strategy:
     1. Check if migration already completed (UserDefaults flag)
     2. Migrate registry file from Caches to Documents if needed
     3. Get list of all downloaded lessons from registry
     4. For each lesson, check if files exist in Caches but not in Documents
     5. Move files from Caches to Documents
     6. Clean up orphaned registry entries (lessons with no files in either location)
     7. Set migration completed flag
     */
    func migrateDownloadsFromCachesToDocuments() {
        // Check if migration already completed
        if UserDefaultsProvider.shared.hasCompletedDownloadsCacheToDocumentsMigration {
            print("✅ Downloads migration already completed, skipping")
            return
        }

        print("🔄 Starting downloads migration from Caches to Documents...")

        // STEP 1: Migrate the registry file itself from Caches to Documents
        migrateRegistryFile()

        guard let cacheURL = FileDirectory.cache.url,
              let documentsURL = FileDirectory.documents.url else {
            print("❌ Migration failed: Could not access directories")
            return
        }

        var migratedCount = 0
        var deletedCount = 0
        var errorCount = 0
        var orphanedLessons: [(lesson: JTLesson, sederId: String, masechetId: String, chapter: String?)] = []

        // Process Gemara downloads
        for (sederId, masechtotDict) in downloadedGemaraLessons {
            for (masechetId, lessons) in masechtotDict {
                for lesson in lessons {
                    let result = migrateLessonFiles(lesson, cacheURL: cacheURL, documentsURL: documentsURL)

                    switch result {
                    case .migrated:
                        migratedCount += 1
                    case .alreadyInDocuments:
                        break // Already migrated, no action needed
                    case .deleted:
                        deletedCount += 1
                    case .orphaned:
                        orphanedLessons.append((lesson, sederId, masechetId, nil))
                    case .error:
                        errorCount += 1
                    }
                }
            }
        }

        // Process Mishna downloads
        for (sederId, masechtotDict) in downloadedMishnaLessons {
            for (masechetId, chaptersDict) in masechtotDict {
                for (chapter, lessons) in chaptersDict {
                    for lesson in lessons {
                        let result = migrateLessonFiles(lesson, cacheURL: cacheURL, documentsURL: documentsURL)

                        switch result {
                        case .migrated:
                            migratedCount += 1
                        case .alreadyInDocuments:
                            break
                        case .deleted:
                            deletedCount += 1
                        case .orphaned:
                            orphanedLessons.append((lesson, sederId, masechetId, chapter))
                        case .error:
                            errorCount += 1
                        }
                    }
                }
            }
        }

        // Clean up orphaned registry entries (lessons with no files anywhere)
        if !orphanedLessons.isEmpty {
            print("🧹 Cleaning up \(orphanedLessons.count) orphaned download entries...")
            for item in orphanedLessons {
                if let gemaraLesson = item.lesson as? JTGemaraLesson {
                    removeGemaraLessonFromArray(gemaraLesson, sederId: item.sederId, masechetId: item.masechetId)
                } else if let mishnaLesson = item.lesson as? JTMishnaLesson, let chapter = item.chapter {
                    removeMishnaLessonFromArray(mishnaLesson, sederId: item.sederId, masechetId: item.masechetId, chapter: chapter)
                }
            }
            updateDownloadedLessonsStorage()
        }

        // Mark migration as completed
        UserDefaultsProvider.shared.hasCompletedDownloadsCacheToDocumentsMigration = true

        print("✅ Migration completed:")
        print("   📦 Migrated: \(migratedCount) lessons")
        print("   🗑️  Deleted duplicates: \(deletedCount) lessons")
        print("   🧹 Cleaned orphans: \(orphanedLessons.count) entries")
        if errorCount > 0 {
            print("   ⚠️  Errors: \(errorCount) lessons")
        }
    }

    private enum MigrationResult {
        case migrated           // Moved from Caches to Documents
        case alreadyInDocuments // File already in Documents, deleted from Caches
        case deleted            // Duplicate found, deleted from Caches
        case orphaned           // No files found in either location
        case error              // Error during migration
    }

    private func migrateLessonFiles(_ lesson: JTLesson, cacheURL: URL, documentsURL: URL) -> MigrationResult {
        let fileManager = FileManager.default
        var hasAnyFile = false
        var migrationOccurred = false

        // Check audio file
        if lesson.audioLink != nil {
            let cacheAudioPath = cacheURL.appendingPathComponent(lesson.audioLocalFileName).path
            let documentsAudioPath = documentsURL.appendingPathComponent(lesson.audioLocalFileName).path

            if fileManager.fileExists(atPath: documentsAudioPath) {
                // File already in Documents - delete from Caches if exists
                hasAnyFile = true
                if fileManager.fileExists(atPath: cacheAudioPath) {
                    try? fileManager.removeItem(atPath: cacheAudioPath)
                    print("🗑️  Deleted duplicate audio from Caches: \(lesson.audioLocalFileName)")
                }
            } else if fileManager.fileExists(atPath: cacheAudioPath) {
                // Move from Caches to Documents
                do {
                    try fileManager.moveItem(atPath: cacheAudioPath, toPath: documentsAudioPath)
                    hasAnyFile = true
                    migrationOccurred = true
                    print("📦 Migrated audio: \(lesson.audioLocalFileName)")
                } catch {
                    print("❌ Error migrating audio \(lesson.audioLocalFileName): \(error)")
                    return .error
                }
            }
        }

        // Check video file
        if lesson.videoLink != nil {
            let cacheVideoPath = cacheURL.appendingPathComponent(lesson.videoLocalFileName).path
            let documentsVideoPath = documentsURL.appendingPathComponent(lesson.videoLocalFileName).path

            if fileManager.fileExists(atPath: documentsVideoPath) {
                hasAnyFile = true
                if fileManager.fileExists(atPath: cacheVideoPath) {
                    try? fileManager.removeItem(atPath: cacheVideoPath)
                    print("🗑️  Deleted duplicate video from Caches: \(lesson.videoLocalFileName)")
                }
            } else if fileManager.fileExists(atPath: cacheVideoPath) {
                do {
                    try fileManager.moveItem(atPath: cacheVideoPath, toPath: documentsVideoPath)
                    hasAnyFile = true
                    migrationOccurred = true
                    print("📦 Migrated video: \(lesson.videoLocalFileName)")
                } catch {
                    print("❌ Error migrating video \(lesson.videoLocalFileName): \(error)")
                    return .error
                }
            }
        }

        // Check PDF/text file
        if lesson.textLink != nil {
            let cacheTextPath = cacheURL.appendingPathComponent(lesson.textLocalFileName).path
            let documentsTextPath = documentsURL.appendingPathComponent(lesson.textLocalFileName).path

            if fileManager.fileExists(atPath: documentsTextPath) {
                hasAnyFile = true
                if fileManager.fileExists(atPath: cacheTextPath) {
                    try? fileManager.removeItem(atPath: cacheTextPath)
                    print("🗑️  Deleted duplicate PDF from Caches: \(lesson.textLocalFileName)")
                }
            } else if fileManager.fileExists(atPath: cacheTextPath) {
                do {
                    try fileManager.moveItem(atPath: cacheTextPath, toPath: documentsTextPath)
                    hasAnyFile = true
                    migrationOccurred = true
                    print("📦 Migrated PDF: \(lesson.textLocalFileName)")
                } catch {
                    print("❌ Error migrating PDF \(lesson.textLocalFileName): \(error)")
                    return .error
                }
            }
        }

        // Determine result
        if !hasAnyFile {
            return .orphaned
        } else if migrationOccurred {
            return .migrated
        } else {
            return .alreadyInDocuments
        }
    }

    /**
     Reloads the downloads list from storage
     This is useful after migration to refresh the in-memory state
     */
    func reloadDownloadsFromStorage() {
        print("🔄 Reloading downloads from storage...")
        loadDownloadedLessonsFromStorage()
        print("✅ Downloads reloaded from storage")
    }

    /**
     Manually refresh the downloads list by removing orphaned entries
     This is a user-triggered cleanup that removes download registry entries
     for lessons where the actual files don't exist in the Documents directory

     Useful as a manual fix if migration didn't work correctly or if users
     manually deleted files outside the app
     */
    func refreshDownloadsList() {
        print("🔄 Refreshing downloads list...")

        guard let documentsURL = FileDirectory.documents.url else {
            print("❌ Could not access Documents directory")
            return
        }

        let fileManager = FileManager.default
        var orphanedGemara: [(lesson: JTGemaraLesson, sederId: String, masechetId: String)] = []
        var orphanedMishna: [(lesson: JTMishnaLesson, sederId: String, masechetId: String, chapter: String)] = []

        // Check Gemara downloads
        for (sederId, masechtotDict) in downloadedGemaraLessons {
            for (masechetId, lessons) in masechtotDict {
                for lesson in lessons {
                    var hasAnyFile = false

                    // Check if ANY of the lesson's files exist
                    if lesson.audioLink != nil {
                        let audioPath = documentsURL.appendingPathComponent(lesson.audioLocalFileName).path
                        if fileManager.fileExists(atPath: audioPath) {
                            hasAnyFile = true
                        }
                    }

                    if lesson.videoLink != nil {
                        let videoPath = documentsURL.appendingPathComponent(lesson.videoLocalFileName).path
                        if fileManager.fileExists(atPath: videoPath) {
                            hasAnyFile = true
                        }
                    }

                    if lesson.textLink != nil {
                        let textPath = documentsURL.appendingPathComponent(lesson.textLocalFileName).path
                        if fileManager.fileExists(atPath: textPath) {
                            hasAnyFile = true
                        }
                    }

                    if !hasAnyFile {
                        orphanedGemara.append((lesson, sederId, masechetId))
                        print("🧹 Found orphaned Gemara lesson: \(lesson.id)")
                    }
                }
            }
        }

        // Check Mishna downloads
        for (sederId, masechtotDict) in downloadedMishnaLessons {
            for (masechetId, chaptersDict) in masechtotDict {
                for (chapter, lessons) in chaptersDict {
                    for lesson in lessons {
                        var hasAnyFile = false

                        if lesson.audioLink != nil {
                            let audioPath = documentsURL.appendingPathComponent(lesson.audioLocalFileName).path
                            if fileManager.fileExists(atPath: audioPath) {
                                hasAnyFile = true
                            }
                        }

                        if lesson.videoLink != nil {
                            let videoPath = documentsURL.appendingPathComponent(lesson.videoLocalFileName).path
                            if fileManager.fileExists(atPath: videoPath) {
                                hasAnyFile = true
                            }
                        }

                        if lesson.textLink != nil {
                            let textPath = documentsURL.appendingPathComponent(lesson.textLocalFileName).path
                            if fileManager.fileExists(atPath: textPath) {
                                hasAnyFile = true
                            }
                        }

                        if !hasAnyFile {
                            orphanedMishna.append((lesson, sederId, masechetId, chapter))
                            print("🧹 Found orphaned Mishna lesson: \(lesson.id)")
                        }
                    }
                }
            }
        }

        // Remove orphaned entries
        for item in orphanedGemara {
            removeGemaraLessonFromArray(item.lesson, sederId: item.sederId, masechetId: item.masechetId)
        }

        for item in orphanedMishna {
            removeMishnaLessonFromArray(item.lesson, sederId: item.sederId, masechetId: item.masechetId, chapter: item.chapter)
        }

        if !orphanedGemara.isEmpty || !orphanedMishna.isEmpty {
            updateDownloadedLessonsStorage()
            print("✅ Removed \(orphanedGemara.count + orphanedMishna.count) orphaned download entries")
        } else {
            print("✅ No orphaned downloads found")
        }

        // PHASE 2: Discover unregistered files and add them to registry
        let discoveredCount = discoverAndRegisterUnregisteredFiles()
        if discoveredCount > 0 {
            print("✅ Added \(discoveredCount) discovered files to registry")
        }
    }

    /**
     Discovers downloaded files that exist in Documents but aren't in the registry
     Attempts to look up full lesson data from cached storage and add to registry
     This fixes the issue where download icons show but lessons don't appear in Downloads screen
     */
    private func discoverAndRegisterUnregisteredFiles() -> Int {
        print("🔍 Scanning for unregistered downloaded files...")

        guard let documentsURL = FileDirectory.documents.url else {
            print("❌ Could not access Documents directory")
            return 0
        }

        let fileManager = FileManager.default
        guard let files = try? fileManager.contentsOfDirectory(atPath: documentsURL.path) else {
            print("❌ Could not list files in Documents directory")
            return 0
        }

        // Find audio/video files (excluding PDFs as they're supplementary)
        let lessonFiles = files.filter { $0.hasSuffix("_aud.mp3") || $0.hasSuffix("_vid.mp4") }

        var addedCount = 0
        for filename in lessonFiles {
            // Extract lesson ID from filename (format: {lessonId}_aud.mp3 or {lessonId}_vid.mp4)
            let components = filename.components(separatedBy: "_")
            guard let lessonIdString = components.first,
                  let lessonId = Int(lessonIdString) else {
                print("⚠️  Could not extract lesson ID from filename: \(filename)")
                continue
            }

            // Check if already in registry
            if isLessonInRegistry(lessonId) {
                continue // Already registered, skip
            }

            // Try to get full lesson data from cached storage (gemaraLessons or mishnaLessons)
            if let (lesson, sederId, masechetId, chapter) = getLessonFromLocalStorage(withId: lessonId) {
                // Verify the file actually exists before adding to registry
                let fileURL = documentsURL.appendingPathComponent(filename)
                guard fileManager.fileExists(atPath: fileURL.path) else {
                    continue
                }

                // Add to registry with full metadata
                if let gemaraLesson = lesson as? JTGemaraLesson {
                    addLessonToDownloaded(gemaraLesson, sederId: sederId, masechetId: masechetId)
                    addedCount += 1
                    print("📥 Discovered unregistered Gemara file: \(filename) (Lesson ID: \(lessonId))")
                } else if let mishnaLesson = lesson as? JTMishnaLesson, let chapterValue = chapter {
                    addLessonToDownloaded(mishnaLesson, sederId: sederId, masechetId: masechetId, chapter: chapterValue)
                    addedCount += 1
                    print("📥 Discovered unregistered Mishna file: \(filename) (Lesson ID: \(lessonId))")
                }
            } else {
                print("⚠️  Found file without cached lesson metadata: \(filename) (Lesson ID: \(lessonId))")
                print("    This lesson may need to be re-downloaded or the lesson cache needs to be refreshed")
            }
        }

        return addedCount
    }

    /**
     Checks if a lesson with the given ID is already in the downloads registry
     Returns true if found in either Gemara or Mishna registry
     */
    private func isLessonInRegistry(_ lessonId: Int) -> Bool {
        // Check Gemara registry
        for (_, masechtotDict) in downloadedGemaraLessons {
            for (_, lessons) in masechtotDict {
                if lessons.contains(where: { $0.id == lessonId }) {
                    return true
                }
            }
        }

        // Check Mishna registry
        for (_, masechtotDict) in downloadedMishnaLessons {
            for (_, chaptersDict) in masechtotDict {
                for (_, lessons) in chaptersDict {
                    if lessons.contains(where: { $0.id == lessonId }) {
                        return true
                    }
                }
            }
        }

        return false
    }
}
