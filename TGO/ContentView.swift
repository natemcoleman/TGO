//
//  ContentView.swift
//  TGO
//
//  Created by Brooklyn Daines on 9/6/25.
//

import SwiftUI
import CoreData
import MapKit
import CoreLocation

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView().tabItem { Image(systemName: "house")
            }.tag(1)
//                .ignoresSafeArea()
//            AnalyticsView().tabItem {
//                Image(systemName: "chart.bar.xaxis")
//            }.tag(2)
//                .ignoresSafeArea()
//            PinMapView().tabItem {
//                Image(systemName: "mappin.and.ellipse.circle")
//            }.tag(2)
////                .ignoresSafeArea()
            RouteListView().tabItem {
                Image(systemName: "point.bottomleft.forward.to.point.topright.filled.scurvepath")
            }.tag(3)
//                .ignoresSafeArea()
        }
        .ignoresSafeArea()
        .padding(.top)
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
