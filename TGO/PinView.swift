//
//  PinView.swift
//  TGO
//
//  Created by Brooklyn Daines on 9/15/25.
//


import SwiftUI

enum pinViewEnum {
    case pinsMap
    case pinsList
}

struct PinView: View {
    @State private var selectedView: pinViewEnum = .pinsMap
    
    var body: some View {
        VStack {
            Picker("Choose a View", selection: $selectedView) {
                Text("Map View").tag(pinViewEnum.pinsMap)
                Text("List View").tag(pinViewEnum.pinsList)
            }
            .pickerStyle(.segmented) // This modifier creates the segmented control UI.
            .padding()
            
            Spacer()
            switch selectedView {
            case .pinsMap:
                PinMapView()
            case .pinsList:
                PinListView()
            }
            
            Spacer()
        }
    }
}

#Preview{
    PinView()
}
