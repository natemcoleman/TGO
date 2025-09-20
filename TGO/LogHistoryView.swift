import SwiftUI
import CoreData

struct LogHistoryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Log.startTime, ascending: false)],
        animation: .default)
    private var logs: FetchedResults<Log>
    
    var body: some View {
        NavigationView {
            if logs.isEmpty {
                VStack {
                    Image(systemName: "list.bullet.clipboard")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                    Text("No Logs Found")
                        .font(.headline)
                        .padding(.top, 8)
                    Text("Complete a run on the Home tab to see your history.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .navigationTitle("History")
            } else {
                List {
                    ForEach(logs) { log in
                        NavigationLink(destination: LogDetailView(log: log)) {
                            LogCardView(log: log)
                        }
                    }
                    .onDelete(perform: deleteLogs) // Enables swipe-to-delete
                }
                .listStyle(InsetGroupedListStyle())
                .navigationTitle("History")
                .toolbar {
                    // Adds the "Edit" button to the navigation bar
                    ToolbarItem(placement: .navigationBarTrailing) {
                        EditButton()
                    }
                }
            }
        }
    }
    
    private func deleteLogs(offsets: IndexSet) {
        withAnimation {
            offsets.map { logs[$0] }.forEach(viewContext.delete)
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

struct LogCardView: View {
    let log: Log
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            //            Text(log.route?.name ?? "Untitled Route")
            //                .font(.headline)
            //                .fontWeight(.bold)
            HStack{
                //                Text(log.startTime ?? Date(), style: .date)
                //                Label("\(log.loggedPins?.count ?? 0) Checkpoints", systemImage: "mappin.and.ellipse")
                ////                    .font(.subheadline)
                ////                    .foregroundColor(.secondary)
                Text(log.route?.name ?? "Untitled Route")
                    .font(.headline)
                    .fontWeight(.bold)
                Spacer()
                //                Text(log.startTime ?? Date(), style: .time)
                Label(formatTime(log.totalTime), systemImage: "timer")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
            }
            Divider()
            HStack {
                //                Label("\(log.loggedPins?.count ?? 0) Checkpoints", systemImage: "mappin.and.ellipse")
                Text(log.startTime ?? Date(), style: .date)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                //                Label(formatTime(log.totalTime), systemImage: "timer")
                Text(log.startTime ?? Date(), style: .time)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }
    
    private func formatTime(_ interval: TimeInterval) -> String {
        let minutes = Int(interval) / 60
        let seconds = Int(interval) % 60
        let milliseconds = Int((interval.truncatingRemainder(dividingBy: 1)) * 100)
        return String(format: "%02d:%02d.%02d", minutes, seconds, milliseconds)
    }
}
