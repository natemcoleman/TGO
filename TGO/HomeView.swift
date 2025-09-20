import SwiftUI
import MapKit
import CoreData
//import CoreLocation

struct HomeView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @StateObject private var runViewModel: LiveTrackingViewModel
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
//    @StateObject private var locationManager = LocationManager()
    @State private var savedPolyline: String?
    @State private var decodedRoute: [CLLocationCoordinate2D] = []
    @State private var isEnd: Bool = false
    @State private var polylines: [MKPolyline] = []
    @State private var currSplitIndex = 0
    
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
    
    //    init() {
    //        let context = PersistenceController.shared.container.viewContext
    //        _runViewModel = StateObject(wrappedValue: LiveTrackingViewModel(context: context))
    //    }
    
    //    private init(context: NSManagedObjectContext) {
    //        _runViewModel = StateObject(wrappedValue: LiveTrackingViewModel(context: context))
    //    }
//    init() {
//        let context = PersistenceController.shared.container.viewContext
//        // Create the LocationManager instance first
//        let lm = LocationManager()
//        
//        // Initialize the StateObjects, passing the manager into the view model
//        _locationManager = StateObject(wrappedValue: lm)
//        _runViewModel = StateObject(wrappedValue: LiveTrackingViewModel(context: context, locationManager: lm))
//    }
    init() {
            let context = PersistenceController.shared.container.viewContext
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
        .onAppear {
            setDefaultRoute()
            // Update callbacks to handle both entry and exit events
//            locationManager.onRegionEnter = { region in
//                runViewModel.handleRegionTrigger(identifier: region.identifier)
//            }
//            locationManager.onRegionExit = { region in
//                runViewModel.handleRegionTrigger(identifier: region.identifier)
//            }
        }
        .onChange(of: runViewModel.runState) {
            //            if runViewModel.nextSplitIndex == runViewModel.numPins {
            //                locationManager.stopTracking()
            //                saveRoute()
            //                isEnd = false
            //            }
            if runViewModel.nextSplitIndex == runViewModel.numPins-1{
                isEnd = true
            }
            //            currSplitIndex+=1
//            if runViewModel.runState == .inactive && locationManager.isTracking {
            if runViewModel.runState == .inactive {
//                locationManager.stopTracking()
                saveRoute()
                isEnd = false
                currSplitIndex = 0
            }
        }
    }
    
    private var setupView: some View {
        VStack {
            Spacer()
            Map(position: $position) {
                
                ForEach(polylines, id: \.self) { polyline in
                    MapPolyline(polyline)
                        .stroke(.blue, lineWidth: 3)
                }
                
                if let route = selectedRoute {
                    let routePins = route.routePins as? Set<RoutePin> ?? []
                    let sortedRoutePins = routePins.sorted { $0.order < $1.order }
                    
                    ForEach(sortedRoutePins, id: \.self) { routePin in
                        if let pin = routePin.pin {
                            Annotation(pin.name ?? "Pin", coordinate: pin.coordinate) {
                                Image(systemName: "flag.fill")
                                    .foregroundColor(.black)
                                    .padding()
                                    .shadow(radius: 2)
                            }
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
                updatePolylines()
                updateMapPosition(for: selectedRoute)
            }
            
            if let route = selectedRoute {
                let routePins = route.routePins as? Set<RoutePin> ?? []
                let sortedRoutePins = routePins.sorted { $0.order < $1.order }
                
                List(sortedRoutePins, id: \.self) { routePin in
                    Text("\(routePin.displayName ?? "Checkpoint")")
                }
            }
            
            Spacer()
            
            Button(action: {
                if let route = selectedRoute {
                    let routePins = route.routePins as? Set<RoutePin> ?? []
                    let sortedRoutePins = routePins.sorted { $0.order < $1.order }
                    
//                    locationManager.monitorRegions(for: sortedRoutePins)
                    
                    decodedRoute = [] // Clear old route from map
//                    locationManager.startTracking()
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
//        .onAppear(perform: setDefaultRoute) // Set the default when the view appears
        
    }
    
    private func updatePolylines() {
        guard let route = selectedRoute else {
            polylines = []
            return
        }
        
        let logFetchRequest: NSFetchRequest<Log> = Log.fetchRequest()
        logFetchRequest.predicate = NSPredicate(format: "route == %@", route)
        logFetchRequest.sortDescriptors = [NSSortDescriptor(key: "startTime", ascending: false)]
        logFetchRequest.fetchLimit = 5
        
        do {
            let recentLogs = try viewContext.fetch(logFetchRequest)
            var newPolylines: [MKPolyline] = []
            
            for log in recentLogs {
                // Ensure the log has a polyline string and it's not empty
                if let encodedPolyline = log.polyline, !encodedPolyline.isEmpty {
                    // Decode the polyline string to get coordinates
                    let decodedCoordinates = Polyline.decode(polyline: encodedPolyline)
                    //                    let decodedCoordinates = Polyline(encodedPolyline: encodedPolyline).coordinates
                    
                    if decodedCoordinates.count > 1 {
                        let polyline = MKPolyline(coordinates: decodedCoordinates, count: decodedCoordinates.count)
                        newPolylines.append(polyline)
                    }
                }
            }
            self.polylines = newPolylines
        } catch {
            print("Failed to fetch logs: \(error)")
        }
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
        if selectedRoute == nil {
            if let firstRoute = routes.first {
                selectedRoute = firstRoute
            } else {
                let newRoute = Route(context: viewContext)
                newRoute.name = "My First Route"
                newRoute.createdAt = Date()
                
                do {
                    try viewContext.save()
                    selectedRoute = newRoute
                } catch {
                    print("Failed to create and save backup route: \(error)")
                }
            }
        }
    }
    
    private var liveRunView: some View {
        VStack {
            Spacer()
            Map(position: $position) { //, interactionModes: []
//                if !locationManager.polylineRoute.isEmpty {
//                    MapPolyline(coordinates: locationManager.polylineRoute)
//                        .stroke(.blue, lineWidth: 5)
//                }
                if !runViewModel.polylineRoute.isEmpty {
                    MapPolyline(coordinates: runViewModel.polylineRoute)
                        .stroke(.blue, lineWidth: 5)
                }
                
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
                UserAnnotation()
            }
            .cornerRadius(50)
            .frame(width: 400, height: 200)
            .mapControls{MapUserLocationButton()}
            .mapStyle(.standard(pointsOfInterest: .excluding(.store)))
            
            VStack{
                Text(formatTime(runViewModel.splitTime))
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                Text(formatTime(runViewModel.elapsedTime))
                    .font(.system(size: 24, design: .rounded))
            }
            
            ScrollViewReader { proxy in
                List {
                    let sortedLoggedPins: [LoggedPin] = {
                        guard let log = runViewModel.activeLog else { return [] }
                        let loggedPinsSet = log.loggedPins as? Set<LoggedPin> ?? []
                        return loggedPinsSet.sorted { $0.order < $1.order }
                    }()
                    
                    ForEach(sortedLoggedPins) { loggedPin in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(loggedPin.displayName ?? loggedPin.pin?.name ?? "Unknown Pin")
                                    .font(.headline)
                                Text("Time: \(formatTime(loggedPin.runningTime))")
                                    .font(.caption.monospaced())
                            }
                            Spacer()
                            Text(formatTime(loggedPin.splitTime))
                                .font(.body.monospaced())
                        }
                        .id(loggedPin.order) // 1. Assign an ID to each row
                        .listRowBackground(
                            runViewModel.nextSplitIndex == loggedPin.order ? Color.green.opacity(0.2) : Color.clear
                        )
                    }
                }
                //                .onChange(of: runViewModel.nextSplitIndex) { // 2. Detect when the index changes
                //                    print("Trying to scroll.")
                //                    withAnimation {
                //                        proxy.scrollTo(runViewModel.nextSplitIndex, anchor: .center)
                //                    }
                //                }
            }
                        
            HStack(spacing: 20) {
                Button(action: {
                    if runViewModel.nextSplitIndex == runViewModel.numPins {
//                        locationManager.stopTracking()
                        saveRoute()
                        isEnd = false
                    }
                    if runViewModel.nextSplitIndex == runViewModel.numPins-1{
                        isEnd = true
                    }
                    currSplitIndex+=1
                    runViewModel.splitLap()
                })
                {
                    if isEnd {
                        Image(systemName: "flag.checkered")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 400, height: 50)
                    } else {
                        Image(systemName: "stopwatch")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 400, height: 50)
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(isEnd ? .black : .green)
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
//        let polyline = Polyline.encode(coordinates: locationManager.polylineRoute)
        let polyline = Polyline.encode(coordinates: runViewModel.polylineRoute)
        runViewModel.activeLog?.polyline = polyline
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
