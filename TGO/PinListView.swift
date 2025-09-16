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

    // MARK: - Body
    var body: some View {
        NavigationView {
            List {
                ForEach(pins) { pin in
                    HStack {
                        // Display the pin's order and name
//                        Text("\(pin.order)")
//                            .font(.headline)
//                            .frame(width: 30)
//                            .padding(.trailing, 5)
                        Text(pin.name ?? "Unnamed Pin")
                    }
                }
//                .onMove(perform: movePins) // The modifier that enables reordering
                .onDelete(perform: removePins) // Optional: Allow deletion of pins
            }
            .navigationTitle("Delete Pins")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
        }
    }

    // MARK: - Core Data Functions

    /// This function is called when the user finishes dragging a row in the list.
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
            do {
                try viewContext.save()
            } catch {
                print("Failed to delete pin: \(error.localizedDescription)")
            }
        }
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
