//
//  LocationManager.swift
//  SpeedRacer
//
//  Created by Brooklyn Daines on 9/5/25.
//

import SwiftUI
import MapKit
import CoreLocation

// MARK: - Custom Location Struct
struct Place: Identifiable {
    let id = UUID()
    let name: LocalizedStringKey
    let coordinate: CLLocationCoordinate2D
}

// MARK: - Location Manager (for user location)
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 39.22958751944363, longitude:  -76.8485354177105), // default center
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    @Published var userLocation: CLLocationCoordinate2D?
    @Published var polylineRoute: [CLLocationCoordinate2D] = []
    @Published var isTracking = false

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        // If you want always authorization, uncomment the next line:
        // manager.requestAlwaysAuthorization()
        manager.startUpdatingLocation()
    }
    
    func startTracking() {
        polylineRoute = []
        isTracking = true
        manager.startUpdatingLocation()
    }

    func stopTracking() {
        isTracking = false
        manager.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        let coordinate = loc.coordinate
        polylineRoute.append(coordinate)
        DispatchQueue.main.async {
            self.userLocation = loc.coordinate
            self.region.center = loc.coordinate
        }
    }
}
