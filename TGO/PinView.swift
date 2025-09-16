//
//  PinView.swift
//  TGO
//
//  Created by Brooklyn Daines on 9/15/25.
//


import SwiftUI

struct PinView: View {

    var body: some View {
        TabView {
            Tab("Map View", systemImage: "sailboat") {
                PinMapView()
            }
            Tab("List View", systemImage: "wind") {
                PinListView()
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
    }
}
