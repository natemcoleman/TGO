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
    @State private var routeIsActive = false
    @State private var position: MapCameraPosition = .automatic
//    @State private var position = MapCameraPosition.region(
//        MKCoordinateRegion(
//            center: CLLocationCoordinate2D(latitude: 39.22958751944363, longitude:  -76.8485354177105),
//            span: MKCoordinateSpan(latitudeDelta: 0.025, longitudeDelta: 0.025)
//        )
//    )

//    @State private var userTrackingMode: MapUserTrackingMode = .follow
    let mapSize = 300
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Pin.order, ascending: true)],
        animation: .default)
    private var pins: FetchedResults<Pin>
    var body: some View {
        @StateObject var locationManager = LocationManager()
        
        VStack(){
            Spacer()
            Map(position: $position) {
                ForEach(pins) { pin in
                    let coord = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
                    Annotation(pin.name ?? "Pin", coordinate: coord) {
                        Image(systemName: "flag.circle.fill")
                            .foregroundColor(.green)
                            .padding()
                    }
                        
//                    NavigationLink {
//                        Text("Item at \(item.timestamp!, formatter: itemFormatter)")
//                    } label: {
//                        Text(item.timestamp!, formatter: itemFormatter)
//                    }
                }
                
                
                
//                ForEach(Array(places.enumerated()), id: \.element.id) { (index, place) in
//                    let flagSymbol: String = {
//                        if index == 0 {
//                            return "flag.circle.fill"
//                        } else if index == places.count - 1 {
//                            return "flag.checkered.circle.fill"
//                        } else {
//                            return "flag.circle.fill"
//                        }
//                    }()
//                    let flagColor: Color = {
//                        if index == 0 {
//                            return .green
//                        } else if index == places.count - 1 {
//                            return .black
//                        } else {
//                            return .yellow
//                        }
//                    }()
//                    Marker(place.name, systemImage: flagSymbol, coordinate: place.coordinate)
//                        .tint(flagColor)
//                }
            }
            .edgesIgnoringSafeArea(.all)
            .frame(width: 300, height: 300)
            .cornerRadius(50)
            .shadow(radius: /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)

            Spacer()

            // Table of pins: name and order
            VStack(alignment: .leading) {
                HStack {
                    Text("Name").bold().frame(width: 120, alignment: .leading)
                    Text("Order").bold()
                }
                ForEach(pins) { pin in
                    HStack {
                        Text(pin.name ?? "Unnamed")
                            .frame(width: 120, alignment: .leading)
                        Text("\(pin.order)")
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .shadow(radius: 2)

            Spacer()
            
            Toggle(isOn: $routeIsActive) {
                Image(systemName: routeIsActive ? "flag.pattern.checkered.circle" : "arrowtriangle.right.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100) // Make it much bigger
            }
            .toggleStyle(.button)
            .labelStyle(.iconOnly)
            .contentTransition(.symbolEffect)
            .foregroundColor(routeIsActive ? .black : .green) // Color logic here
            
            Spacer()
        }
    }
}

#Preview {
    HomeView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
