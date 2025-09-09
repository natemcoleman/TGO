//
//  RouteView.swift
//  SpeedRacer
//
//  Created by Brooklyn Daines on 9/5/25.
//

import SwiftUI
import MapKit
import CoreData
import CoreLocation

//struct RouteView:View {
////    @EnvironmentObject var session:
//    var body: some View {
//        Text("Routes!")
//    }
//}

struct RouteView:View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        entity: Pin.entity(),
        sortDescriptors: []
    ) var savedPins: FetchedResults<Pin>
    
    @State private var mapRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 39.22958751944363, longitude:  -76.8485354177105), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
    
    @State private var position = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275),
            span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)
        )
    )
//    @State private var userTrackingMode: MapUserTrackingMode = .follow
    @Namespace var mapScope
    @State private var addPin = false
    
    // Convert Core Data to [Place]
    var pins: [Place] {
        savedPins.map {
            Place(
                name: LocalizedStringKey($0.name ?? "Unnamed"),
                coordinate: CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude)
            )
        }
    }
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    @State private var places: [Place] = []
    @State private var pendingCoordinate: CLLocationCoordinate2D? = nil
    @State private var newPlaceName: String = ""
    @State private var showNamePrompt: Bool = false
    
    var body: some View {
        VStack() {
            Spacer()
            MapViewRepresentable(
                region: $region,
                places: $places,
                onCoordinateTapped: { coordinate in
                    pendingCoordinate = coordinate
                    newPlaceName = ""
                    showNamePrompt = true
                }
            )
            .edgesIgnoringSafeArea(.all)
            .alert("Enter a name for this location", isPresented: $showNamePrompt, actions: {
                TextField("Name", text: $newPlaceName)
                Button("Add", action: {
                    if let coordinate = pendingCoordinate, !newPlaceName.isEmpty {
                        places.append(Place(name: LocalizedStringKey(newPlaceName), coordinate: coordinate))
                    }
                    pendingCoordinate = nil
                    newPlaceName = ""
                })
                Button("Cancel", role: .cancel, action: {
                    pendingCoordinate = nil
                    newPlaceName = ""
                })
            })
            Spacer()
        }
    }
    
    // MARK: - Helpers
    
    func savePin(at coordinate: CLLocationCoordinate2D) {
        let newPin = Pin(context: viewContext)
        newPin.id = UUID()
        newPin.latitude = coordinate.latitude
        newPin.longitude = coordinate.longitude
        
        do {
            try viewContext.save()
        } catch {
            print("Failed to save pin: \(error.localizedDescription)")
        }
    }
    
    // Convert CGPoint to map coordinate
    func geoToCoordinate(point: CGPoint, in size: CGSize) -> CLLocationCoordinate2D {
        let span = region.span
        let center = region.center
        
        let x = point.x / size.width - 0.5
        let y = point.y / size.height - 0.5
        
        let newLat = center.latitude - y * span.latitudeDelta
        let newLon = center.longitude + x * span.longitudeDelta
        
        return CLLocationCoordinate2D(latitude: newLat, longitude: newLon)
    }
}

struct Location: Identifiable {
    let id = UUID()
    var name: String
    var coordinate: CLLocationCoordinate2D
}

let MapLocations = [
    MapLocation(name: "St Francis Memorial Hospital", latitude: 37.789467, longitude: -122.416772),
    MapLocation(name: "The Ritz-Carlton, San Francisco", latitude: 37.791965, longitude: -122.406903),
    MapLocation(name: "Honey Honey Cafe & Crepery", latitude: 37.787891, longitude: -122.411223)
]

let locations = [
    Location(name: "Buckingham Palace", coordinate: CLLocationCoordinate2D(latitude: 51.501, longitude: -0.141)),
    Location(name: "Tower of London", coordinate: CLLocationCoordinate2D(latitude: 51.508, longitude: -0.076))
]
