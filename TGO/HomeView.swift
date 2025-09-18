import SwiftUI
import MapKit
import CoreData
import CoreLocation

struct HomeView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @StateObject private var runViewModel: LiveTrackingViewModel
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
    @StateObject private var locationManager = LocationManager()
    @State private var savedPolyline: String?
    @State private var decodedRoute: [CLLocationCoordinate2D] = []
    @State private var isEnd: Bool = false
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Route.createdAt, ascending: true)])
    private var routes: FetchedResults<Route>
    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Pin.order, ascending: true)
        ],
        animation: .default
    )
    private var allPins: FetchedResults<Pin>
    
    @State private var selectedRoute: Route?
    
    init() {
        let context = PersistenceController.shared.container.viewContext
        _runViewModel = StateObject(wrappedValue: LiveTrackingViewModel(context: context))
    }
    
    private init(context: NSManagedObjectContext) {
        _runViewModel = StateObject(wrappedValue: LiveTrackingViewModel(context: context))
    }
    
    var body: some View {
        VStack{
            Spacer()
            if runViewModel.runState == .inactive {
                setupView
            } else {
                liveRunView
            }
        }
    }
    
    private var setupView: some View {
        VStack {
            Spacer()
            Map(position: $position) { //, interactionModes: []
//                if !locationManager.polylineRoute.isEmpty {
//                    MapPolyline(coordinates: locationManager.polylineRoute)
//                        .stroke(.blue, lineWidth: 5)
//                }
                
                
                if let route = selectedRoute {
                    let routePins = route.routePins as? Set<RoutePin> ?? []
                    let sortedPins = routePins.sorted { $0.order < $1.order }.compactMap { $0.pin }
                    
                    ForEach(sortedPins) { pin in
                        Annotation(pin.name ?? "Pin", coordinate: pin.coordinate) {
                            Image(systemName: "flag.fill")
                                .foregroundColor(.black)
                                .padding()
                                .shadow(radius: 2)
                        }
                    }
                }
                else{
                    ForEach(allPins) { pin in
                        Annotation(pin.name ?? "Pin", coordinate: pin.coordinate) {
                            Image(systemName: "flag.fill")
                                .foregroundColor(.black)
                                .padding()
                                .shadow(radius: 2)
                        }
                    }
                }
                UserAnnotation()
            }
            .cornerRadius(50)
            .frame(width: 400, height: 300)
            .shadow(radius: 10)
            .mapControls{MapUserLocationButton()}
            .mapStyle(.standard(pointsOfInterest: .excluding(.store)))
            
            Spacer()
            
            Picker("Select a Route", selection: $selectedRoute) {
                Text("Select a Route").tag(nil as Route?)
                ForEach(routes) { route in
                    Text(route.name ?? "Unnamed Route").tag(route as Route?)
                }
            }
            .padding()
            .background(Color(UIColor.systemGray6))
            .cornerRadius(12)
            .onChange(of: selectedRoute) {
                updateMapPosition(for: selectedRoute)
            }
            
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
                    decodedRoute = [] // Clear old route from map
                    locationManager.startTracking()
                    runViewModel.startRun(for: route)
                }
            }) {
                Image(systemName: "arrowtriangle.right.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
            }
            .foregroundColor(.green)
            .disabled(selectedRoute == nil)
            
            Spacer()
        }
        .onAppear(perform: setDefaultRoute) // Set the default when the view appears
        
    }
    private func updateMapPosition(for route: Route?) {
        guard let route = route else {
            position = .userLocation(fallback: .automatic)
            return
        }
        
        let routePins = route.routePins as? Set<RoutePin> ?? []
        let coordinates = routePins.compactMap { (routePin) -> CLLocationCoordinate2D? in
            guard let pin = routePin.pin else { return nil }
            return CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
        }
        
        guard !coordinates.isEmpty else {
            position = .userLocation(fallback: .automatic)
            return
        }
        
        if coordinates.count == 1 {
            let region = MKCoordinateRegion(center: coordinates[0], span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
            position = .region(region)
            return
        }
        
        let minLat = coordinates.map { $0.latitude }.min()!
        let maxLat = coordinates.map { $0.latitude }.max()!
        let minLon = coordinates.map { $0.longitude }.min()!
        let maxLon = coordinates.map { $0.longitude }.max()!
        
        let center = CLLocationCoordinate2D(latitude: (minLat + maxLat) / 2, longitude: (minLon + maxLon) / 2)
        
        let span = MKCoordinateSpan(latitudeDelta: (maxLat - minLat) * 1.4, longitudeDelta: (maxLon - minLon) * 1.4)
        
        let region = MKCoordinateRegion(center: center, span: span)
        
        withAnimation {
            position = .region(region)
        }
    }
    private func setDefaultRoute() {
        // This check ensures we only set the default once.
        if selectedRoute == nil {
            if let firstRoute = routes.first {
                // If routes exist, pick the first one from the already fetched list.
                selectedRoute = firstRoute
            } else {
                // If no routes exist, create and save a new one as a backup.
                let newRoute = Route(context: viewContext)
                newRoute.name = "My First Route"
                newRoute.createdAt = Date()
                
                do {
                    try viewContext.save()
                    // Set the newly created route as the selection.
                    selectedRoute = newRoute
                } catch {
                    print("Failed to create and save backup route: \(error)")
                }
            }
        }
    }
    
    private var liveRunView: some View {
        VStack {
            VStack{
                Text(formatTime(runViewModel.splitTime))
                    .font(.system(size: 64, weight: .bold, design: .rounded))
                    .padding()
                Text(formatTime(runViewModel.elapsedTime))
                    .font(.system(size: 32, design: .rounded))
                    .padding()
            }
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
                            Text("Split: \(formatTime(loggedPin.runningTime))")
                            //                                .font(.caption.rounded())
                        }
                        Spacer()
                        Text(formatTime(loggedPin.splitTime))
                        //                            .font(.body.rounded())
                    }
                    .listRowBackground(
                        runViewModel.nextSplitIndex == loggedPin.order ? Color.green.opacity(0.2) : Color.clear
                    )
                }
            }
            
            Spacer()
            
            HStack(spacing: 20) {
                Button(action: {
                    runViewModel.finishRun()
                    locationManager.stopTracking()
                    saveRoute()
                })
                {
                    Image(systemName: "stop.circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                }
                .buttonStyle(.borderedProminent).tint(.red)
                
                Button(action: {
                    runViewModel.splitLap()
                    if runViewModel.nextSplitIndex == runViewModel.numPins {
                        locationManager.stopTracking()
                        saveRoute()
                    }
                    if runViewModel.nextSplitIndex == runViewModel.numPins{
                        isEnd = true
                    }
                })
                {
//                    Image(systemName: "stopwatch")
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 100, height: 100)
                    if isEnd {
                            Image(systemName: "flag.checkered")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                        } else {
                            Image(systemName: "stopwatch")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                        }
                }
                .buttonStyle(.borderedProminent)
                .tint(isEnd ? .black : .green)
//                .buttonStyle(.borderedProminent).tint(.green)
            }
            .padding()
            
            Spacer()
        }
    }
    
    private func formatTime(_ interval: TimeInterval) -> String {
        let minutes = Int(interval) / 60
        let seconds = Int(interval) % 60
        //        let milliseconds = Int((interval.truncatingRemainder(dividingBy: 1)) * 100)
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func saveRoute() {
        let polyline = Polyline.encode(coordinates: locationManager.polylineRoute)
        runViewModel.activeLog?.polyline = polyline
//        UserDefaults.standard.set(polyline, forKey: polylineKey)
//        self.savedPolyline = polyline
//        print("Route saved! Polyline: \(polyline)")
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
