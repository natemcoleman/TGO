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
            RouteView2().tabItem {
                Image(systemName: "point.bottomleft.forward.to.point.topright.filled.scurvepath")
            }.tag(2)
//                .ignoresSafeArea()
        }
        .ignoresSafeArea()
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
