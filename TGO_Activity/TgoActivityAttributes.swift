//
//  TgoActivityAttributes.swift
//  TGO
//
//  Created by Brooklyn Daines on 9/19/25.
//


import Foundation
import ActivityKit

struct TgoActivityAttributes: ActivityAttributes {
    // The ContentState must be defined inside the struct.
    public struct ContentState: Codable, Hashable {
        // Data that updates during the activity
        var currentCheckpoint: String
        var nextCheckpoint: String
        var elapsedTime: String
    }

    // Data that doesn't change (static attributes)
    var routeName: String
}
