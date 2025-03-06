//
//  ParkingViewModel.swift
//  ParkOps
//
//  Created by Mayank Jangid on 3/6/25.
//

import Foundation

class ParkingViewModel {
    
    func fetchTotalSlots() -> Int16? {
        return CoreDataManager.shared.fetchTotalSlots()
    }
    
    func setTotalSlots(_ totalSlots: Int16) {
        CoreDataManager.shared.setTotalSlots(totalSlots)
    }
    
    var occupiedSlots: Int16 {
        return CoreDataManager.shared.occupiedSlots
    }
    
    var availableSlots: Int16 {
        return CoreDataManager.shared.availableSlots
    }
    
    func addParkingSlot(name: String?, slotNumber: Int16, timeDurationInHour: Int16, vehicleNumber: String) {
        CoreDataManager.shared.addParkingSlot(name: name, slotNumber: slotNumber, timeDurationInHour: timeDurationInHour, startingTime: Date(), vehicleNumber: vehicleNumber)
    }
}
