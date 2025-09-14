import SwiftUI
import MapKit
import CoreData
import CoreLocation

struct HomeView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @StateObject private var runViewModel: LiveTrackingViewModel

    @State private var position: MapCameraPosition = .automatic
    @State private var selectedRoute: Route?
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Route.createdAt, ascending: true)])
    private var routes: FetchedResults<Route>
    
    // --- MODIFICATION #1: Update the initializer ---
    // This initializer now uses the context from the environment to create its view model.
    // This ensures the view and its view model are always using the same data store.
    init() {
        let context = PersistenceController.shared.container.viewContext
        _runViewModel = StateObject(wrappedValue: LiveTrackingViewModel(context: context))
    }

    private init(context: NSManagedObjectContext) {
        _runViewModel = StateObject(wrappedValue: LiveTrackingViewModel(context: context))
    }
    // ---------------------------------------------
    
    var body: some View {
        if runViewModel.runState == .inactive {
            setupView
        } else {
            liveRunView
        }
    }

    private var setupView: some View {
        VStack {
            Map(position: $position) {
                if let route = selectedRoute {
                    let routePins = route.routePins as? Set<RoutePin> ?? []
                    let sortedPins = routePins.sorted { $0.order < $1.order }.compactMap { $0.pin }
                    
                    ForEach(sortedPins) { pin in
                        Annotation(pin.name ?? "Pin", coordinate: pin.coordinate) {
                            Image(systemName: "flag.circle.fill")
                                .foregroundColor(.green)
                                .padding()
                                .shadow(radius: 2)
                        }
                    }
                }
            }
            .frame(height: 300)
            .cornerRadius(50)

            Picker("Select a Route", selection: $selectedRoute) {
                Text("Select a Route...").tag(nil as Route?)
                ForEach(routes) { route in
                    Text(route.name ?? "Unnamed Route").tag(route as Route?)
                }
            }
            .padding()

            if let route = selectedRoute {
                let routePins = route.routePins as? Set<RoutePin> ?? []
                let sortedPins = routePins.sorted { $0.order < $1.order }.compactMap { $0.pin }
                
                List(sortedPins) { pin in
                    Text(pin.name ?? "Unnamed Pin")
                }
            }
            
            Spacer()
            
            Button(action: {
                if let route = selectedRoute {
                    runViewModel.startRun(for: route)
                }
            }) {
                Image(systemName: "arrowtriangle.right.circle.fill")
                    .resizable().scaledToFit().frame(width: 100, height: 100)
            }
            .foregroundColor(.green)
            .disabled(selectedRoute == nil)
            
            Spacer()
        }
    }
    
    private var liveRunView: some View {
        VStack {
            Text(formatTime(runViewModel.elapsedTime))
                .font(.system(size: 64, weight: .bold, design: .monospaced))
                .padding()

            List {
                let sortedLoggedPins: [LoggedPin] = {
                    guard let log = runViewModel.activeLog else { return [] }
                    let loggedPinsSet = log.loggedPins as? Set<LoggedPin> ?? []
                    return loggedPinsSet.sorted { $0.order < $1.order }
                }()
                
                ForEach(sortedLoggedPins) { loggedPin in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(loggedPin.pin?.name ?? "Unknown Pin")
                                .font(.headline)
                            Text("Split: \(formatTime(loggedPin.splitTime))")
                                .font(.caption.monospaced())
                        }
                        Spacer()
                        Text(formatTime(loggedPin.runningTime))
                            .font(.body.monospaced())
                    }
                    .listRowBackground(
                        runViewModel.nextSplitIndex == loggedPin.order ? Color.green.opacity(0.2) : Color.clear
                    )
                }
            }
            
            Spacer()
            
            HStack(spacing: 20) {
                Button(action: { runViewModel.finishRun() }) { Text("Stop") }
                    .buttonStyle(.borderedProminent).tint(.red)
                
                Button(action: { runViewModel.splitLap() }) { Text("Split") }
                    .buttonStyle(.borderedProminent).tint(.blue)
            }
            .padding()
        }
    }
    
    private func formatTime(_ interval: TimeInterval) -> String {
        let minutes = Int(interval) / 60
        let seconds = Int(interval) % 60
        let milliseconds = Int((interval.truncatingRemainder(dividingBy: 1)) * 100)
        return String(format: "%02d:%02d.%02d", minutes, seconds, milliseconds)
    }
}

// --- MODIFICATION #2: Update the Preview ---
//// This now creates a special version of HomeView for the preview,
//// ensuring it uses the correct in-memory preview context.
//#Preview {
//    let previewContext = PersistenceController.preview.container.viewContext
//    return HomeView(context: previewContext)
//        .environment(\.managedObjectContext, previewContext)
//}
//// ------------------------------------------
#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
