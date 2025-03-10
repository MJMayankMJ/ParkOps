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
    
    // MARK: - Parking Slot Persistence
    
    func fetchAllParkingSlots() -> [ParkingSlotData] {
        let fetchRequest: NSFetchRequest<ParkingSlotData> = ParkingSlotData.fetchRequest()
        do {
            return try context.fetch(fetchRequest).sorted { compareSlotNumbers($0.slotNumber, $1.slotNumber) }
        } catch {
            print("Failed to fetch parking slots: \(error)")
            return []
        }
    }
    
    private func compareSlotNumbers(_ slot1: String?, _ slot2: String?) -> Bool {
        guard let slot1 = slot1, let slot2 = slot2 else { return false }
        let floor1 = String(slot1.prefix(1))
        let floor2 = String(slot2.prefix(1))
        if floor1 == floor2 {
            let num1 = Int(slot1.dropFirst()) ?? 0
            let num2 = Int(slot2.dropFirst()) ?? 0
            return num1 < num2
        }
        return floor1 < floor2
    }
    
    func deleteParkingSlot(slot: ParkingSlotData) {
        context.delete(slot)
        saveContext()
    }
    
    func removeParkingSlot(bySlotNumber slotNumber: String) {
        let allSlots = fetchAllParkingSlots()
        if let slot = allSlots.first(where: { $0.slotNumber == slotNumber }) {
            deleteParkingSlot(slot: slot)
        } else {
            print("Slot not found.")
        }
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
    
    func fetchTotalFloors() -> Int16? {
        let fetchRequest: NSFetchRequest<ParkingSlot> = ParkingSlot.fetchRequest()
        do {
            return try context.fetch(fetchRequest).first?.totalFloors
        } catch {
            print("Failed to fetch total floors: \(error)")
            return nil
        }
    }
    
    // Update total slots per floor.
    func setTotalSlotsPerFloor(_ newTotal: Int16) {
        updateTotalSlotsPerFloor(newTotal: newTotal)
        if let currentFloors = fetchTotalFloors() {
            deleteOutOfRangeSlots(totalFloors: currentFloors, slotsPerFloor: newTotal)
        }
    }
    
    // Update total floors.
    func setTotalFloors(_ newTotal: Int16) {
        updateTotalFloors(newTotal: newTotal)
        if let currentSlots = fetchTotalSlotsPerFloor() {
            deleteOutOfRangeSlots(totalFloors: newTotal, slotsPerFloor: currentSlots)
        }
    }
    
    // Helper methods for updating the configuration.
    private func updateTotalSlotsPerFloor(newTotal: Int16) {
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
    
    private func updateTotalFloors(newTotal: Int16) {
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
    
    // Consolidated method to delete parking slots that are out-of-range.
    func deleteOutOfRangeSlots(totalFloors: Int16, slotsPerFloor: Int16) {
        let allSlots = fetchAllParkingSlots()
        let allowedFloors = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ".prefix(Int(totalFloors)))
        for slot in allSlots {
            let slotStr = slot.slotNumber
            let floor = String(slotStr.prefix(1)).uppercased()
            let slotNumber = Int(slotStr.dropFirst()) ?? 0
            if !allowedFloors.contains(floor) || slotNumber > Int(slotsPerFloor) {
                deleteParkingSlot(slot: slot)
            }
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
    
    func saveContext() {
        do {
            try context.save()
        } catch {
            context.rollback()
            print("Failed to save context: \(error)")
        }
    }
    
    //MARK: - Delete all / RESET
    func deleteAllParkingSlots() {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "ParkingSlotData")
        
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            print("Error deleting all slots: \(error)")
        }
    }
    
    func resetParkingConfiguration() {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<ParkingSlot> = ParkingSlot.fetchRequest()

        do {
            if let parkingSlot = try context.fetch(fetchRequest).first {
                parkingSlot.totalFloors = 0
                parkingSlot.totalSlotsPerFloor = 0
                try context.save()
            }
        } catch {
            print("Error resetting parking configuration: \(error)")
        }
    }

}
