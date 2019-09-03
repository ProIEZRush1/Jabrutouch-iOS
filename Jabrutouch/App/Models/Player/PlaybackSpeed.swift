//בעזרת ה׳ החונן לאדם דעת
//  PlaybackSpeed.swift
//  Jabrutouch
//
//  Created by Yoni Reiss on 29/08/2019.
//  Copyright © 2019 Ravtech. All rights reserved.
//

import Foundation

enum PlaybackSpeed {
    case regular
    case oneAndAHalf
    case double
    
    var rate: Float {
        switch self {
        case .regular:
            return 1.0
        case .oneAndAHalf:
            return 1.5
        case .double:
            return 2.0
        }
    }
}
