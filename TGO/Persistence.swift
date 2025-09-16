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

        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "TGO")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(
                fileURLWithPath: "/dev/null"
            )
        }
        container.loadPersistentStores(completionHandler: {
            (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }

        })
        self.seedInitialData()
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    private func seedInitialData() {
        let viewContext = container.viewContext

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

                let route1 = Route(context: viewContext)
                route1.id = UUID()
                route1.name = "Morning Commute"
                route1.createdAt = Date()
                route1.desc = "Regular route to work"

                // 3. Link the Pins to the Route using the RoutePin join entity
                // This is the crucial step.
                let routePin1 = RoutePin(context: viewContext)
                routePin1.order = 0
                routePin1.route = route1  // Link to the route
                routePin1.pin = pin1  // Link to the pin

                let routePin2 = RoutePin(context: viewContext)
                routePin2.order = 1
                routePin2.route = route1  // Link to the route
                routePin2.pin = pin2 // Link to the pin
                
                let routePin3 = RoutePin(context: viewContext)
                routePin3.order = 2
                routePin3.route = route1  // Link to the route
                routePin3.pin = pin3 // Link to the pin
                
                let routePin4 = RoutePin(context: viewContext)
                routePin4.order = 3
                routePin4.route = route1  // Link to the route
                routePin4.pin = pin4 // Link to the pin
                
                let routePin5 = RoutePin(context: viewContext)
                routePin5.order = 4
                routePin5.route = route1  // Link to the route
                routePin5.pin = pin5 // Link to the pin

                try viewContext.save()
            } else {
                print("Core Data already contains data. No seeding needed.")
            }

        } catch let error as NSError {
            print(
                "Could not fetch or save from Core Data. \(error), \(error.userInfo)"
            )
        }
    }
}
