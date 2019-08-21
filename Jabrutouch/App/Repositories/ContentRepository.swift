//בעזרת ה׳ החונן לאדם דעת
//  ContentRepository.swift
//  Jabrutouch
//
//  Created by Yoni Reiss on 14/08/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import Foundation

enum JTLessonMediaType {
    case audio
    case video
}

protocol ContentRepositoryDownloadDelegate: class {
    
}

enum ContentFileSource {
    case s3
    case vimeo
}

class ContentRepository {
    
    
    //========================================
    // MARK: - Properties
    //========================================
    var shas: [JTSeder] = []
    var gemaraLessons: [String:[String:JTGemaraLesson]] = [:]
    var mishnaLessons: [String:[String:[String:JTMishnaLesson]]] = [:]
    var downloadedGemaraLessons: [String: [String:JTGemaraLesson]] = [:]
    var downloadedMishnaLessons: [String: [String:JTMishnaLesson]] = [:]

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
    // MARK: - Main Methods
    //========================================
    
    func getGemaraSeders()-> [JTGemaraSeder] {
        var seders: [JTGemaraSeder] = []
        for seder in self.shas {
            let masechtot = seder.masechtot.map{JTGemaraMasechetItem(name: $0.name, masechetId: $0.id, pagesCount: $0.pagesCount)}.filter{$0.pagesCount > 0}
            seders.append(JTGemaraSeder(name: seder.name, masechtot: masechtot))
        }
        return seders
    }
    
    func getMishanSeders()-> [JTMishnaSeder] {
        var seders: [JTMishnaSeder] = []
        for seder in self.shas {
            let masechtot = seder.masechtot.map{JTMishnaMasechetItem(name: $0.name, masechetId: $0.id, chaptersCount: $0.chaptersCount)}
            seders.append(JTMishnaSeder(name: seder.name, masechtot: masechtot))
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
    
    //========================================
    // MARK: - Download content methods
    //========================================
    
    func addLessonToDownloaded(_ lesson: JTGemaraLesson, seder: String) {
        if let _ = self.downloadedGemaraLessons[seder] {
            self.downloadedGemaraLessons[seder]?.updateValue(lesson, forKey: "\(lesson.id)")
        }
        else {
            self.downloadedGemaraLessons[seder] = ["\(lesson.id)" : lesson]
        }
        self.updateDownloadedLessonsStorage()
    }
    
    func addLessonToDownloaded(_ lesson: JTMishnaLesson, seder: String) {
        if let _ = self.downloadedMishnaLessons[seder] {
            self.downloadedMishnaLessons[seder]?.updateValue(lesson, forKey: "\(lesson.id)")
        }
        else {
            self.downloadedMishnaLessons[seder] = ["\(lesson.id)" : lesson]
        }
        self.updateDownloadedLessonsStorage()
    }
    
    func removeLessonFromDownloaded(_ lesson: JTGemaraLesson, seder: String) {
        
    }
    
    func removeLessonFromDownloaded(_ lesson: JTMishnaLesson, seder: String) {
        
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
    // MARK: - Stored content methods
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
            guard let content = Utils.convertStringToDictionary(contentString) as? [String:[String:[String:[String:Any]]]] else { return }
            if let gemaraLessonsValues = content["gemara"] {
                self.downloadedGemaraLessons = gemaraLessonsValues.mapValues{$0.compactMapValues{JTGemaraLesson(values: $0)}}
            }
            if let mishnaLessonsValues = content["mishna"] {
                self.downloadedMishnaLessons = mishnaLessonsValues.mapValues{$0.compactMapValues{JTMishnaLesson(values: $0)}}
            }
        }
        catch {
            
        }
    }
    
    private func updateDownloadedLessonsStorage() {
        guard let url = self.downloadedLessonsStorageUrl else { return }
        let mappedGemaraLessons = self.downloadedGemaraLessons.mapValues{$0.mapValues{$0.values}}
        let mappedMishnaLessons = self.downloadedMishnaLessons.mapValues{$0.mapValues{$0.values}}
        let content = ["gemara": mappedGemaraLessons, "mishna": mappedMishnaLessons]
        do {
            try self.saveContentToFile(content: content, url: url)
        }
        catch {
            
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
                    NotificationCenter.default.post(name: .shasLoaded, object: nil, userInfo: nil)
                case .failure(let error):
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
}
