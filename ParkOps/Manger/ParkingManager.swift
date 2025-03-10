//
//  ParkingManager.swift
//  ParkOps
//
//  Created by Mayank Jangid on 3/10/25.
//

import Foundation

class ParkingManager {
    static let shared = ParkingManager()
    private let coreDataManager = CoreDataManager.shared
    
    private init() {}
    
    func addParkingSlot(name: String,slotNumber: String,timeDurationInHour: Int16,startingTime: Date,vehicleNumber: String) {
        guard let totalFloors = coreDataManager.fetchTotalFloors(),
              let totalSlotsPerFloor = coreDataManager.fetchTotalSlotsPerFloor() else {
            print("Error: Total floors or slots per floor not set.")
            return
        }
        
        // Validate floor letter based on configuration
        let floorLetters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        let validFloors = Array(floorLetters.prefix(Int(totalFloors)))
        let floor = String(slotNumber.prefix(1))
        let slotNumberPart = String(slotNumber.dropFirst())
        
        guard validFloors.contains(floor) else {
            print("Error: Invalid floor. Allowed floors: \(validFloors)")
            return
        }
        
        // Validate the numeric part of the slot number
        guard let slotNum = Int(slotNumberPart),
              slotNum > 0,
              slotNum <= totalSlotsPerFloor else {
            print("Error: Invalid slot number. Allowed range: 1-\(totalSlotsPerFloor)")
            return
        }
        
        // Create and persist the parking slot entry
        let context = coreDataManager.context
        let slot = ParkingSlotData(context: context)
        slot.name = name
        slot.slotNumber = slotNumber
        slot.id = UUID()
        slot.timeDurationInHour = timeDurationInHour
        slot.startingTime = startingTime
        slot.vehicleNumber = vehicleNumber
        
        coreDataManager.saveContext()
    }
    
    func removeParkingSlot(bySlotNumber slotNumber: String) {
        coreDataManager.removeParkingSlot(bySlotNumber: slotNumber)
    }
    
    func deleteOutOfRangeSlotsForConfiguration(totalFloors: Int16, slotsPerFloor: Int16) {
        coreDataManager.deleteOutOfRangeSlots(totalFloors: totalFloors, slotsPerFloor: slotsPerFloor)
    }

}
