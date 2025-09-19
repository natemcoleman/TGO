import SwiftUI
import CoreData

struct AddEditRouteView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Pin.order, ascending: true)])
    private var allPins: FetchedResults<Pin>
    
    let routeToEdit: Route?
    
    @State private var name: String = ""
    @State private var description: String = ""
    @State private var selectedPins: [Pin] = []
    
    @State private var exitCheckpoints: Set<Pin.ID> = []
    
    
    private var availablePins: [Pin] {
        allPins.filter { !selectedPins.contains($0) }
    }
    
    private var navigationTitle: String {
        routeToEdit == nil ? "New Route" : "Edit Route"
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Route Details") {
                    TextField("Route Name", text: $name)
                        .textInputAutocapitalization(.words)
                    TextField("Description", text: $description)
                        .textInputAutocapitalization(.words)
                }
                
                // In the body of AddEditRouteView.swift

                Section("Selected Checkpoints") {
                    List {
                        ForEach(selectedPins) { pin in
                            HStack {
                                // This now correctly reflects whether an exit pin should be created
                                Image(systemName: exitCheckpoints.contains(pin.id!) ? "checkmark.square.fill" : "square")
                                    .foregroundColor(.accentColor)
                                
                                Text(pin.name ?? "Unnamed")
                                
                                Spacer()
                                
                                Text("(Tap box for stoplight)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                // This correctly toggles the pin's ID in the set
                                if exitCheckpoints.contains(pin.id!) {
                                    exitCheckpoints.remove(pin.id!)
                                } else {
                                    exitCheckpoints.insert(pin.id!)
                                }
                            }
                        }
                        .onMove(perform: movePin)
                        .onDelete(perform: removePin)
                    }
                }
                
                Section("Available Checkpoints") {
                    List(availablePins) { pin in
                        Text(pin.name ?? "Unnamed")
                            .contentShape(Rectangle()) // Makes the entire row area tappable
                            .onTapGesture {
                                addPin(pin)
                            }
                    }
                }
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: saveRoute)
                        .disabled(name.isEmpty || selectedPins.isEmpty)
                }
            }
            .onAppear(perform: setupView)
        }
    }
    
    // MARK: - Functions
    
    // In AddEditRouteView.swift

    // In AddEditRouteView.swift

    private func setupView() {
        if let route = routeToEdit {
            name = route.name ?? ""
            description = route.desc ?? ""
            
            let routePins = route.routePins as? Set<RoutePin> ?? []
            
            // --- THIS LOGIC PREVENTS DUPLICATE IDs ---
            
            // Use a dictionary to ensure each Pin is processed only once.
            var uniquePins = [Pin: Bool]()

            // Sort by order to process correctly.
            let sortedRoutePins = routePins.sorted { $0.order < $1.order }
            
            for routePin in sortedRoutePins {
                guard let pin = routePin.pin else { continue }
                
                // If the pin is an exit event (!onEnter), mark it as 'true' in our dictionary.
                if !routePin.onEnter {
                    uniquePins[pin] = true
                } else if uniquePins[pin] == nil {
                    // Otherwise, if we haven't seen this pin yet, add it as 'false' (not an exit).
                    uniquePins[pin] = false
                }
            }
            
            // Now, build the final arrays from the unique dictionary.
            // 1. Get the unique pins (the dictionary keys).
            let finalPins = Array(uniquePins.keys)
            
            // 2. Sort them to maintain a somewhat consistent order.
            selectedPins = finalPins.sorted { p1, p2 in
                let order1 = sortedRoutePins.first { $0.pin == p1 }?.order ?? 0
                let order2 = sortedRoutePins.first { $0.pin == p2 }?.order ?? 0
                return order1 < order2
            }
            
            // 3. Populate exitCheckpoints based on the dictionary values.
            exitCheckpoints = Set(uniquePins.filter { $0.value == true }.map { $0.key.id! })
        }
    }
    
    private func saveRoute() {
        let route = routeToEdit ?? Route(context: viewContext)
        
        if routeToEdit == nil {
            route.id = UUID()
            route.createdAt = Date()
        }
        
        route.name = name
        route.desc = description

        // Clear out old RoutePins to avoid duplicates
        if let oldRoutePins = route.routePins as? Set<RoutePin> {
            oldRoutePins.forEach(viewContext.delete)
        }
        
        var currentOrder: Int32 = 0
        for pin in selectedPins {
            let enterRoutePin = RoutePin(context: viewContext)
            enterRoutePin.pin = pin
            enterRoutePin.route = route
            enterRoutePin.order = currentOrder
            enterRoutePin.onEnter = true
            enterRoutePin.displayName = pin.name
            currentOrder += 1

            // 2. If the checkbox was checked, create the 'onExit' RoutePin
            if exitCheckpoints.contains(pin.id) {
                let exitRoutePin = RoutePin(context: viewContext)
                exitRoutePin.pin = pin // It still links to the same, original Pin
                exitRoutePin.route = route
                exitRoutePin.order = currentOrder
                exitRoutePin.onEnter = false
                exitRoutePin.displayName = "\(pin.name ?? "Unnamed") duration"
                enterRoutePin.displayName = "Time to \(pin.name ?? "Unnamed")"
                currentOrder += 1
            }
        }
        
        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Failed to save route: \(error.localizedDescription)")
        }
    }
    
    // MARK: - List Actions
    
    private func addPin(_ pin: Pin) {
        withAnimation {
            selectedPins.append(pin)
        }
    }
    
    private func removePin(at offsets: IndexSet) {
        selectedPins.remove(atOffsets: offsets)
    }
    
    private func movePin(from source: IndexSet, to destination: Int) {
        selectedPins.move(fromOffsets: source, toOffset: destination)
    }
}

//#Preview {
//    AddEditRouteView(routeToEdit: nil).environment(
//        \.managedObjectContext,
//        PersistenceController.preview.container.viewContext
//    )
//}
