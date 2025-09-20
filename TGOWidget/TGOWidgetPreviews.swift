//
//  TGOActivityWidget.swift
//  TGO
//
//  Created by Brooklyn Daines on 9/20/25.
//


import SwiftUI
import WidgetKit
import ActivityKit

// 1. Define sample data for your previews
let previewAttributes = TGOTrackingAttributes(routeName: "Morning Commute", numTotalCheckpoints: 5)
let previewContentState = TGOTrackingAttributes.ContentState(
    elapsedTime: 365, // 6 minutes 5 seconds
    splitTime: 123,   // 2 minutes 3 seconds
    nextCheckpoint: "Patuxent Light",
    numComplete: 2
)

// 2. Create the preview for your Live Activity
struct TGOActivityWidget_Previews: PreviewProvider {
    static var previews: some View {
        // --- Dynamic Island Previews ---

        // Expanded Dynamic Island
        previewAttributes
            .previewContext(previewContentState, viewKind: .dynamicIsland(.expanded))
            .previewDisplayName("Dynamic Island (Expanded)")

        // Compact Dynamic Island
        previewAttributes
            .previewContext(previewContentState, viewKind: .dynamicIsland(.compact))
            .previewDisplayName("Dynamic Island (Compact)")

        // Minimal Dynamic Island
        previewAttributes
            .previewContext(previewContentState, viewKind: .dynamicIsland(.minimal))
            .previewDisplayName("Dynamic Island (Minimal)")

        // --- Lock Screen Previews ---
        
        previewAttributes
            .previewContext(previewContentState, viewKind: .content)
            .previewDisplayName("Lock Screen")
    }
}
