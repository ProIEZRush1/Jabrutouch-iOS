//בעזרת ה׳ החונן לאדם דעת
//  DownloadTask.swift
//  Jabrutouch
//
//  Created by Yoni Reiss on 21/08/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import Foundation

protocol DownloadTaskDelegate: class {
    func downloadCompleted(downloadId: Int, mediaType: JTLessonMediaType, success: Bool)
    func downloadProgress(downloadId: Int, progress: Float, mediaType: JTLessonMediaType)
}

class DownloadTask {
    var id: Int
    var filesToDownload: [(fileName: String, source: ContentFileSource, localFileName: String)]
    var filesDownloadProgress: [String:(totalBytesDownloaded: Int64, totalBytes: Int64)] = [:]
    var filesDownloadedSuccessfully = 0
    var filesFailedDownloading = 0
    var mediaType: JTLessonMediaType
    weak var delegate: DownloadTaskDelegate?
    
    init(id: Int, delegate: DownloadTaskDelegate?, mediaType: JTLessonMediaType) {
        self.id = id
        self.filesToDownload = []
        self.delegate = delegate
        self.mediaType = mediaType
    }
    
    func execute() {
        for file in filesToDownload {
            var linksForHttpDownload: [String] = []
            switch file.source {
            case .s3:
                AWSS3Provider.shared.handleFileDownload(fileName: file.fileName, bucketName: AWSS3Provider.appS3BucketName, progressBlock: { (_ fileName: String, _ progress: Progress) in
                    self.filesDownloadProgress[fileName] = (progress.completedUnitCount, progress.totalUnitCount)
                    if self.filesDownloadProgress.keys.count == self.filesToDownload.count {
                        self.updateProgress()
                    }
                }) { (result: Result<Data, Error>) in
                    switch result {
                    case .success(let data):
                        if let url = FileDirectory.cache.url?.appendingPathComponent(file.localFileName) {
                            do {
                                try FilesManagementProvider.shared.overwriteFile(path: url, data: data)
                                self.filesDownloadedSuccessfully += 1
                            }
                            catch let error {
                                print(error)
                                self.filesFailedDownloading += 1
                            }
                        }
                        
                    case .failure(let error):
                        print(error)
                        self.filesFailedDownloading += 1
                    }
                    if self.filesDownloadedSuccessfully + self.filesFailedDownloading == self.filesToDownload.count {
                        self.downloadComplete()
                    }
                }
            case .vimeo:
                linksForHttpDownload.append(file.fileName)
            }
            
            if linksForHttpDownload.count > 0 {
                HttpServiceProvider.shared.downloadFiles(downloadId: self.id, links: linksForHttpDownload, delegate: self)
            }
        }
    }
    
    func updateProgress() {
        var totalBytes: Int64 = 0
        var downloadedBytes: Int64 = 0
        for (_, progress) in self.filesDownloadProgress {
            totalBytes += progress.totalBytes
            downloadedBytes += progress.totalBytesDownloaded
        }
        let progress: Float = Float(downloadedBytes) / Float(totalBytes)
        DispatchQueue.main.async {
            self.delegate?.downloadProgress(downloadId: self.id, progress: progress, mediaType: self.mediaType)
        }
    }
    
    func downloadComplete() {
        DispatchQueue.main.async {
            self.delegate?.downloadCompleted(downloadId: self.id, mediaType: self.mediaType, success: (self.filesFailedDownloading == 0) )
        }
    }
}

extension DownloadTask: HttpDownloadTaskDelegate {
    
    func fileDownloadProgress(link: String, bytesDownloaded: Int64, totalBytes: Int64, downloadId: Int) {
        self.filesDownloadProgress[link] = (bytesDownloaded, totalBytes)
        if self.filesDownloadProgress.keys.count == self.filesToDownload.count {
            self.updateProgress()
        }
    }
    
    func fileDownloadFailed(link: String, downlaodId: Int) {
        self.filesFailedDownloading += 1
        
        if self.filesDownloadedSuccessfully + self.filesFailedDownloading == self.filesToDownload.count {
            self.downloadComplete()
        }
    }
    
    func fileDownloadFinished(link: String, downlaodId: Int, data: Data) {
        var localFileName = ""
        for file in self.filesToDownload {
            if file.fileName == link { localFileName = file.localFileName}
        }
        if let url = FileDirectory.cache.url?.appendingPathComponent(localFileName) {
            do {
                try FilesManagementProvider.shared.overwriteFile(path: url, data: data)
                self.filesDownloadedSuccessfully += 1
            }
            catch let error {
                print(error)
                self.filesFailedDownloading += 1
            }
        }
        
        if self.filesDownloadedSuccessfully + self.filesFailedDownloading == self.filesToDownload.count {
            self.downloadComplete()
        }
    }
    
    func downloadFinished(downloadId: Int) {
        
    }
    
    func downloadTotalProgress(progress: Float, downloadId: Int) {
        
    }
}
