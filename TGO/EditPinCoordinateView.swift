//
//  EditPinCoordinateView.swift
//  TGO
//
//  Created by Brooklyn Daines on 9/20/25.
//


import SwiftUI
import CoreData

struct EditPinCoordinateView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @ObservedObject var pin: Pin

    @State private var latitudeString: String
    @State private var longitudeString: String

    init(pin: Pin) {
        self.pin = pin
        _latitudeString = State(initialValue: "\(pin.latitude)")
        _longitudeString = State(initialValue: "\(pin.longitude)")
    }

    var body: some View {
        NavigationView {
            Form {
                Section("Coordinates") {
                    TextField("Latitude", text: $latitudeString)
                        .keyboardType(.decimalPad)
                    TextField("Longitude", text: $longitudeString)
                        .keyboardType(.decimalPad)
                }
            }
            .navigationTitle("Edit \(pin.name ?? "Pin")")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: savePin)
                }
            }
        }
    }

    private func savePin() {
        // Validate and convert the string input to Doubles
        if let lat = Double(latitudeString), let lon = Double(longitudeString) {
            pin.latitude = lat
            pin.longitude = lon
            do {
                try viewContext.save()
                dismiss()
            } catch {
                print("Failed to save pin: \(error.localizedDescription)")
            }
        }
    }
}
