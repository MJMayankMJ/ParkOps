//
//  CoreDataManager.swift
//  ParkOps
//
//  Created by Mayank Jangid on 3/6/25.
//

import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    let persistentContainer: NSPersistentContainer

    private init() {
        persistentContainer = NSPersistentContainer(name: "ParkOps")
        persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
        }
    }

    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    // MARK: - Parking Slot Management
    
    func addParkingSlot(name: String?, slotNumber: Int16, timeDurationInHour: Int16, startingTime: Date, vehicleNumber: String) {
        let slot = ParkingSlotData(context: context)
        slot.name = name
        slot.slotNumber = slotNumber
        slot.id = UUID()
        slot.timeDurationInHour = timeDurationInHour
        slot.startingTime = startingTime
        slot.vehicleNumber = vehicleNumber
        saveContext()
    }
    
    func fetchAllParkingSlots() -> [ParkingSlotData] {
        let fetchRequest: NSFetchRequest<ParkingSlotData> = ParkingSlotData.fetchRequest()
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Failed to fetch parking slots: \(error)")
            return []
        }
    }
    
    func deleteParkingSlot(slot: ParkingSlotData) {
        context.delete(slot)
        saveContext()
    }
    
    // MARK: - Total & Occupied Slots
    
    func fetchTotalSlots() -> Int16? {
        let fetchRequest: NSFetchRequest<ParkingSlot> = ParkingSlot.fetchRequest()
        do {
            let slots = try context.fetch(fetchRequest)
            return slots.first?.totalSlots
        } catch {
            print("Failed to fetch total slots: \(error)")
            return nil
        }
    }
    
    func setTotalSlots(_ newTotal: Int16) {
        let fetchRequest: NSFetchRequest<ParkingSlot> = ParkingSlot.fetchRequest()
        
        do {
            let slots = try context.fetch(fetchRequest)
            
            if let existingSlot = slots.first {
                existingSlot.totalSlots = newTotal
            } else {
                let newSlot = ParkingSlot(context: context)
                newSlot.totalSlots = newTotal
            }
            
            saveContext()
        } catch {
            print("Failed to update total slots: \(error)")
        }
    }
    
    var occupiedSlots: Int16 {
        return Int16(fetchAllParkingSlots().count)
    }
    
    var availableSlots: Int16 {
        if let totalSlots = fetchTotalSlots() {
            return totalSlots - occupiedSlots
        }
        return 0
    }
    
    // MARK: - Core Data Save Context
    // it should br private but currently edti vc is accessing this ... i will fix this .... maybe....
    func saveContext() {
        do {
            try context.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }

}
