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
    var filesToSave: [(filename:String, data:Data)] = []
    var maxRetries = 3
    var fileRetryCount: [String: Int] = [:]
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
                self.downloadFileFromS3(file: file)
            case .vimeo:
                linksForHttpDownload.append(file.fileName)
            }

            if linksForHttpDownload.count > 0 {
                HttpServiceProvider.shared.downloadFiles(downloadId: self.id, links: linksForHttpDownload, delegate: self)
            }
        }
    }

    private func downloadFileFromS3(file: (fileName: String, source: ContentFileSource, localFileName: String)) {
        // Use Documents directory instead of Caches for persistent storage
        guard let documentsURL = FileDirectory.documents.url else {
            self.filesFailedDownloading += 1
            if self.filesDownloadedSuccessfully + self.filesFailedDownloading == self.filesToDownload.count {
                self.downloadComplete()
            }
            return
        }

        let destinationURL = documentsURL.appendingPathComponent(file.localFileName)

        AWSS3Provider.shared.handleFileDownloadToURL(
            fileName: file.fileName,
            bucketName: AWSS3Provider.appS3BucketName,
            destinationURL: destinationURL,
            progressBlock: { (_ fileName: String, _ progress: Progress) in
                self.filesDownloadProgress[fileName] = (progress.completedUnitCount, progress.totalUnitCount)
                if self.filesDownloadProgress.keys.count == self.filesToDownload.count {
                    self.updateProgress()
                }
            }
        ) { (result: Result<URL, Error>) in
            switch result {
            case .success(let url):
                // File successfully downloaded and saved to Documents
                print("✅ Download success: \(url.path)")
                self.filesDownloadedSuccessfully += 1
            case .failure(let error):
                print("❌ Download failed: \(error.localizedDescription)")
                // Implement retry logic
                let retryCount = self.fileRetryCount[file.fileName] ?? 0
                if retryCount < self.maxRetries {
                    self.fileRetryCount[file.fileName] = retryCount + 1
                    print("🔄 Retrying download (\(retryCount + 1)/\(self.maxRetries)): \(file.fileName)")
                    // Retry after a delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        self.downloadFileFromS3(file: file)
                    }
                    return
                } else {
                    print("⛔ Max retries reached for: \(file.fileName)")
                    self.filesFailedDownloading += 1
                }
            }

            if self.filesDownloadedSuccessfully + self.filesFailedDownloading == self.filesToDownload.count {
                self.downloadComplete()
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
        let success = (self.filesFailedDownloading == 0)

        // Note: Files are already saved to Documents directory via streaming download
        // No need to write data again (unlike the old cache-based approach)

        if !success {
            print("⚠️ Download completed with \(self.filesFailedDownloading) failed file(s)")
        } else {
            print("✅ All downloads completed successfully")
        }

        // Legacy data-based save for Vimeo/HTTP downloads
        if success && self.filesToSave.count > 0 {
            for file in self.filesToSave {
                // Changed from cache to documents directory
                if let url = FileDirectory.documents.url?.appendingPathComponent(file.filename) {
                    do {
                        try FilesManagementProvider.shared.overwriteFile(path: url, data: file.data)
                    }
                    catch let error {
                        print("❌ Error saving file \(file.filename): \(error)")
                    }
                }
            }
        }

        DispatchQueue.main.async {
            self.delegate?.downloadCompleted(downloadId: self.id, mediaType: self.mediaType, success: success )
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
        self.filesToSave.append((localFileName,data))
        self.filesDownloadedSuccessfully += 1
        
        if self.filesDownloadedSuccessfully + self.filesFailedDownloading == self.filesToDownload.count {
            self.downloadComplete()
        }
    }
    
    func downloadFinished(downloadId: Int) {
        
    }
    
    func downloadTotalProgress(progress: Float, downloadId: Int) {
        
    }
}
