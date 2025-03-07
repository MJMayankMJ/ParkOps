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
    
    func addParkingSlot(name: String, slotNumber: String, timeDurationInHour: Int16, startingTime: Date, vehicleNumber: String) {
        guard let totalFloors = fetchTotalFloors(),
              let totalSlotsPerFloor = fetchTotalSlotsPerFloor() else {
            print("Error: Total floors or slots per floor not set.")
            return
        }

        let floorLetters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        let validFloors = Array(floorLetters.prefix(Int(totalFloors))) // Allowed floors (e.g., A-F if totalFloors=6)

        // Extract floor letter and slot number
        let floor = String(slotNumber.prefix(1)) // First letter (e.g., "B")
        let slotNumberPart = String(slotNumber.dropFirst()) // Number part (e.g., "11")
        
        guard validFloors.contains(floor) else {
            print("Error: Invalid floor. Allowed floors: \(validFloors)")
            return
        }
        
        guard let slotNum = Int(slotNumberPart), slotNum > 0, slotNum <= totalSlotsPerFloor else {
            print("Error: Invalid slot number. Allowed range: 1-\(totalSlotsPerFloor)")
            return
        }
        
        // Proceed with adding the slot
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
            return try context.fetch(fetchRequest).sorted { compareSlotNumbers($0.slotNumber, $1.slotNumber) }
        } catch {
            print("Failed to fetch parking slots: \(error)")
            return []
        }
    }
    
    func deleteParkingSlot(slot: ParkingSlotData) {
        context.delete(slot)
        saveContext()
    }
    
    // MARK: - Total Slots & Floors Management
    
    func fetchTotalSlotsPerFloor() -> Int16? {
        let fetchRequest: NSFetchRequest<ParkingSlot> = ParkingSlot.fetchRequest()
        do {
            return try context.fetch(fetchRequest).first?.totalSlotsPerFloor
        } catch {
            print("Failed to fetch total slots per floor: \(error)")
            return nil
        }
    }
    
    func setTotalSlotsPerFloor(_ newTotal: Int16) {
        let fetchRequest: NSFetchRequest<ParkingSlot> = ParkingSlot.fetchRequest()
        
        do {
            let slots = try context.fetch(fetchRequest)
            
            if let existingSlot = slots.first {
                existingSlot.totalSlotsPerFloor = newTotal
            } else {
                let newSlot = ParkingSlot(context: context)
                newSlot.totalSlotsPerFloor = newTotal
            }
            
            saveContext()
        } catch {
            print("Failed to update total slots per floor: \(error)")
        }
    }
    
    func fetchTotalFloors() -> Int16? {
        let fetchRequest: NSFetchRequest<ParkingSlot> = ParkingSlot.fetchRequest()
        do {
            return try context.fetch(fetchRequest).first?.totalFloors
        } catch {
            print("Failed to fetch total floors: \(error)")
            return nil
        }
    }
    
    func setTotalFloors(_ newTotal: Int16) {
        let fetchRequest: NSFetchRequest<ParkingSlot> = ParkingSlot.fetchRequest()
        
        do {
            let slots = try context.fetch(fetchRequest)
            
            if let existingSlot = slots.first {
                existingSlot.totalFloors = newTotal
            } else {
                let newSlot = ParkingSlot(context: context)
                newSlot.totalFloors = newTotal
            }
            
            saveContext()
        } catch {
            print("Failed to update total floors: \(error)")
        }
    }
    
    var occupiedSlots: Int16 {
        return Int16(fetchAllParkingSlots().count)
    }
    
    var availableSlots: Int16 {
        if let totalSlots = fetchTotalSlotsPerFloor(), let totalFloors = fetchTotalFloors() {
            return (totalSlots * totalFloors) - occupiedSlots
        }
        return 0
    }
    
    // MARK: - Core Data Save Context
    
    func saveContext() {
        do {
            try context.save()
        } catch {
            context.rollback()
            print("Failed to save context: \(error)")
        }
    }
    
    // MARK: - Alphanumeric Sorting Function

    private func compareSlotNumbers(_ slot1: String?, _ slot2: String?) -> Bool {
        guard let s1 = slot1, let s2 = slot2 else { return false }
        
        let pattern = "([A-Za-z]+)([0-9]+)"
        let regex = try? NSRegularExpression(pattern: pattern)
        
        func extractParts(from slot: String) -> (String, Int)? {
            guard let match = regex?.firstMatch(in: slot, range: NSRange(slot.startIndex..., in: slot)) else { return nil }
            let letterRange = Range(match.range(at: 1), in: slot)!
            let numberRange = Range(match.range(at: 2), in: slot)!
            
            let letterPart = String(slot[letterRange])
            let numberPart = Int(slot[numberRange]) ?? 0
            return (letterPart, numberPart)
        }
        
        if let parts1 = extractParts(from: s1), let parts2 = extractParts(from: s2) {
            if parts1.0 == parts2.0 { // Same letter prefix, compare numbers
                return parts1.1 < parts2.1
            }
            return parts1.0 < parts2.0
        }
        return s1 < s2 // Fallback to default string comparison
    }
}
