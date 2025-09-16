//
//  AddPinView.swift
//  TGO
//
//  Created by Brooklyn Daines on 9/12/25.
//


import SwiftUI

struct AddPinView: View {
    // MARK: - Properties
    
    // Allows us to dismiss this sheet
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String = ""
    @State private var order: String = ""
    
    // A callback function to pass the new data back to the map view
    var onSave: (String, Int) -> Void
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Pin Details")) {
                    TextField("Pin Name", text: $name)
                    TextField("Display Order", text: $order)
                        .keyboardType(.numberPad) // Use a number pad for order input
                }
            }
            .navigationTitle("Add New Pin")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Toolbar for Cancel and Save buttons
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss() // Dismiss the sheet
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        // Convert order string to an Int, defaulting to 0 if invalid
                        let orderInt = Int(order) ?? 0
                        onSave(name, orderInt)
                        dismiss() // Dismiss the sheet after saving
                    }
                    .disabled(name.isEmpty) // Disable save if name is empty
                }
            }
        }
    }
}

#Preview {
    // A sample preview that does nothing on save
    AddPinView(onSave: { _, _ in })
}
