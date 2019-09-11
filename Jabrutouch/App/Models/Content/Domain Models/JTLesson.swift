//בעזרת ה׳ החונן לאדם דעת
//  JTLesson.swift
//  Jabrutouch
//
//  Created by Yoni Reiss on 25/08/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import Foundation

class JTLesson: Hashable  {
    
    
    
    //============================================
    // MARK: - Stored Properties
    //============================================
    
    var id: Int
    var chapter: Int
    var duration: Int
    var audioLink: String?
    var videoLink: String?
    var textLink: String?
    var videoPart: [String]
    var gallery: [String]
    var presenter: JTLesssonPresenter?
    
    var isDownloadingAudio = false
    var isDownloadingVideo = false
    var audioDownloadProgress: Float?
    var videoDownloadProgress: Float?
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
        
        if let duration = values["duration"] as? Int {
            self.duration = duration
        } else { return nil }
        
        if let audioLink = values["audio"] as? String {
            self.audioLink = audioLink
        }
        
        if let videoLink = values["video"] as? String {
            self.videoLink = videoLink
        }
        
        if let textLink = values["page"] as? String {
            self.textLink = textLink
        }
        
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
    
    private var audioRemoteURL: URL? {
        guard let link = self.audioLink else { return nil }
        var fullLink = "\(AWSS3Provider.appS3BaseUrl)\(link)"
//        fullLink = fullLink.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
        fullLink = fullLink.replacingOccurrences(of: " ", with: "%20")
        return URL(string: fullLink)
    }
    
    private var videoRemoteURL: URL? {
        guard let link = self.videoLink else { return nil }
        return URL(string: link)
    }
    
    private var textRemoteURL: URL? {
        guard let link = self.textLink else { return nil }
        var fullLink = "\(AWSS3Provider.appS3BaseUrl)\(link)"
//        fullLink = fullLink.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
        fullLink = fullLink.replacingOccurrences(of: " ", with: "%20")
        return URL(string: fullLink)
    }
    
    private var audioLocalURL: URL? {
        return FileDirectory.cache.url?.appendingPathComponent(self.audioLocalFileName)
    }
    
    private var videoLocalURL: URL? {
        return FileDirectory.cache.url?.appendingPathComponent(self.videoLoaclFileName)
    }
    
    private var textLocalURL: URL? {
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
    
    var audioURL: URL? {
        if self.isAudioDownloaded {
            return self.audioLocalURL
        }
        else {
            return self.audioRemoteURL
        }
    }
    
    var videoURL: URL? {
        if self.isVideoDownloaded {
            return self.videoLocalURL
        }
        else {
            return self.videoRemoteURL
        }
    }
    
    var textURL: URL? {
        if self.isTextFileDownloaded {
            return self.textLocalURL
        }
        else {
            return self.textRemoteURL
        }
    }
    
    var values: [String: Any] {
        var values: [String:Any] = [:]
        values["id"] = self.id
        values["chapter"] = chapter
        values["duration"] = self.duration
        values["audio"] = self.audioLink
        values["video"] = self.videoLink
        values["page"]  = self.textLink
        values["video_part"] = self.videoPart
        values["gallery"] = self.gallery
        values["presenter"] = self.presenter?.values
        return values
    }
    
    //============================================
    // MARK: - Hashable
    //============================================
    static func == (lhs: JTLesson, rhs: JTLesson) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
}
