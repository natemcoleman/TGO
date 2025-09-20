//
//  TGOTrackingAttributes.swift
//  TGO
//
//  Created by Brooklyn Daines on 9/20/25.
//

import Foundation
import ActivityKit

struct TGOTrackingAttributes: ActivityAttributes {
    public typealias TGOTrackingStatus = ContentState
    var routeName: String
    var numTotalCheckpoints: Int
    public struct ContentState: Codable, Hashable {
        var elapsedTime: TimeInterval
        var splitTime: TimeInterval
        var nextCheckpoint: String
        var numComplete: Int
    }
}
