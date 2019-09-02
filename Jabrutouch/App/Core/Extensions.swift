//בעזרת ה׳ החנון לאדם דעת
//  Extensions.swift
//  Jabrutouch
//
//  Created by Yoni Reiss on 22/07/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import UIKit
import AVKit

extension String {
    subscript (i: Int) -> Character {
        return self[index(startIndex, offsetBy: i)]
    }
}

extension Dictionary {
    
    public func compactMapValues<T>(_ transform: (Value) throws -> T?) rethrows -> [Key: T] {
        return try self.reduce(into: [Key: T](), { (result, x) in
            if let value = try transform(x.value) {
                result[x.key] = value
            }
        })
    }
}

extension AVPlayer {
    var isPlaying: Bool {
        return rate != 0 && error == nil
    }
    
    var currentTime: TimeInterval {
        return TimeInterval(CMTimeGetSeconds( self.currentTime()))
    }
    
    var duration: TimeInterval {
        return TimeInterval(CMTimeGetSeconds(self.currentItem?.asset.duration ?? CMTime()))
    }
}

extension CALayer {
    func moveTo(point: CGPoint, animated: Bool) {
        if animated {
            let animation = CABasicAnimation(keyPath: "position")
            animation.fromValue = value(forKey: "position")
            animation.toValue = NSValue(cgPoint: point)
            animation.fillMode = .forwards
            self.position = point
            add(animation, forKey: "position")
        } else {
            self.position = point
        }
    }
    
    func resize(to size: CGSize, animated: Bool) {
        let oldBounds = bounds
        var newBounds = oldBounds
        newBounds.size = size
        
        if animated {
            let animation = CABasicAnimation(keyPath: "bounds")
            animation.fromValue = NSValue(cgRect: oldBounds)
            animation.toValue = NSValue(cgRect: newBounds)
            animation.fillMode = .forwards
            self.bounds = newBounds
            add(animation, forKey: "bounds")
        } else {
            self.bounds = newBounds
        }
    }
    
    func resizeAndMove(frame: CGRect, animated: Bool, duration: TimeInterval = 0) {
        if animated {
            let positionAnimation = CABasicAnimation(keyPath: "position")
            positionAnimation.fromValue = value(forKey: "position")
            positionAnimation.toValue = NSValue(cgPoint: CGPoint(x: frame.midX, y: frame.midY))
            
            let oldBounds = bounds
            var newBounds = oldBounds
            newBounds.size = frame.size
            
            let boundsAnimation = CABasicAnimation(keyPath: "bounds")
            boundsAnimation.fromValue = NSValue(cgRect: oldBounds)
            boundsAnimation.toValue = NSValue(cgRect: newBounds)
            boundsAnimation.duration = duration
            
            let groupAnimation = CAAnimationGroup()
            groupAnimation.animations = [positionAnimation, boundsAnimation]
            groupAnimation.fillMode = .forwards
            groupAnimation.duration = duration
            groupAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            self.frame = frame
            add(groupAnimation, forKey: "frame")
            
        } else {
            self.frame = frame
        }
    }
}
