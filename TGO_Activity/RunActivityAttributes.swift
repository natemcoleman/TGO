//
//  RunActivityAttributes.swift
//  TGO
//
//  Created by Brooklyn Daines on 9/19/25.
//


import Foundation
import ActivityKit

struct RunActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic data that changes during the run
        var elapsedTime: TimeInterval
        var splitTime: TimeInterval
        var nextCheckpoint: String
    }

    // Static data that doesn't change
    var routeName: String
}