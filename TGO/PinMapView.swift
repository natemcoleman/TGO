//
//  PinMapView.swift
//  TGO
//
//  Created by Brooklyn Daines on 9/12/25.
//

import CoreData
import MapKit
import SwiftUI

enum MapMode {
    case none
    case adding
    case deleting
    case dragging
}

struct PinMapView: View {
    // MARK: - Core Data
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Pin.order, ascending: true)
        ],
        animation: .default
    )
    private var pins: FetchedResults<Pin>

    // MARK: - State Properties
    @State private var mode: MapMode = .none
    @State private var position: MapCameraPosition = .automatic

    // State for handling the "add pin" flow
    @State private var showNameAlert = false
    @State private var newPinName = ""
    @State private var tappedCoordinate: CLLocationCoordinate2D?

    // State to keep track of the pin being actively dragged
    @State private var draggedPin: Pin?
    @State private var isDragging = false

    // MARK: - Body
    var body: some View {
        
        NavigationView {
            ZStack {
                MapReader { proxy in
                    Map(position: $position) {
                        ForEach(pins) { pin in
                            Annotation(
                                pin.name ?? "Unnamed Pin",
                                coordinate: pin.coordinate
                            ) {
                                pinAnnotationView(for: pin)
                                    .gesture(
                                        // Only allow dragging when in .none or .dragging mode
                                        mode == .none || mode == .dragging
                                            ? dragGesture(for: pin, in: proxy)
                                            : nil
                                    )
                                    .onTapGesture {
                                        if mode == .deleting {
                                            deletePin(pin)
                                        }
                                        print("Tapping pin")
                                    }
                            }
                        }
                    }
                    .onTapGesture { screenPosition in
                        guard mode == .adding else { return }
                        if let coordinate = proxy.convert(
                            screenPosition,
                            from: .local
                        ) {
                            tappedCoordinate = coordinate
                            showNameAlert = true
                        }
                    }
                }
                //            .ignoresSafeArea()
                .frame(width: 400, height: 600)  // Sets a fixed width and height
                .cornerRadius(50)
                .shadow(
                    radius: /*@START_MENU_TOKEN@*/ 10 /*@END_MENU_TOKEN@*/
                )

                // UI Overlays (Buttons and Mode Indicator)
                VStack {
                    Spacer()

                    if mode != .none {
                        modeIndicator
                    }

                    HStack(spacing: 20) {
                        modeButton(systemName: "plus", for: .adding)
                        modeButton(systemName: "minus", for: .deleting)
                    }
                    .padding()
                    .background(.thinMaterial)
                    .cornerRadius(15)
                    .shadow(radius: 5)
                    .padding(.bottom)
                }
            }
            .alert("Name Your Pin", isPresented: $showNameAlert) {
                TextField("Enter pin name", text: $newPinName)
                Button("Save") {
                    if let coordinate = tappedCoordinate {
                        addPin(at: coordinate, name: newPinName)
                    }
                    resetAddPinFlow()
                }
                Button("Cancel", role: .cancel) {
                    resetAddPinFlow()
                }
            } message: {
                Text("Please provide a name for your new map location.")
            }
            .navigationTitle("Map Pins")
            .navigationBarTitleDisplayMode(.inline)
            // Moved this to tab view
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    NavigationLink(destination: PinListView()) {
//                        Image(systemName: "list.bullet")
//                    }
//                }
//            }
        }
    }

    // MARK: - Drag Gesture Logic
    private func dragGesture(for pin: Pin, in proxy: MapProxy) -> some Gesture {
        DragGesture()
            .onChanged { value in
                // Set the current pin as the one being dragged
                draggedPin = pin
                isDragging = true
                mode = .dragging
                print("Dragging pin")
                // Convert the drag gesture's screen location to a map coordinate
                if let newCoordinate = proxy.convert(
                    value.location,
                    from: .local
                ) {
                    // Update the pin's location in the Core Data context
                    pin.latitude = newCoordinate.latitude
                    pin.longitude = newCoordinate.longitude
                }
            }
            .onEnded { _ in
                // Save the final position to Core Data
                saveContext()

                // Reset dragging state
                draggedPin = nil
                isDragging = false
                mode = .none
            }
    }

    // MARK: - Subviews

    /// Provides a view for the pin, making it larger if it's being dragged.
    private func pinAnnotationView(for pin: Pin) -> some View {
        Image(systemName: "mappin.and.ellipse")
            .font(.title)
            .foregroundStyle(.white, .red)
            .shadow(radius: 2)
            // Add visual feedback for the dragged pin
            .scaleEffect(draggedPin == pin && isDragging ? 1.5 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isDragging)
    }

    private var modeIndicator: some View {
        var text = ""
        switch mode {
        case .adding: text = "Tap map to add a pin"
        case .deleting: text = "Tap a pin to delete it"
        case .dragging: text = "Dragging pin..."
        default: break
        }

        return Text(text)
            .font(.caption)
            .fontWeight(.semibold)
            .padding(8)
            .background(.black.opacity(0.6))
            .foregroundColor(.white)
            .clipShape(Capsule())
            .padding(.bottom, 10)
            .transition(.scale.combined(with: .opacity))
    }

    private func modeButton(systemName: String, for targetMode: MapMode)
        -> some View
    {
        Button {
            withAnimation {
                mode = (mode == targetMode) ? .none : targetMode
            }
        } label: {
            Image(systemName: systemName)
                .font(.title2)
                .padding()
                .background(
                    mode == targetMode
                        ? Color.blue.opacity(0.8) : Color.secondary.opacity(0.4)
                )
                .foregroundColor(.white)
                .clipShape(Circle())
        }
    }

    // MARK: - Core Data Functions
    private func saveContext() {
        do {
            try viewContext.save()
            print("Context saved successfully!")
        } catch {
            print("Failed to save context: \(error.localizedDescription)")
        }
    }

    private func addPin(at coordinate: CLLocationCoordinate2D, name: String) {
        let highestOrder = pins.last?.order ?? -1

        let newPin = Pin(context: viewContext)
        newPin.id = UUID()
        newPin.name = name.isEmpty ? "Unnamed Pin" : name
        newPin.latitude = coordinate.latitude
        newPin.longitude = coordinate.longitude
        newPin.order = highestOrder + 1
        saveContext()
    }

    private func deletePin(_ pin: Pin) {
        viewContext.delete(pin)
        saveContext()
    }

    private func resetAddPinFlow() {
        tappedCoordinate = nil
        newPinName = ""
        mode = .none
    }
}

// This helper extension remains the same
extension Pin {
    var coordinate: CLLocationCoordinate2D {
        .init(latitude: latitude, longitude: longitude)
    }
}

#Preview {
    PinMapView().environment(
        \.managedObjectContext,
        PersistenceController.preview.container.viewContext
    )
}
