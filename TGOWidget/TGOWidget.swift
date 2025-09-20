//
//  TGOWidget.swift
//  TGOWidget
//
//  Created by Brooklyn Daines on 9/20/25.
//

import WidgetKit
import SwiftUI

struct TGOWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TGOTrackingAttributes.self) { context in
            // Lock screen/banner UI
            VStack {
                Text(context.attributes.routeName)
                    .font(.headline)
                HStack {
                    Text("Time: \(formatTime(context.state.elapsedTime))")
                    Spacer()
                    Text("Split: \(formatTime(context.state.splitTime))")
                    Spacer()
                    Text("Num total: \(context.attributes.numTotalCheckpoints)")
                    Spacer()
                    Text("Num Complete: \(context.state.numComplete)")
                }
                Text("Next: \(context.state.nextCheckpoint)")
            }
            .padding()
        } dynamicIsland: { context in
            // Dynamic Island UI
            DynamicIsland {
                // Expanded UI
                DynamicIslandExpandedRegion(.leading) {
                    Text("Route: \(context.attributes.routeName)")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Next: \(context.state.nextCheckpoint)")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    VStack {
                        Text("Elapsed Time: \(formatTime(context.state.elapsedTime))")
                        Text("Split Time: \(formatTime(context.state.splitTime))")
                        Text("Num total: \(context.attributes.numTotalCheckpoints)")
                        Text("Num Complete: \(context.state.numComplete)")
                    }
                }
            } compactLeading: {
                Image(systemName: "timer")
            } compactTrailing: {
                Text(formatTime(context.state.elapsedTime))
            } minimal: {
                Image(systemName: "timer")
            }
        }
    }

    private func formatTime(_ interval: TimeInterval) -> String {
        let minutes = Int(interval) / 60
        let seconds = Int(interval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
