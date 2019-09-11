//בעזרת ה׳ החונן לאדם דעת
//  HTTPProvider.swift
//  Jabrutouch
//
//  Created by Yoni Reiss on 29/07/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import Foundation

enum HttpRequestMethod:String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

protocol HttpDownloadTaskDelegate {
    func downloadTotalProgress(progress: Float, downloadId: Int)
    func fileDownloadProgress(link: String, bytesDownloaded: Int64, totalBytes: Int64, downloadId: Int)
    func fileDownloadFinished(link: String, downlaodId: Int, data: Data)
    func fileDownloadFailed(link: String, downlaodId: Int)
    func downloadFinished(downloadId: Int)
}

class HttpDownloadTask {
    var id: Int
    var tasks: [(task: URLSessionDataTask, link: String)]
    var downloadedData: [Int: Data] = [:]
    var delegate: HttpDownloadTaskDelegate
    var progress: Float
    var finished: Bool
    private var tasksFinished = 0
    private var tasksFinishedSuccessfully = 0
    
    init(id: Int, delegate: HttpDownloadTaskDelegate) {
        self.id = id
        self.delegate = delegate
        self.tasks = []        
        self.progress = 0.0
        self.finished = false
    }
    
    func taskCompleted(task: URLSessionDataTask, withError error: Error?) {
        self.tasksFinished += 1
        if error == nil {
            self.tasksFinishedSuccessfully += 1
        }
        
        for _task in self.tasks {
            if _task.task.taskIdentifier == task.taskIdentifier {
                if error == nil {
                    if let data = self.downloadedData[task.taskIdentifier] {
                        self.delegate.fileDownloadFinished(link: _task.link, downlaodId: self.id, data: data)
                    }
                }
                else {
                    self.delegate.fileDownloadFailed(link: _task.link, downlaodId: self.id)
                }
            }
        }
        if self.tasksFinished == self.tasks.count {
            self.finished = true
            DispatchQueue.main.async {
                self.delegate.downloadFinished(downloadId: self.id)
            }
        }
    }
}

class HttpServiceProvider: NSObject {
    
    private var downloadTasks: [HttpDownloadTask] = []
    private var _downloadSession: URLSession?
    
    private static var provider: HttpServiceProvider?
    
    var downloadSession: URLSession {
        if self._downloadSession == nil {
            let sessionConfiguration = URLSessionConfiguration.default
            self._downloadSession = URLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: nil)
        }
        return self._downloadSession!
    }
    
    class var shared: HttpServiceProvider {
        if self.provider == nil {
            self.provider = HttpServiceProvider()
        }
        return self.provider!
    }
    
    private override init() {
        
    }
    
    func excecuteRequest(request:URLRequest, completionHandler:@escaping ((Data?, URLResponse?, Error?) -> Void) ) {
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            if let _error = error {
                completionHandler(data, response, _error)
            }
            else {
                completionHandler(data, response, nil)
            }
            
        }
        task.resume()
    }
    
    func downloadFiles(downloadId: Int, links: [String], delegate: HttpDownloadTaskDelegate) {
        
        let downloadTask = HttpDownloadTask(id: downloadId, delegate: delegate)
        for link in links {
            guard let url = URL(string: link) else { return }
            let task = self.downloadSession.dataTask(with: url)
            downloadTask.tasks.append((task,link))
        }
        self.downloadTasks.append(downloadTask)
        
        for (task,_) in downloadTask.tasks {
            downloadTask.downloadedData[task.taskIdentifier] = Data()
            task.resume()
        }
        
    }
    
    private func removeDownloadTask(_ downloadTask: HttpDownloadTask) {
        for i in 0..<self.downloadTasks.count {
            if self.downloadTasks[i] === downloadTask {
                self.downloadTasks.remove(at: i)
                return
            }
        }
    }
}

extension HttpServiceProvider: URLSessionDataDelegate{
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        for downloadTask in self.downloadTasks {
            var total: Int64 = 0
            var received: Int64 = 0
            for (task, link) in downloadTask.tasks {
                total += task.countOfBytesExpectedToReceive
                received += task.countOfBytesReceived
                
                if task.taskIdentifier == dataTask.taskIdentifier {
                    downloadTask.downloadedData[task.taskIdentifier]?.append(data)
                    downloadTask.delegate.fileDownloadProgress(link: link, bytesDownloaded: task.countOfBytesReceived, totalBytes: task.countOfBytesExpectedToReceive, downloadId: downloadTask.id)
                }
            }
            downloadTask.progress = Float(received/total)
            
            downloadTask.delegate.downloadTotalProgress(progress: downloadTask.progress, downloadId: downloadTask.id)
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        for downloadTask in self.downloadTasks {
            for (_task,_) in downloadTask.tasks {
                if _task.taskIdentifier == task.taskIdentifier {
                    
                    downloadTask.taskCompleted(task: _task, withError: error)
                    if downloadTask.finished {
                        self.removeDownloadTask(downloadTask)
                    }
                }
            }
        }
    }
}
