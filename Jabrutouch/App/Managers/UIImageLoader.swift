//
//  UIImageLoader.swift
//  Jabrutouch
//
//  Created by Avraham Kirsch on 13/09/2021.
//  Copyright © 2021 Ravtech. All rights reserved.
//

import Foundation

class ImageLoader {
    private var loadedImages = [URL: UIImage]()
    private var runningRequests = [UUID: URLSessionDataTask]()

    func loadImage(_ url: URL, _ completion: @escaping (Result<UIImage, Error>) -> Void) -> UUID? {

        if let image = self.loadedImages[url] {
            completion(.success(image))
            return nil
        }

        let uuid = UUID()

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
        
            defer {self.runningRequests.removeValue(forKey: uuid) }

            if let data = data, let image = UIImage(data: data) {
                self.loadedImages[url] = image
                completion(.success(image))
                return
            }

            guard let error = error else {
                // without an image or an error, we'll just ignore this for now
                // you could add your own special error cases for this scenario
                return
            }
            guard (error as NSError).code == NSURLErrorCancelled else {
                completion(.failure(error))
                return
            }
            // the request was cancelled, no need to call the callback
        }
        task.resume()
        self.runningRequests[uuid] = task
        return uuid
    }


    func cancelLoad(_ uuid: UUID) {
        self.runningRequests[uuid]?.cancel()
        self.runningRequests.removeValue(forKey: uuid)
    }
    
    func removeImage(url: URL){
        self.loadedImages.removeValue(forKey: url)
    }



}


class UIImageLoader {
    static let loader = UIImageLoader()

    private let imageLoader = ImageLoader()
    private var uuidMap = [UIImageView: UUID]()

    private init() {}

    func load(_ url: URL, for imageView: UIImageView) {
        let imageActivity = Utils.showActivityView(inView: imageView, withFrame: imageView.frame, text: nil)
        let token = self.imageLoader.loadImage(url) { result in
 
            defer { self.uuidMap.removeValue(forKey: imageView)}
            do {

                let image = try result.get()
                DispatchQueue.main.async {
                    imageView.image = image
                    Utils.removeActivityView(imageActivity)
                }
            } catch {
            // handle the error
            }
        }

        if let token = token {
            self.uuidMap[imageView] = token
        }
    }

    func cancel(for imageView: UIImageView) {
        if let uuid = self.uuidMap[imageView] {
            self.imageLoader.cancelLoad(uuid)
            self.uuidMap.removeValue(forKey: imageView)
        }
    }
    
    func removeSavedImage(url: URL) {
        self.imageLoader.removeImage(url: url)
    }
}

extension UIImageView {
  func loadImage(at url: URL) {
    UIImageLoader.loader.load(url, for: self)
  }

  func cancelImageLoad() {
    UIImageLoader.loader.cancel(for: self)
  }
}
