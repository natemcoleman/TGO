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
    
    var onRegionEnter: ((CLRegion) -> Void)?
    var onRegionExit: ((CLRegion) -> Void)?
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        
        manager.allowsBackgroundLocationUpdates = true
        
//        manager.requestWhenInUseAuthorization()
        manager.requestAlwaysAuthorization()
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
        stopMonitoringAllRegions()
    }
    
    func monitorRegions(for routePins: [RoutePin]) {
        stopMonitoringAllRegions()
        
        if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            let radius: CLLocationDistance = 75
            
            for routePin in routePins where routePin.order > 0 {
                guard let pin = routePin.pin else { continue }
                let center = pin.coordinate
                let identifier = "pin_\(routePin.order)"
                
                let region = CLCircularRegion(center: center, radius: radius, identifier: identifier)
                
                // Configure notification based on the RoutePin's `onEnter` property
                if routePin.onEnter {
                    region.notifyOnEntry = true
                    region.notifyOnExit = false
                } else {
                    region.notifyOnEntry = false
                    region.notifyOnExit = true
                }
                
                manager.startMonitoring(for: region)
                print("Monitoring region \(identifier) with notifyOnEntry: \(region.notifyOnEntry), notifyOnExit: \(region.notifyOnExit)")
            }
        }
    }
    
    func stopMonitoringAllRegions() {
        for region in manager.monitoredRegions {
            manager.stopMonitoring(for: region)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        let coordinate = loc.coordinate
        
        if isTracking {
            polylineRoute.append(coordinate)
        }
        
        DispatchQueue.main.async {
            self.userLocation = loc.coordinate
            self.region.center = loc.coordinate
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("✅ Entered region: \(region.identifier)")
        // Execute the callback
        onRegionEnter?(region)
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("✅ Exited region: \(region.identifier)")
        onRegionExit?(region)
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("❌ Monitoring failed for region with identifier: \(region?.identifier ?? "unknown") - \(error.localizedDescription)")
    }
    
}
