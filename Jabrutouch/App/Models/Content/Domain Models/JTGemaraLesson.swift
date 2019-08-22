//בעזרת ה׳ החונן לאדם דעת
//  JTGemaraLesson.swift
//  Jabrutouch
//
//  Created by Yoni Reiss on 14/08/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import Foundation

struct JTGemaraLesson: Hashable  {
    
    //============================================
    // MARK: - Stored Properties
    //============================================
    
    var id: Int
    var chapter: Int
    var page: Int
    var duration: Int
    var audioLink: String
    var videoLink: String
    var textLink: String
    var videoPart: [String]
    var gallery: [String]
    var presenter: JTLesssonPresenter?
    
    var isDonwnloading = false
    var downloadProgress: Float?
    //============================================
    // MARK: - Initializer
    //============================================
    
    init?(values: [String:Any]) {
        
        if let id = values["id"] as? Int {
            self.id = id
        } else { return nil }
        
        if let chapter = values["chapter"] as? Int {
            self.chapter = chapter
        } else { return nil }
        
        if let page = values["page_number"] as? Int {
            self.page = page
        } else { return nil }
        
        if let duration = values["duration"] as? Int {
            self.duration = duration
        } else { return nil }
        
        if let audioLink = values["audio"] as? String {
            self.audioLink = audioLink
        } else { return nil }
        
        if let videoLink = values["video"] as? String {
            self.videoLink = videoLink
        } else { return nil }
        
        if let textLink = values["page"] as? String {
            self.textLink = textLink
        } else { return nil }
        
        if let videoPart = values["video_part"] as? [String] {
            self.videoPart = videoPart
        } else { return nil }
        
        if let gallery = values["gallery"] as? [String] {
            self.gallery = gallery
        } else { return nil }
        
        if let presenterValues = values["presenter"] as? [String: Any] {
            if let presenter = JTLesssonPresenter(values: presenterValues) {
                self.presenter = presenter
            } 
        }
    }
    
    
    //============================================
    // MARK: - Hashable & Equateable
    //============================================
    
    static func == (lhs: JTGemaraLesson, rhs: JTGemaraLesson) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
    
    //============================================
    // MARK: - Computed Properties
    //============================================
    
    
    var durationDisplay: String {
        let minutes = self.duration/60
        return "\(minutes)\(Strings.minutesShorthand)"
    }
    
    var isAudioDownloaded: Bool {
        guard let filesNames = FilesManagementProvider.shared.filesList(.cache) else { return false }
        for fileName in filesNames {
            if fileName == self.audioLocalFileName {
                return true
            }
        }
        return false
    }
    
    var isVideoDownloaded: Bool {
        guard let filesNames = FilesManagementProvider.shared.filesList(.cache) else { return false }
        for fileName in filesNames {
            if fileName == self.videoLoaclFileName {
                return true
            }
        }
        return false
    }
    
    var isTextFileDownloaded: Bool {
        guard let filesNames = FilesManagementProvider.shared.filesList(.cache) else { return false }
        for fileName in filesNames {
            if fileName == self.textLocalFileName {
                return true
            }
        }
        return false
    }
    
    var audioRemoteURL: URL? {
        let fullLink = "\(AWSS3Provider.appS3BaseUrl)\(AWSS3Provider.appS3BucketName)/\(self.videoLink)"
        return URL(string: fullLink)
    }
    
    var videoRemoteURL: URL? {
        return URL(string: self.videoLink)
    }
    
    var textRemoteURL: URL? {
        let fullLink = "\(AWSS3Provider.appS3BaseUrl)\(AWSS3Provider.appS3BucketName)/\(self.videoLink)"
        return URL(string: fullLink)
    }
    
    var audioLocalURL: URL? {
        return FileDirectory.cache.url?.appendingPathComponent(self.audioLocalFileName)
    }
    
    var videoLocalURL: URL? {
        return FileDirectory.cache.url?.appendingPathComponent(self.videoLoaclFileName)
    }
    
    var textLocalURL: URL? {
        return FileDirectory.cache.url?.appendingPathComponent(self.textLocalFileName)
    }
    
    var audioLocalFileName: String {
        return "\(self.id)_aud.mp3"
    }
    
    var videoLoaclFileName: String {
        return "\(self.id)_vid.mp4"
    }
    
    var textLocalFileName: String {
        return "\(self.id)_text.pdf"
    }
    
    var values: [String: Any] {
        var values: [String:Any] = [:]
        values["id"] = self.id
        values["chapter"] = chapter
        values["page_number"] = self.page
        values["duration"] = self.duration
        values["audio"] = self.audioLink
        values["video"] = self.videoLink
        values["page"]  = self.textLink
        values["video_part"] = self.videoPart
        values["gallery"] = self.gallery
        values["presenter"] = self.presenter?.values 
        return values
    }
}



