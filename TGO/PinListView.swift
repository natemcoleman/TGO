//
//  PinListView.swift
//  TGO
//
//  Created by Brooklyn Daines on 9/12/25.
//

import SwiftUI
import CoreData

struct PinListView: View {
    // MARK: - Core Data
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Pin.order, ascending: true)],
        animation: .default)
    private var pins: FetchedResults<Pin>
    
    @Environment(\.editMode) private var editMode
    
    @FocusState private var focusedPinID: NSManagedObjectID?

    // MARK: - Body
    var body: some View {
        NavigationView {
            List {
                ForEach(pins) { pin in
//                    if editMode?.wrappedValue == .active {
//                        print("Editing pin with ID: \(pin.objectID)")
                        // If so, display a TextField for the pin's name.
                        // We create a custom binding to safely handle the optional pin.name.
                        let binding = Binding(
                            get: { pin.name ?? "" },
                            set: { pin.name = $0 }
                        )
                        
                        TextField("Pin Name", text: binding)
                            // This ensures the correct text field gets keyboard focus.
                            .focused($focusedPinID, equals: pin.objectID)
                            // When the user hits 'return', submit the changes.
                            .onSubmit(saveContext)
                        
//                    } else {
//                        // If not in edit mode, just display the pin name as text.
//                        Text(pin.name ?? "Unnamed Pin")
//                    }
                    // --- ⬆️ END MODIFICATION ---
                }
                .onMove(perform: movePins)
                .onDelete(perform: removePins)
            }
            .navigationTitle("Edit Pins")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
            .onChange(of: editMode?.wrappedValue) { _, newValue in
                if newValue == .inactive {
                    saveContext()
                }
            }
        }
    }

    // MARK: - Core Data Functions
    private func movePins(from source: IndexSet, to destination: Int) {
        var revisedPins = pins.map { $0 }
        revisedPins.move(fromOffsets: source, toOffset: destination)

        for (index, pin) in revisedPins.enumerated() {
            pin.order = Int32(index)
        }
        saveContext()
    }
    
    private func removePins(offsets: IndexSet) {
        withAnimation {
            offsets.map { pins[$0] }.forEach(viewContext.delete)
            saveContext()
        }
    }
    
    private func saveContext() {
        guard viewContext.hasChanges else { return }
        
        do {
            try viewContext.save()
            focusedPinID = nil
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

#Preview {
    PinListView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
