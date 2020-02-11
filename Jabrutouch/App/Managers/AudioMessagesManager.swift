//
//  AudioMessagesManager.swift
//  Jabrutouch
//
//  Created by AviDeutsch on 04/02/2020.
//  Copyright © 2020 Ravtech. All rights reserved.
//

import Foundation
import AVFoundation

protocol AudioMessagesManagerDelegate {
    func currentTimeChanged(currentTime: TimeInterval)
    func playerDidFinish()
}

class AudioMessagesManager {
    
    private static var manager: AudioMessagesManager?
    
    class var shared: AudioMessagesManager {
        if self.manager == nil {
            self.manager = AudioMessagesManager()
        }
        return self.manager!
    }
    
    private init() {
        
    }
    
    var soundPlayer : AVAudioPlayer?
    var soundRecorder: AVAudioRecorder?
    var timer = Timer()
    var delegate: AudioMessagesManagerDelegate?
    
    func startRecording(_ fileName: String) {
        
        let urlFile = FilesManagementProvider.shared.loadFile(link: "sample1.wav", directory: FileDirectory.recorders)
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            audioSession.requestRecordPermission() { allowed in
                if allowed {
                    print("Allow")
                } else {
                    print("Dont Allow")
                }
            }
            
            try audioSession.setCategory(AVAudioSession.Category.record)
            try audioSession.setActive(true)
            
            let settings = [
                AVFormatIDKey: Int(kAudioFormatLinearPCM),
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 2,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            
            soundRecorder = try AVAudioRecorder(url: urlFile as URL, settings: settings)
            soundRecorder?.delegate = self as? AVAudioRecorderDelegate
            soundRecorder?.prepareToRecord()
            soundRecorder?.record()
        }
        catch {
            print(error)
        }
    }
    
    func stopRecoredr(_ fileName: String) {
        soundRecorder?.stop()
        soundRecorder = nil
        self.attempConvert(fileName)
    }
    
    
    func startPlayer(_ url: String) {
        
        let urlFile = FilesManagementProvider.shared.loadFile(link: url, directory: FileDirectory.recorders)
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            soundPlayer = try AVAudioPlayer(contentsOf: urlFile, fileTypeHint: AVFileType.mp3.rawValue)
            soundPlayer?.delegate = self as? AVAudioPlayerDelegate
            soundPlayer?.prepareToPlay()
            soundPlayer?.play()
            soundPlayer?.volume = 1.0
            timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.updateCurrentTime(_:)), userInfo: nil, repeats: true)

        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    
    func stopPlayer() {
        soundPlayer?.stop()
        soundPlayer = nil
        timer.invalidate()

    }
    
    @objc func updateCurrentTime(_ sender: Any) {
        self.delegate?.currentTimeChanged(currentTime: self.getCurrentTime())
        if !self.isFinishedPlayer {
            timer.invalidate()
            self.delegate?.playerDidFinish()
        }
    }
    
    func getCurrentTime() -> TimeInterval {
        return self.soundPlayer?.currentTime ?? 0
    }
    
    func setCurrentTime(_ currentTime: Float)  {
          self.soundPlayer?.currentTime = Double(currentTime)
      }
      
    var isFinishedPlayer: Bool {
       let playerStatus = soundPlayer!.isPlaying
            return playerStatus
    }
    
    
    
    func attempConvert(_ fileName: String) {
        let source = FilesManagementProvider.shared.loadFile(link: "sample1.wav", directory: FileDirectory.recorders).path
        let target = FilesManagementProvider.shared.loadFile(link: "\(fileName).mp3", directory: FileDirectory.recorders).path
        AudioWrapper.convert(fromWav: source, destinationPath:  target, sourceSampleRate: 44100 )
        
        
    }
    
    //    func getDocumentDirectory()-> URL {
    //        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    //        return paths
    //    }
    
    
    
}
