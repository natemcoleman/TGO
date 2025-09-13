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

    // Fetch the pins and, crucially, sort them by the 'order' attribute
    // This ensures they appear in the correct, user-defined sequence.
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Pin.order, ascending: true)],
        animation: .default)
    private var pins: FetchedResults<Pin>

    // MARK: - Body
    var body: some View {
        // Use a NavigationView to provide a title and toolbar
        NavigationView {
            List {
                // ForEach is what allows the list to be dynamic and reorderable
                ForEach(pins) { pin in
                    HStack {
                        // Display the pin's order and name
                        Text("\(pin.order)")
                            .font(.headline)
                            .frame(width: 30)
                            .padding(.trailing, 5)
                        Text(pin.name ?? "Unnamed Pin")
                    }
                }
                .onMove(perform: movePins) // The modifier that enables reordering
            }
            .navigationTitle("Reorder Pins")
            .toolbar {
                // An EditButton toggles the list's edit mode, showing the drag handles
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
        }
    }

    // MARK: - Core Data Functions

    /// This function is called when the user finishes dragging a row in the list.
    private func movePins(from source: IndexSet, to destination: Int) {
        // 1. Create a mutable copy of the fetched pins array.
        var revisedPins = pins.map { $0 }

        // 2. Perform the move operation on the in-memory array.
        revisedPins.move(fromOffsets: source, toOffset: destination)

        // 3. Iterate through the now-reordered array and update the 'order'
        //    attribute of each pin based on its new index.
        for (index, pin) in revisedPins.enumerated() {
            pin.order = Int32(index)
        }
        
        // 4. Save the managed object context to persist the changes.
        saveContext()
    }
    
    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

#Preview {
    PinListView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
