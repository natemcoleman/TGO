//
//  TGO_ActivityLiveActivity.swift
//  TGO_Activity
//
//  Created by Brooklyn Daines on 9/19/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct TGO_ActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct TGO_ActivityLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TGO_ActivityAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension TGO_ActivityAttributes {
    fileprivate static var preview: TGO_ActivityAttributes {
        TGO_ActivityAttributes(name: "World")
    }
}

extension TGO_ActivityAttributes.ContentState {
    fileprivate static var smiley: TGO_ActivityAttributes.ContentState {
        TGO_ActivityAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: TGO_ActivityAttributes.ContentState {
         TGO_ActivityAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: TGO_ActivityAttributes.preview) {
   TGO_ActivityLiveActivity()
} contentStates: {
    TGO_ActivityAttributes.ContentState.smiley
    TGO_ActivityAttributes.ContentState.starEyes
}
