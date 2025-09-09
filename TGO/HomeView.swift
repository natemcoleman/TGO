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
    //    @State private var position: MapCameraPosition = .automatic
    @State private var position = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 39.22958751944363, longitude:  -76.8485354177105),
            span: MKCoordinateSpan(latitudeDelta: 0.025, longitudeDelta: 0.025)
        )
    )
    // Array of custom locations
    let places: [Place] = [
        Place(name: "Home", coordinate: CLLocationCoordinate2D(latitude: 39.22958751944363, longitude:  -76.8485354177105)),
        Place(name: "Patuxent Light", coordinate: CLLocationCoordinate2D(latitude: 39.22589744964121, longitude: -76.85535359298007)),
        Place(name: "29 Light", coordinate: CLLocationCoordinate2D(latitude: 39.17386677510497, longitude: -76.88125300327637)),
        Place(name: "Hopkins Road Light", coordinate: CLLocationCoordinate2D(latitude: 39.15944302100448, longitude: -76.89335513031924)),
        Place(name: "APL", coordinate: CLLocationCoordinate2D(latitude: 39.16167249112726, longitude: -76.89963149940631))
    ]
//    @State private var userTrackingMode: MapUserTrackingMode = .follow
    let mapSize = 300
    var body: some View {
        @StateObject var locationManager = LocationManager()
        
        VStack(){
            Spacer()
            Map(position: $position) {
                ForEach(Array(places.enumerated()), id: \.element.id) { (index, place) in
                    let flagSymbol: String = {
                        if index == 0 {
                            return "flag.circle.fill"
                        } else if index == places.count - 1 {
                            return "flag.checkered.circle.fill"
                        } else {
                            return "flag.circle.fill"
                        }
                    }()
                    let flagColor: Color = {
                        if index == 0 {
                            return .green
                        } else if index == places.count - 1 {
                            return .black
                        } else {
                            return .yellow
                        }
                    }()
                    Marker(place.name, systemImage: flagSymbol, coordinate: place.coordinate)
                        .tint(flagColor)
                }
            }
            .edgesIgnoringSafeArea(.all)
            .frame(width: 300, height: 300)
            .cornerRadius(50)
            .shadow(radius: /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)

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
