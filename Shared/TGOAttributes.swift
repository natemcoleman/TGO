//
//  TGOAttributes.swift
//  TGO
//
//  Created by Brooklyn Daines on 9/19/25.
//

// 1.
import ActivityKit
import Foundation

// 2.
struct PrintingAttributes: ActivityAttributes {
    
    // 3.
    public struct ContentState: Codable, Hashable {
        var progress: Double
        var elapsedTime: TimeInterval
        var statusMessage: String
    }
    
    // 4.
    var printName: String
    var estimatedDuration: TimeInterval
}
