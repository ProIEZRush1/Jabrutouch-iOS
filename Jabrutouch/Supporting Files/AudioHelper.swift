//
//  AudioHelper.swift
//  Jabrutouch
//
//  Created by AviDeutsch on 30/01/2020.
//  Copyright © 2020 Ravtech. All rights reserved.
//


import UIKit
import AVFoundation


protocol AudioHelperDelegate {
    func assetExportSessionDidFinishExport(session: AVAssetExportSession, outputUrl:URL)
}

class AudioHelper: NSObject {

    var delegate: AudioHelperDelegate?

    func concatenate(audioUrls: [NSURL]) {

        //Create AVMutableComposition Object.This object will hold our multiple AVMutableCompositionTrack.
        var composition = AVMutableComposition()
        var compositionAudioTrack:AVMutableCompositionTrack = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: CMPersistentTrackID())!
        //create new file to receive data
        let url = FilesManagementProvider.shared.loadFile(link: "resultmerge.wav", directory: FileDirectory.cache)
//        var documentDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first! as NSURL
//        var fileDestinationUrl = NSURL(fileURLWithPath: NSTemporaryDirectory().stringByAppendingPathComponent("resultmerge.wav"))
//        print(fileDestinationUrl)

//        FilesManagementProvider.shared.removeFile(atPath: url) .deleteFileAtPath(NSTemporaryDirectory().stringByAppendingPathComponent("resultmerge.wav"))

        var avAssets: [AVURLAsset] = []
        var assetTracks: [AVAssetTrack] = []
        var durations: [CMTime] = []
        var timeRanges: [CMTimeRange] = []

        var insertTime = CMTime.zero

        for audioUrl in audioUrls {
            
            let avAsset = AVURLAsset(url: audioUrl as URL, options: nil)
            avAssets.append(avAsset)

            let assetTrack = avAsset.tracks(withMediaType: AVMediaType.audio)[0]
            assetTracks.append(assetTrack)

            let duration = assetTrack.timeRange.duration
            durations.append(duration)

            let timeRange = CMTimeRangeMake(start: CMTime.zero, duration: duration)
            timeRanges.append(timeRange)

            compositionAudioTrack.insertTimeRange(timeRange, of: assetTrack, at: insertTime)
            insertTime = CMTimeAdd(insertTime, duration)
        }

        //AVAssetExportPresetPassthrough => concatenation
        var assetExport = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetPassthrough)
        assetExport?.outputFileType = AVFileType.wav
        assetExport!.outputURL = url
        assetExport?.exportAsynchronously(completionHandler: {
            self.delegate?.assetExportSessionDidFinishExport(session: assetExport!, outputUrl: url)
        })
    }

    func exportTempWavAsMp3() {

//        let wavFilePath = NSTemporaryDirectory().stringByAppendingPathComponent("resultmerge.wav")
        AudioWrapper.convertFromWavToMp3(url)
    }
}
