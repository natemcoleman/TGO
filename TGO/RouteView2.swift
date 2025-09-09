//
//  RouteView2.swift
//  SpeedRacer
//
//  Created by Brooklyn Daines on 9/6/25.
//

import SwiftUI
import MapKit
import CoreData

struct RouteView2: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var isAddingMode = false
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 39.22958751944363, longitude:  -76.8485354177105),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    
    // Fetch existing waypoints to display on map
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Pin.id, ascending: true)],
        animation: .default)
    private var pins: FetchedResults<Pin>

    var body: some View {
        NavigationView {
            ZStack {
                // Map View
                MapReader { proxy in
                    Map(coordinateRegion: $region, annotationItems: pins) { pin in
                        MapPin(coordinate: pin.coordinate, tint: .red)
                    }
//                    .onTapGesture { location in
//                        if isAddingMode {
//                            addWaypoint(at: proxy.convert(location, from: .local))
//                        }
//                    }
                }
                
                // Controls overlay
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        
                        // Toggle button for adding mode
                        Button(action: {
                            isAddingMode.toggle()
                        }) {
                            Image(systemName: isAddingMode ? "plus.circle.fill" : "plus.circle")
                                .font(.title)
                                .foregroundColor(isAddingMode ? .green : .blue)
                                .background(Color.white.opacity(0.8))
                                .clipShape(Circle())
                                .shadow(radius: 4)
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 100)
                    }
                    
                    // Status indicator
                    if isAddingMode {
                        Text("Tap on the map to add waypoint")
                            .padding()
                            .background(Color.black.opacity(0.7))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.bottom, 20)
                    }
                }
            }
            .navigationTitle("Add Waypoints")
            .navigationBarTitleDisplayMode(.inline)
            .frame(width: 400, height: 600) // Sets a fixed width and height
            .cornerRadius(50)
            .shadow(radius: /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
        }
    }
    
    private func addWaypoint(at coordinate: CLLocationCoordinate2D) {
        // Create new Pin entity
        let newPin = Pin(context: viewContext)
        newPin.id = UUID()
        newPin.latitude = coordinate.latitude
        newPin.longitude = coordinate.longitude
        
        // Save to Core Data
        do {
            try viewContext.save()
            print("Waypoint added at \(coordinate.latitude), \(coordinate.longitude)")
        } catch {
            print("Failed to save waypoint: \(error)")
        }
    }
    
    private func deletePin(_ pin: Pin) {
        viewContext.delete(pin)
        
        do {
            try viewContext.save()
            print("Waypoint deleted")
        } catch {
            print("Failed to delete waypoint: \(error)")
        }
    }
    private func convertCGPointToCLLocationCoordinate2D(point: CGPoint, mapView: MKMapView) -> CLLocationCoordinate2D {
        let coordinate = mapView.convert(point, toCoordinateFrom: nil)
        return coordinate
    }
}

// Extension to make Pin work with MapKit
extension Pin {
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

// Preview
struct AddWaypointView_Previews: PreviewProvider {
    static var previews: some View {
        RouteView2()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

//// Example Core Data setup (if you need it)
//class PersistenceController {
//    static let shared = PersistenceController()
//    static let preview = PersistenceController(inMemory: true)
//
//    let container: NSPersistentContainer
//
//    init(inMemory: Bool = false) {
//        container = NSPersistentContainer(name: "DataModel") // Replace with your model name
//        
//        if inMemory {
//            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
//        }
//        
//        container.loadPersistentStores { _, error in
//            if let error = error as NSError? {
//                fatalError("Unresolved error \(error), \(error.userInfo)")
//            }
//        }
//    }
//}
