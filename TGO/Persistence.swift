//
//  Persistence.swift
//  TGO
//
//  Created by Brooklyn Daines on 9/6/25.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
//        for _ in 0..<10 {
//            let newItem = Item(context: viewContext)
//            newItem.timestamp = Date()
//        }
//        for _ in 0..<10 {
//            let newPin = Pin(context: viewContext)
//            newPin.id = UUID()
//        }
//        let pin1 = Pin(context: viewContext)
//        pin1.id = UUID()
//        pin1.name = "Home"
//        pin1.latitude = 39.22958751944363
//        pin1.longitude = -76.8485354177105
//        pin1.order = 0
//        
//        let pin2 = Pin(context: viewContext)
//        pin2.id = UUID()
//        pin2.name = "Patuxent Light"
//        pin2.latitude = 39.22589744964121
//        pin2.longitude = -76.85535359298007
//        pin2.order = 1
//        
//        let pin3 = Pin(context: viewContext)
//        pin3.id = UUID()
//        pin3.name = "29 Light"
//        pin3.latitude = 39.17386677510497
//        pin3.longitude = -76.88125300327637
//        pin3.order = 2
//        
//        let pin4 = Pin(context: viewContext)
//        pin4.id = UUID()
//        pin4.name = "Hopkins Road Light"
//        pin4.latitude = 39.15944302100448
//        pin4.longitude = -76.89335513031924
//        pin4.order = 3
//        
//        let pin5 = Pin(context: viewContext)
//        pin5.id = UUID()
//        pin5.name = "APL"
//        pin5.latitude = 39.16167249112726
//        pin5.longitude = -76.89963149940631
//        pin5.order = 4
        
        
        
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "TGO")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
            
        })
        self.seedInitialData()
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    private func seedInitialData() {
        let viewContext = container.viewContext
        
        // Perform a fetch request to see if any pins already exist.
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        
        do {
            let existingPins = try viewContext.fetch(fetchRequest)
            
            // If the database is empty, add your initial pins.
            if existingPins.isEmpty {
                print("Core Data is empty. Seeding initial pins...")
                
                let pin1 = Pin(context: viewContext)
                pin1.id = UUID()
                pin1.name = "Home"
                pin1.latitude = 39.22958751944363
                pin1.longitude = -76.8485354177105
                pin1.order = 0
                
                let pin2 = Pin(context: viewContext)
                pin2.id = UUID()
                pin2.name = "Patuxent Light"
                pin2.latitude = 39.22589744964121
                pin2.longitude = -76.85535359298007
                pin2.order = 1
                
                let pin3 = Pin(context: viewContext)
                pin3.id = UUID()
                pin3.name = "29 Light"
                pin3.latitude = 39.17386677510497
                pin3.longitude = -76.88125300327637
                pin3.order = 2
                
                let pin4 = Pin(context: viewContext)
                pin4.id = UUID()
                pin4.name = "Hopkins Road Light"
                pin4.latitude = 39.15944302100448
                pin4.longitude = -76.89335513031924
                pin4.order = 3
                
                let pin5 = Pin(context: viewContext)
                pin5.id = UUID()
                pin5.name = "APL"
                pin5.latitude = 39.16167249112726
                pin5.longitude = -76.89963149940631
                pin5.order = 4
                
                // Save the new pins to the database
                try viewContext.save()
            } else {
                print("Core Data already contains pins. No seeding needed.")
            }
        } catch let error as NSError {
            print("Could not fetch or save from Core Data. \(error), \(error.userInfo)")
        }
    }
}

