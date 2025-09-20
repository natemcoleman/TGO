import ActivityKit
import WidgetKit
import SwiftUI

struct TGOActivityWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: RunActivityAttributes.self) { context in
            // Lock screen/banner UI
            VStack {
                Text(context.attributes.routeName)
                    .font(.headline)
                HStack {
                    Text("Time: \(formatTime(context.state.elapsedTime))")
                    Spacer()
                    Text("Split: \(formatTime(context.state.splitTime))")
                }
                Text("Next: \(context.state.nextCheckpoint)")
            }
            .padding()
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI
                DynamicIslandExpandedRegion(.leading) {
                    Text("Route")
                        .font(.caption)
                    Text(context.attributes.routeName)
                        .font(.headline)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Next")
                        .font(.caption)
                    Text(context.state.nextCheckpoint)
                        .font(.headline)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    VStack {
                        Text("Elapsed Time: \(formatTime(context.state.elapsedTime))")
                        Text("Split Time: \(formatTime(context.state.splitTime))")
                    }
                }
            } compactLeading: {
                Image(systemName: "timer")
                    .foregroundColor(.cyan)
            } compactTrailing: {
                Text(formatTime(context.state.elapsedTime))
                    .foregroundColor(.cyan)
            } minimal: {
                Image(systemName: "timer")
                    .foregroundColor(.cyan)
            }
        }
    }

    private func formatTime(_ interval: TimeInterval) -> String {
        let minutes = Int(interval) / 60
        let seconds = Int(interval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
