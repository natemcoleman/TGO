import SwiftUI
import CoreData

struct LogDetailView: View {
    let log: Log
    @State private var isShowingEditSheet = false

    var body: some View {
        let sortedLoggedPins = (log.loggedPins as? Set<LoggedPin> ?? [])
            .sorted { $0.order < $1.order }
        
        List {
            Section("Summary") {
                HStack {
                    Text("Route")
                    Spacer()
                    Text(log.route?.name ?? "N/A")
                        .foregroundColor(.secondary)
                }
                HStack {
                    Text("Date")
                    Spacer()
                    Text(log.startTime ?? Date(), style: .date)
                        .foregroundColor(.secondary)
                }
                HStack {
                    Text("Total Time")
                    Spacer()
                    Text(formatTime(log.totalTime))
                        .font(.body.monospaced())
                        .foregroundColor(.secondary)
                }
            }

            Section("Checkpoints") {
                ForEach(sortedLoggedPins) { loggedPin in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(loggedPin.pin?.name ?? "Unknown Pin")
                                .font(.headline)
                            Text("Split: \(formatTime(loggedPin.splitTime))")
                                .font(.caption.monospaced())
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Text(formatTime(loggedPin.runningTime))
                            .font(.body.monospaced())
                    }
                }
            }
        }
        .navigationTitle("Run Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Edit") {
                    isShowingEditSheet = true
                }
            }
        }
        .sheet(isPresented: $isShowingEditSheet) {
            EditLogView(log: log)
        }
    }
    
    private func formatTime(_ interval: TimeInterval) -> String {
        let minutes = Int(interval) / 60
        let seconds = Int(interval) % 60
        let milliseconds = Int((interval.truncatingRemainder(dividingBy: 1)) * 100)
        return String(format: "%02d:%02d.%02d", minutes, seconds, milliseconds)
    }
}
