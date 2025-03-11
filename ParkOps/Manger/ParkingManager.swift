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
    
    // Create a new parking slot with default transaction fields.
    func addParkingSlot(name: String,
                        slotNumber: String,
                        timeDurationInHour: Int16,
                        startingTime: Date,
                        vehicleNumber: String) {
        
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
        slot.id = UUID()
        slot.name = name
        slot.slotNumber = slotNumber
        slot.timeDurationInHour = timeDurationInHour
        slot.startingTime = startingTime
        slot.vehicleNumber = vehicleNumber
        
        // New fields: default to "approved" and payment = true ---- cz when we enter manually u need it in manage slot; having it in transaction slot and than you need to approve your request would be a bit wanky thing to do
        slot.transactionStatus = "approved"
        slot.isPaymentDone = true
        
        coreDataManager.saveContext()
    }
    
    // Remove a slot by slot number
    func removeParkingSlot(bySlotNumber slotNumber: String) {
        coreDataManager.removeParkingSlot(bySlotNumber: slotNumber)
    }
    
    // Called if floors/slots are reconfigured
    func deleteOutOfRangeSlotsForConfiguration(totalFloors: Int16, slotsPerFloor: Int16) {
        coreDataManager.deleteOutOfRangeSlots(totalFloors: totalFloors, slotsPerFloor: slotsPerFloor)
    }
    
    // Example methods for changing transaction status / payment
    func approveSlot(_ slot: ParkingSlotData) {
        slot.transactionStatus = "approved"
        coreDataManager.saveContext()
    }
    
    func markSlotAsPaid(_ slot: ParkingSlotData) {
        slot.isPaymentDone = true
        coreDataManager.saveContext()
    }
    
    func rejectSlot(_ slot: ParkingSlotData) {
        // e.g. delete the slot
        coreDataManager.deleteParkingSlot(slot: slot)
    }
}
