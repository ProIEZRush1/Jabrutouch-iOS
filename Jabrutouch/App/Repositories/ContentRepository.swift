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

enum JTLessonMediaType {
    case audio
    case video
}

protocol ContentRepositoryDownloadDelegate: class {
    func downloadCompleted(downloadId: Int)
    func downloadProgress(downloadId: Int, progress: Float)
}

enum ContentFileSource {
    case s3
    case vimeo
}

class ContentRepository {
    
    
    //========================================
    // MARK: - Properties
    //========================================
    private var lessonsInDownload: [Int: Float] = [:]
    private var shas: [JTSeder] = []
    private var gemaraLessons: [String:[String:JTGemaraLesson]] = [:]
    private var mishnaLessons: [String:[String:[String:JTMishnaLesson]]] = [:]
    private var downloadedGemaraLessons: [SederId:[MasechetId:Set<JTGemaraLesson>]] = [:]
    private var downloadedMishnaLessons: [SederId:[MasechetId:[Chapter:Set<JTMishnaLesson>]]] = [:]
    private var delegates: [ContentRepositoryDownloadDelegate] = []
    
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
        guard let directoryUrl = FileDirectory.cache.url else { return nil }
        let filename = "downloadedLessons.json"
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
    }
    
    //========================================
    // MARK: - Delegates
    //========================================
    
    func addDelegate(_ delegate: ContentRepositoryDownloadDelegate) {
        self.delegates.append(delegate)
    }
    
    func removeDelegate(_ delegate: ContentRepositoryDownloadDelegate) {
        for i in 0..<self.delegates.count {
            if self.delegates[i] === delegate {
                self.delegates.remove(at: i)
                return
            }
        }
    }
    //========================================
    // MARK: - Main Methods
    //========================================
    
    func getGemaraSeders()-> [JTGemaraSeder] {
        var seders: [JTGemaraSeder] = []
        for seder in self.shas {
            let masechtot = seder.masechtot.map{JTGemaraMasechetItem(name: $0.name, masechetId: $0.id, pagesCount: $0.pagesCount)}.filter{$0.pagesCount > 0}
            seders.append(JTGemaraSeder(sederId: seder.id, name: seder.name, masechtot: masechtot))
        }
        return seders
    }
    
    func getMishanSeders()-> [JTMishnaSeder] {
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
    
    func getDownloadedGemaraLessons() -> [JTSederDownloadedGemaraLessons] {
        var downloadedLessons:[JTSederDownloadedGemaraLessons] = []
        for (sederId,masechtotDict) in self.downloadedGemaraLessons {
            guard let seder = self.getSederById(sederId: sederId) else {continue}
            var lessons: [JTDownloadedGemaraLesson] = []
            for (masechetId, _lessons) in masechtotDict {
                guard let masechet = self.getMasechetById(sederId: sederId, masechetId: masechetId) else { continue }
                for lesson in _lessons {
                    lessons.append(JTDownloadedGemaraLesson(lesson: lesson, masechetName: masechet.name, masechetId: masechetId))
                }
            }
            downloadedLessons.append(JTSederDownloadedGemaraLessons(sederId: sederId, sederName: seder.name, lessons: lessons, order: seder.order))
        }
        downloadedLessons.sort{$0.order < $1.order}
        return downloadedLessons
    }
    
    func getDownloadedMishnaLessons() -> [JTSederDownloadedMishnaLessons] {
        var downloadedLessons:[JTSederDownloadedMishnaLessons] = []
        for (sederId,masechtotDict) in self.downloadedMishnaLessons {
            guard let seder = self.getSederById(sederId: sederId) else {continue}
            var lessons: [JTDownloadedMishnaLesson] = []
            for (masechetId, chapters) in masechtotDict {
                guard let masechet = self.getMasechetById(sederId: sederId, masechetId: masechetId) else { continue }
                for (chapter,_lessons) in chapters {
                    for lesson in _lessons {
                        lessons.append(JTDownloadedMishnaLesson(lesson: lesson, masechetName: masechet.name, masechetId: masechetId, chapter: chapter))
                    }
                }
            }
            downloadedLessons.append(JTSederDownloadedMishnaLessons(sederId: sederId, sederName: seder.name, lessons: lessons, order: seder.order))
        }
        downloadedLessons.sort{$0.order < $1.order}
        return downloadedLessons
    }
    //========================================
    // MARK: - Download content methods
    //========================================
    func getLessonDownloadProgress(_ lessonId: Int) -> Float? {
        return self.lessonsInDownload[lessonId]
    }
    func lessonStartedDownloading(_ lessonId: Int) {
        self.lessonsInDownload[lessonId] = 0.0
    }
    
    func lessonEndedDownloading(_ lessonId: Int) {
        self.lessonsInDownload.removeValue(forKey: lessonId)
    }
    
    func lessonDownloadProgress(_ lessonId: Int, progress: Float) {
        self.lessonsInDownload[lessonId] = progress
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
    
    
    func removeLessonFromDownloaded(_ lesson: JTGemaraLesson, sederId: String, masechetId: String) {
        self.downloadedGemaraLessons[sederId]?[masechetId]?.remove(lesson)
        if self.downloadedGemaraLessons[sederId]?[masechetId]?.count == 0 {
            self.downloadedGemaraLessons[sederId]?.removeValue(forKey: masechetId)
        }
        if self.downloadedGemaraLessons[sederId]?.count == 0 {
            self.downloadedGemaraLessons.removeValue(forKey: sederId)
        }
        let urls: [URL] = [lesson.textLocalURL, lesson.audioLocalURL, lesson.videoLocalURL].compactMap{$0}
        FilesManagementProvider.shared.removeFiles(urls)
        self.updateDownloadedLessonsStorage()
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
        let urls: [URL] = [lesson.textLocalURL, lesson.audioLocalURL, lesson.videoLocalURL].compactMap{$0}
        FilesManagementProvider.shared.removeFiles(urls)
        self.updateDownloadedLessonsStorage()
    }
    
    
    func downloadGemaraLesson(_ lesson: JTGemaraLesson, mediaType: JTLessonMediaType, delegate: DownloadTaskDelegate?) {
        let downloadTask = DownloadTask(id: lesson.id, delegate: delegate)
        switch mediaType {
        case .audio:
            downloadTask.filesToDownload.append((lesson.audioLink, .s3, lesson.audioLocalFileName))
        case .video:
            downloadTask.filesToDownload.append((lesson.videoLink, .vimeo, lesson.videoLoaclFileName))
        }
        
        if lesson.isTextFileDownloaded == false {
            downloadTask.filesToDownload.append((lesson.textLink, .s3, lesson.textLocalFileName))
        }
        
        downloadTask.execute()
    }
    
    func downloadMishnaLesson(_ lesson: JTMishnaLesson, mediaType: JTLessonMediaType, delegate: DownloadTaskDelegate?) {
        let downloadTask = DownloadTask(id: lesson.id, delegate: delegate)
        switch mediaType {
        case .audio:
            downloadTask.filesToDownload.append((lesson.audioLink, .s3, lesson.audioLocalFileName))
        case .video:
            downloadTask.filesToDownload.append((lesson.videoLink, .vimeo, lesson.videoLoaclFileName))
        }
        
        if lesson.isTextFileDownloaded == false {
            downloadTask.filesToDownload.append((lesson.textLink, .s3, lesson.textLocalFileName))
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
        guard let url = self.downloadedLessonsStorageUrl else { return }
        do {
            let contentString = try String(contentsOf: url)
            guard let content = Utils.convertStringToDictionary(contentString) as? [String:Any] else { return }
            if let gemaraLessonsValues = content["gemara"] as? [SederId:[MasechetId:[[String:Any]]]]{
                self.downloadedGemaraLessons = gemaraLessonsValues.mapValues{$0.mapValues{Set($0.compactMap{JTGemaraLesson(values:$0)})}}
            }
            if let mishnaLessonsValues = content["mishna"] as? [SederId:[MasechetId:[Chapter : [[String:Any]]]]]{
                self.downloadedMishnaLessons = mishnaLessonsValues.mapValues{$0.mapValues{$0.mapValues{Set($0.compactMap{JTMishnaLesson(values: $0)})}}}
            }
        }
        catch {
            
        }
    }
    
    private func updateDownloadedLessonsStorage() {
        guard let url = self.downloadedLessonsStorageUrl else { return }
        let mappedGemaraLessons = self.downloadedGemaraLessons.mapValues{$0.mapValues{$0.map{$0.values}}}
        let mappedMishnaLessons = self.downloadedMishnaLessons.mapValues{$0.mapValues{$0.mapValues{$0.map{$0.values}}}}
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
                completion(.failure(error))
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
                completion(.failure(error))
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
    func downloadCompleted(downloadId: Int) {
        DispatchQueue.main.async {
            for delegate in self.delegates {
                delegate.downloadCompleted(downloadId: downloadId)
            }
        }
    }
    
    func downloadProgress(downloadId: Int, progress: Float) {
        DispatchQueue.main.async {
            for delegate in self.delegates {
                delegate.downloadProgress(downloadId: downloadId, progress: progress )
            }
        }
    }
}
