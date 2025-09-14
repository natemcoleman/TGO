import SwiftUI
import CoreData

struct EditLogView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    let log: Log
    
    private struct EditableLoggedPin: Identifiable {
        let id: NSManagedObjectID
        let pinName: String
        var runningTimeString: String
        var splitTimeString: String
    }
    
    @State private var editablePins: [EditableLoggedPin] = []
    @State private var totalTimeString: String

    init(log: Log) {
        self.log = log
        // Call the helper using `Self.formatTime` because it is now a static function.
        _totalTimeString = State(initialValue: Self.formatTime(log.totalTime))
    }

    var body: some View {
        NavigationView {
            Form {
                Section("Total Time") {
                    TextField("Total Time", text: $totalTimeString)
                        .keyboardType(.decimalPad)
                }
                
                Section("Splits") {
                    ForEach($editablePins) { $pin in
                        VStack(alignment: .leading) {
                            Text(pin.pinName).font(.headline)
                            HStack {
                                Text("Running:")
                                TextField("Time", text: $pin.runningTimeString)
                                    .keyboardType(.decimalPad)
                            }
                            HStack {
                                Text("Split:")
                                TextField("Time", text: $pin.splitTimeString)
                                    .keyboardType(.decimalPad)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Edit Log")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: saveChanges)
                }
            }
            .onAppear(perform: loadData)
        }
    }
    
    private func loadData() {
        let sortedLoggedPins = (log.loggedPins as? Set<LoggedPin> ?? [])
            .sorted { $0.order < $1.order }
        
        editablePins = sortedLoggedPins.map { loggedPin in
            EditableLoggedPin(
                id: loggedPin.objectID,
                pinName: loggedPin.pin?.name ?? "Unknown Pin",
                runningTimeString: Self.formatTime(loggedPin.runningTime), // Use Self.formatTime
                splitTimeString: Self.formatTime(loggedPin.splitTime)   // Use Self.formatTime
            )
        }
    }
    
    private func saveChanges() {
        // Update the main log's total time
        log.totalTime = Self.parseTime(totalTimeString) // Use Self.parseTime
        
        // Update each individual LoggedPin
        for editablePin in editablePins {
            if let loggedPin = try? viewContext.existingObject(with: editablePin.id) as? LoggedPin {
                loggedPin.runningTime = Self.parseTime(editablePin.runningTimeString) // Use Self.parseTime
                loggedPin.splitTime = Self.parseTime(editablePin.splitTimeString)   // Use Self.parseTime
            }
        }
        
        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Failed to save edited log: \(error.localizedDescription)")
        }
    }
    
    // --- MODIFIED: Added the 'static' keyword ---
    // This makes the function associated with the EditLogView type, not an instance.
    private static func formatTime(_ interval: TimeInterval) -> String {
        let minutes = Int(interval) / 60
        let seconds = Int(interval) % 60
        let milliseconds = Int((interval.truncatingRemainder(dividingBy: 1)) * 100)
        return String(format: "%02d:%02d.%02d", minutes, seconds, milliseconds)
    }
    
    // --- MODIFIED: Added the 'static' keyword ---
    private static func parseTime(_ timeString: String) -> TimeInterval {
        let components = timeString.replacingOccurrences(of: ":", with: ".")
            .split(separator: ".").compactMap { Double($0) }
        guard components.count == 3 else { return 0 }
        let minutes = components[0]
        let seconds = components[1]
        let milliseconds = components[2]
        return (minutes * 60) + seconds + (milliseconds / 100)
    }
}
