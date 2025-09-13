////
////  CoreDataManager.swift
////  TGO
////
////  Created by Brooklyn Daines on 9/9/25.
////
//
//
//import CoreData
//import MapKit
//
//class CoreDataManager: ObservableObject {
//    static let shared = CoreDataManager()
//    
//    lazy var persistentContainer: NSPersistentContainer = {
//        let container = NSPersistentContainer(name: "CommuteDataModel") // Your .xcdatamodeld file name
//        container.loadPersistentStores { _, error in
//            if let error = error {
//                fatalError("Core Data error: \(error.localizedDescription)")
//            }
//        }
//        return container
//    }()
//    
//    var context: NSManagedObjectContext {
//        persistentContainer.viewContext
//    }
//    
//    func save() {
//        if context.hasChanges {
//            do {
//                try context.save()
//            } catch {
//                print("Save error: \(error)")
//            }
//        }
//    }
//    
//    func saveCommuteLog(regionId: String, eventType: CommuteLog.EventType, coordinate: CLLocationCoordinate2D? = nil) {
//        let log = CommuteLogEntity(context: context)
//        log.id = UUID()
//        log.regionId = regionId
//        log.timestamp = Date()
//        log.eventType = eventType.rawValue
//        
//        if let coordinate = coordinate {
//            log.latitude = coordinate.latitude
//            log.longitude = coordinate.longitude
//        }
//        
//        save()
//    }
//    
//    func fetchCommuteLogs() -> [CommuteLogEntity] {
//        let request: NSFetchRequest<CommuteLogEntity> = CommuteLogEntity.fetchRequest()
//        request.sortDescriptors = [NSSortDescriptor(keyPath: \CommuteLogEntity.timestamp, ascending: false)]
//        
//        do {
//            return try context.fetch(request)
//        } catch {
//            print("Fetch error: \(error)")
//            return []
//        }
//    }
//    
//    func deleteAllLogs() {
//        let request: NSFetchRequest<NSFetchRequestResult> = CommuteLogEntity.fetchRequest()
//        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
//        
//        do {
//            try context.execute(deleteRequest)
//            save()
//        } catch {
//            print("Delete error: \(error)")
//        }
//    }
//}
