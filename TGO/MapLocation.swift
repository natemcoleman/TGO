//
//  MapLocation.swift
//  SpeedRacer
//
//  Created by Brooklyn Daines on 9/5/25.
//

import UIKit
import MapKit

struct MapLocation: Identifiable {
    let id = UUID()
    let name: String
    let latitude: Double
    let longitude: Double
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

import SwiftUI

struct MapViewRepresentable: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    @Binding var places: [Place]
    var onCoordinateTapped: ((CLLocationCoordinate2D) -> Void)? = nil

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapViewRepresentable

        init(_ parent: MapViewRepresentable) {
            self.parent = parent
        }

        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            let mapView = gesture.view as! MKMapView
            let locationInView = gesture.location(in: mapView)
            let coordinate = mapView.convert(locationInView, toCoordinateFrom: mapView)

            // Notify parent instead of adding directly
            parent.onCoordinateTapped?(coordinate)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.setRegion(region, animated: false)
        mapView.showsUserLocation = true
        mapView.delegate = context.coordinator

        // Add tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        mapView.addGestureRecognizer(tapGesture)

        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.removeAnnotations(uiView.annotations)

        let annotations = places.map { place -> MKPointAnnotation in
            let annotation = MKPointAnnotation()
            annotation.coordinate = place.coordinate
//            annotation.title = place.name
            return annotation
        }

        uiView.addAnnotations(annotations)

        // Update region if changed
        if uiView.region.center.latitude != region.center.latitude || uiView.region.center.longitude != region.center.longitude {
            uiView.setRegion(region, animated: true)
        }
    }
}
