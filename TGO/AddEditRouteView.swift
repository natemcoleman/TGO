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
                    TextField("Description", text: $description)
                }

                Section("Selected Checkpoints") {
                    List {
                        ForEach(selectedPins) { pin in
                            Text(pin.name ?? "Unnamed")
                        }
                        .onMove(perform: movePin)
                        .onDelete(perform: removePin)
                    }
                }

                Section("Available Checkpoints") {
                    List(availablePins) { pin in
                        // --- FIX #1: Replaced Button with a tappable Text view ---
                        Text(pin.name ?? "Unnamed")
                            .contentShape(Rectangle()) // Makes the entire row area tappable
                            .onTapGesture {
                                addPin(pin)
                            }
                        // ---------------------------------------------------------
                    }
                }
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            // --- FIX #2: Restructured the toolbar for clarity and reliability ---
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                
                // This places the Edit/Done button correctly.
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: saveRoute)
                        .disabled(name.isEmpty || selectedPins.isEmpty)
                }
            }
            // ------------------------------------------------------------------
            .onAppear(perform: setupView)
        }
    }
    
    // MARK: - Functions
    
    private func setupView() {
        if let route = routeToEdit {
            name = route.name ?? ""
            description = route.desc ?? ""
            
            let routePins = route.routePins as? Set<RoutePin> ?? []
            selectedPins = routePins
                .sorted { $0.order < $1.order }
                .compactMap { $0.pin }
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

        if let oldRoutePins = route.routePins as? Set<RoutePin> {
            oldRoutePins.forEach(viewContext.delete)
        }
        
        for (index, pin) in selectedPins.enumerated() {
            let routePin = RoutePin(context: viewContext)
            routePin.pin = pin
            routePin.route = route
            routePin.order = Int32(index)
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
