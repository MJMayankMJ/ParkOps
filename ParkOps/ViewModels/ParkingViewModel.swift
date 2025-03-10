//
//  ParkingViewModel.swift
//  ParkOps
//
//  Created by Mayank Jangid on 3/6/25.
//


import Foundation

class ParkingViewModel {
    
    func fetchTotalSlotsPerFloor() -> Int16? {
        return CoreDataManager.shared.fetchTotalSlotsPerFloor()
    }
    
    func setTotalSlotsPerFloor(_ totalSlots: Int16) {
        CoreDataManager.shared.setTotalSlotsPerFloor(totalSlots)
    }
    
    func fetchTotalFloors() -> Int16? {
        return CoreDataManager.shared.fetchTotalFloors()
    }
    
    func setTotalFloors(_ totalFloors: Int16) {
        CoreDataManager.shared.setTotalFloors(totalFloors)
    }
    
    var occupiedSlots: Int16 {
        return CoreDataManager.shared.occupiedSlots
    }
    
    var availableSlots: Int16 {
        return CoreDataManager.shared.availableSlots
    }
    
    // adds a parking slot entry; if u fk up, completion returns an optional error message
    func addParkingSlot(name: String?, slotNumber: String, timeDurationInHour: Int16, vehicleNumber: String, completion: @escaping (String?) -> Void) {
        ParkingManager.shared.addParkingSlot(name: name!, slotNumber: slotNumber, timeDurationInHour: timeDurationInHour, startingTime: Date(), vehicleNumber: vehicleNumber)
        completion(nil)
    }
    
    // Returns the maximum required number of floors based on occupied slots.
    // For example, if an occupied slot is "H10", then maxRequiredFloors() returns 8 (since H is the 8th letter).
    func maxRequiredFloors() -> Int16 {
        let occupied = CoreDataManager.shared.fetchAllParkingSlots()
        var maxFloor: Int16 = 0
        for slot in occupied {
            let floorLetter = String(slot.slotNumber.prefix(1)).uppercased()
            if let scalar = floorLetter.unicodeScalars.first {
                let floorValue = Int16(scalar.value) - 64 // 'A' is 65 in Unicode
                if floorValue > maxFloor {
                    maxFloor = floorValue
                }
            }
        }
        return maxFloor
    }
    
    // Returns the maximum required slot number (the numeric part) across all occupied slots.
    func maxRequiredSlotsPerFloor() -> Int16 {
        let occupied = CoreDataManager.shared.fetchAllParkingSlots()
        var maxSlot: Int16 = 0
        for slot in occupied {
            let slotPart = String(slot.slotNumber.dropFirst())
            if let slotNum = Int16(slotPart), slotNum > maxSlot {
                maxSlot = slotNum
            }
        }
        return maxSlot
    }
}
