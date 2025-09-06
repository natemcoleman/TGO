//
//  TGOApp.swift
//  TGO
//
//  Created by Brooklyn Daines on 9/6/25.
//

import SwiftUI

@main
struct TGOApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
