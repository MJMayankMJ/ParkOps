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
    
    func addParkingSlot(name: String?, slotNumber: String, timeDurationInHour: Int16, vehicleNumber: String) {
        CoreDataManager.shared.addParkingSlot(name: name!, slotNumber: slotNumber, timeDurationInHour: timeDurationInHour, startingTime: Date(), vehicleNumber: vehicleNumber)
    }
}
