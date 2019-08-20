//בעזרת ה׳ החונן לאדם דעת
//  JTMishnaLesson.swift
//  Jabrutouch
//
//  Created by Yoni Reiss on 14/08/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import Foundation

struct JTMishnaLesson {
    var id: Int
    var chapter: Int
    var mishna: Int
    var duration: Int
    var audioLink: String
    var videoLink: String
    var textLink: String
    var videoPart: [String]
    var gallery: [String]
    var presenter: JTLesssonPresenter?
    
    var durationDisplay: String {
        let minutes = self.duration/60
        return "\(minutes)\(Strings.minutesShorthand)"
    }
    
    var isAudioDownloaded: Bool {
        return false
    }
    
    var isVideoDownloaded: Bool {
        return false
    }
    
    var audioLocalFileName: String {
        return "\(self.id)_aud.mp3"
    }
    
    var videoLoaclFileName: String {
        return "\(self.id)_vid.mp4"
    }
    
    var teztLocalFileName: String {
        return "\(self.id)_text.pdf"
    }
    
    init?(values: [String:Any]) {
        
        if let id = values["id"] as? Int {
            self.id = id
        } else { return nil }
        
        if let chapter = values["chapter"] as? Int {
            self.chapter = chapter
        } else { return nil }
        
        if let mishna = values["mishna"] as? Int {
            self.mishna = mishna
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
    
    var values: [String: Any] {                        
        var values: [String:Any] = [:]
        values["id"] = self.id
        values["chapter"] = chapter
        values["mishna"] = self.mishna
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
