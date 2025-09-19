//
//  TgoLiveActivity.swift
//  TGO
//
//  Created by Brooklyn Daines on 9/19/25.
//


import WidgetKit
import SwiftUI

//@main
struct TgoLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TgoActivityAttributes.self) { context in
            // MARK: Lock Screen and Banner UI
            VStack(alignment: .leading) {
                HStack {
                    Text(context.attributes.routeName)
                        .font(.headline)
                    Spacer()
                    Text(context.state.elapsedTime)
                        .font(.title.monospaced())
                }
                .padding(.bottom, 8)
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("Current")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(context.state.currentCheckpoint)
                    }
                    Spacer()
                    Image(systemName: "arrow.right")
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("Next")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(context.state.nextCheckpoint)
                    }
                }
            }
            .padding()

        } dynamicIsland: { context in
            // MARK: Dynamic Island UI
            DynamicIsland {
                // Expanded UI
                DynamicIslandExpandedRegion(.leading) {
                    Text("Current")
                        .font(.caption)
                    Text(context.state.currentCheckpoint)
                        .font(.headline)
                }
                DynamicIslandExpandedRegion(.trailing) {
                     Text("Next")
                        .font(.caption)
                    Text(context.state.nextCheckpoint)
                        .font(.headline)
                }
                DynamicIslandExpandedRegion(.center) {
                    Text(context.state.elapsedTime)
                        .font(.title.monospaced())
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Route: \(context.attributes.routeName)")
                }
                
            } compactLeading: {
                Image(systemName: "timer")
                    .foregroundColor(.green)
            } compactTrailing: {
                Text(context.state.elapsedTime)
                    .monospaced()
                    .foregroundColor(.green)
            } minimal: {
                Image(systemName: "stopwatch")
                    .foregroundColor(.green)
            }
        }
    }
}

//#Preview("Live Activity", as: .content, using: TgoActivityAttributes.self) {
//    TgoLiveActivity()
//} contentStates: {
//    // This defines the data for the preview
//    TgoActivityAttributes.ContentState(
//        currentCheckpoint: "Patuxent Light",
//        nextCheckpoint: "29 Light",
//        elapsedTime: "02:35.16"
//    )
//}

//#Preview(as: .dynamicIsland(.expanded), using: TgoActivityAttributes.init(routeName: "Test Route")) {
//    TgoLiveActivity()
//} contentStates: {
//    TgoActivityAttributes.ContentState(
//        currentCheckpoint: "Patuxent Light",
//        nextCheckpoint: "29 Light",
//        elapsedTime: "02:35.16"
//    )
//}
