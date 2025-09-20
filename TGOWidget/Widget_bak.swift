////
////  Widget_bak.swift
////  TGO
////
////  Created by Brooklyn Daines on 9/20/25.
////
//
////
////  TGOWidget.swift
////  TGOWidget
////
////  Created by Brooklyn Daines on 9/20/25.
////
//
//import WidgetKit
//import SwiftUI
//
//struct Provider: AppIntentTimelineProvider {
//    func placeholder(in context: Context) -> SimpleEntry {
//        SimpleEntry(date: Date(), configuration: ConfigurationAppIntent())
//    }
//
//    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
//        SimpleEntry(date: Date(), configuration: configuration)
//    }
//    
//    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
//        var entries: [SimpleEntry] = []
//
//        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
//        let currentDate = Date()
//        for hourOffset in 0 ..< 5 {
//            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
//            let entry = SimpleEntry(date: entryDate, configuration: configuration)
//            entries.append(entry)
//        }
//
//        return Timeline(entries: entries, policy: .atEnd)
//    }
//
////    func relevances() async -> WidgetRelevances<ConfigurationAppIntent> {
////        // Generate a list containing the contexts this widget is relevant in.
////    }
//}
//
//struct SimpleEntry: TimelineEntry {
//    let date: Date
//    let configuration: ConfigurationAppIntent
//}
//
//struct TGOWidgetEntryView : View {
//    var entry: Provider.Entry
//
//    var body: some View {
//        VStack {
//            Text("Time:")
//            Text(entry.date, style: .time)
//
//            Text("Favorite Emoji:")
//            Text(entry.configuration.favoriteEmoji)
//        }
//    }
//}
//
////struct TGOWidget: Widget {
////    let kind: String = "TGOWidget"
////
////    var body: some WidgetConfiguration {
////        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
////            TGOWidgetEntryView(entry: entry)
////                .containerBackground(.fill.tertiary, for: .widget)
////        }
////    }
////}
//
//struct TGOWidget: Widget {
//    var body: some WidgetConfiguration {
//        ActivityConfiguration(for: TGOTrackingAttributes.self) { context in
//            // Lock screen/banner UI
//            VStack {
//                Text(context.attributes.routeName)
//                    .font(.headline)
//                HStack {
//                    Text("Time: \(formatTime(context.state.elapsedTime))")
//                    Spacer()
//                    Text("Split: \(formatTime(context.state.splitTime))")
//                }
//                Text("Next: \(context.state.nextCheckpoint)")
//            }
//            .padding()
//        } dynamicIsland: { context in
//            // Dynamic Island UI
//            DynamicIsland {
//                // Expanded UI
//                DynamicIslandExpandedRegion(.leading) {
//                    Text("Route: \(context.attributes.routeName)")
//                }
//                DynamicIslandExpandedRegion(.trailing) {
//                    Text("Next: \(context.state.nextCheckpoint)")
//                }
//                DynamicIslandExpandedRegion(.bottom) {
//                    VStack {
//                        Text("Elapsed Time: \(formatTime(context.state.elapsedTime))")
//                        Text("Split Time: \(formatTime(context.state.splitTime))")
//                    }
//                }
//            } compactLeading: {
//                Image(systemName: "timer")
//            } compactTrailing: {
//                Text(formatTime(context.state.elapsedTime))
//            } minimal: {
//                Image(systemName: "timer")
//            }
//        }
//    }
//
//    private func formatTime(_ interval: TimeInterval) -> String {
//        let minutes = Int(interval) / 60
//        let seconds = Int(interval) % 60
//        return String(format: "%02d:%02d", minutes, seconds)
//    }
//}
//
////struct TGOWidget: Widget {
//////    let kind: String = "TGOWidget"
////
////    var body: some WidgetConfiguration {
////        //        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
////        //            TGOWidgetEntryView(entry: entry)
////        //                .containerBackground(.fill.tertiary, for: .widget)
////        //        }
////        ActivityConfiguration(for: TGOTrackingAttributes.self) {context in
////            TGOTrackingWidgetView(context: context)
////        } dynamicIsland: { context in
////            DynamicIsland {
////                DynamicIslandExpandedRegion(.leading) {
////                    Text("Main")
////                }
////                } compactLeading: {
////                    Text("CL")
////                } compactTrailing: {
////                    Text("CT")
////                } minimal: {
////                    Text("M")
////                }
////            }
////        }
//////    }
////}
//
//
//#Preview(as: .systemSmall) {
//    TGOWidget()
//} timeline: {
//    SimpleEntry(date: .now, configuration: .smiley)
////    SimpleEntry(date: .now, configuration: .starEyes)
//}
