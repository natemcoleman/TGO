//
//  HomeView.swift
//  SpeedRacer
//
//  Created by Brooklyn Daines on 9/5/25.
//


import SwiftUI
import MapKit
import CoreData
import CoreLocation

struct HomeView:View {
    // MARK: - State and Fetch Requests
    @State private var routeIsActive = false
    @State private var position: MapCameraPosition = .automatic
    
    // NEW: State to hold the currently selected route. It's optional.
    @State private var selectedRoute: Route?

    // This fetch request gets all pins (used as a fallback).
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Pin.order, ascending: true)],
        animation: .default)
    private var allPins: FetchedResults<Pin>

    // NEW: Fetch all of your Route entities.
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Route.createdAt, ascending: true)],
        animation: .default)
    private var routes: FetchedResults<Route>
    
    // This was moved from the body to prevent re-initialization
    @StateObject var locationManager = LocationManager()
    
//     NEW: A computed property that extracts the coordinates from the fetched pins.
        private var pinCoordinates: [CLLocationCoordinate2D] {
            allPins.map { $0.coordinate }
        }
    
    // NEW: A computed property to determine which pins to show.
    // If a route is selected, it shows that route's pins, sorted correctly.
    // If no route is selected, it shows all pins.
    private var pinsToShow: [Pin] {
        guard let route = selectedRoute else {
            return Array(allPins)
        }
        
        let routePins = route.routePins as? Set<RoutePin> ?? []
        return routePins
            .sorted { $0.order < $1.order }
            .compactMap { $0.pin }
    }

    // MARK: - Body
    var body: some View {
        VStack {
            Spacer()
            
            // The Map now loops over the 'pinsToShow' computed property.
            Map(position: $position) {
                MapPolyline(coordinates: pinCoordinates)
                                            .stroke(.blue, lineWidth: 5)
                ForEach(pinsToShow) { pin in
                    Annotation(pin.name ?? "Pin", coordinate: pin.coordinate) {
                        Image(systemName: "flag.circle.fill")
                            .foregroundColor(.green)
                            .padding()
                            .shadow(radius: 2)
                    }
                }
            }
            .edgesIgnoringSafeArea(.all)
            .frame(width: 300, height: 300)
            .cornerRadius(50)
            .shadow(radius: 10)
            
            Spacer()

            // NEW: The route selector Picker.
            Picker("Select a Route", selection: $selectedRoute) {
                // Add a "None" option to allow deselecting a route.
                Text("Show All Pins").tag(nil as Route?)
                
                // Loop through all fetched routes.
                ForEach(routes) { route in
                    Text(route.name ?? "Unnamed Route").tag(route as Route?)
                }
            }
            .pickerStyle(.menu) // This makes it a dropdown button.
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .shadow(radius: 2)
            
            Spacer()

            // The list of pins also loops over 'pinsToShow' to stay in sync.
            VStack(alignment: .leading) {
                HStack {
                    Text("Name").bold().frame(width: 120, alignment: .leading)
                    Text("Order").bold()
                }
                ForEach(Array(pinsToShow.enumerated()), id: \.element.id) { index, pin in
                    HStack {
                        Text(pin.name ?? "Unnamed")
                            .frame(width: 120, alignment: .leading)
                        // Use the index from the sorted array for correct order display.
                        Text("\(index + 1)")
                    }
                }
            }
            .padding()

            Spacer()
            
            Toggle(isOn: $routeIsActive) {
                Image(systemName: routeIsActive ? "flag.pattern.checkered.circle" : "arrowtriangle.right.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
            }
            .toggleStyle(.button)
            .labelStyle(.iconOnly)
            .contentTransition(.symbolEffect)
            .foregroundColor(routeIsActive ? .black : .green)
            
            Spacer()
        }
    }
}

//// Helper to make Pin conform to CLLocationCoordinate2D
//extension Pin {
//    var coordinate: CLLocationCoordinate2D {
//        .init(latitude: latitude, longitude: longitude)
//    }
//}

#Preview {
    HomeView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
