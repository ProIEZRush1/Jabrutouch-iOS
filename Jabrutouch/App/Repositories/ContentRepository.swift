//בעזרת ה׳ החונן לאדם דעת
//  ContentRepository.swift
//  Jabrutouch
//
//  Created by Yoni Reiss on 14/08/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import Foundation

class ContentRepository {
    
    //========================================
    // MARK: - Properties
    //========================================
    var shas: [JTSeder] = []
    var gemaraLessons: [Int:[Int:JTGemaraLesson]] = [:]
    var mishnaLessons: [Int:[Int:[Int:JTMishnaLesson]]] = [:]
    
    private static var repository: ContentRepository?
    
    class var shared: ContentRepository {
        if self.repository == nil {
            self.repository = ContentRepository()
        }
        return self.repository!
    }
    
    //========================================
    // MARK: - Initializer
    //========================================
    
    private init() {
        self.loadShas()
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
        
        
        if let lessonsDict = self.gemaraLessons[masechetId] {
            if forceRefresh == false {
                let lessons = Array(lessonsDict.values)
                completion(.success(lessons))
                return
            }
        }
        
        self.loadGemaraLessons(masechetId: masechetId) { (result:Result<[JTGemaraLesson], JTError>) in
            switch result {
            case .success(let lessons):
                let lessonsDict = Dictionary(uniqueKeysWithValues: lessons.map{($0.id, $0)})
                self.gemaraLessons.updateValue(lessonsDict, forKey: masechetId)
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
        
        if let lessonsDict = self.mishnaLessons[masechetId]?[chapter] {
            if forceRefresh == false {
                let lessons = Array(lessonsDict.values)
                completion(.success(lessons))
                return
            }
        }
            
        
        self.loadMishnaLessons(masechetId: masechetId, chapter: chapter) { (result:Result<[JTMishnaLesson], JTError>) in
            switch result {
            case .success(let lessons):
                let lessonsDict = Dictionary(uniqueKeysWithValues: lessons.map{($0.id, $0)})
                if let _ = self.mishnaLessons[masechetId] {
                    self.mishnaLessons[masechetId]?.updateValue(lessonsDict, forKey: chapter)
                }
                else {
                    self.mishnaLessons.updateValue([chapter:lessonsDict], forKey: masechetId)
                }
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
    // MARK: - Loading methods
    //========================================
    
    private func loadShas() {
        API.getMasechtot { (result: APIResult<GetMasechtotResponse>) in
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
}
