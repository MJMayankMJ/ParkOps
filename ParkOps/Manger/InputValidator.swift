//
//  InputValidator.swift
//  ParkOps
//
//  Created by Mayank Jangid on 3/7/25.
//

import Foundation

class InputValidator {
    
    static func validateDriverName(_ name: String?) -> String? {
        guard let name = name, !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return "Driver's name cannot be empty."
        }
        return nil
    }
    
    static func validateAndFormatSlotNumber(_ slotNumber: String?, totalFloors: Int16, slotsPerFloor: Int16) -> (String?, String?) {
            guard let slotNumber = slotNumber, !slotNumber.isEmpty else {
                return (nil, "Slot number cannot be empty.")
            }
            
            let pattern = "^[A-Za-z][0-9]+$"
            let regex = try! NSRegularExpression(pattern: pattern, options: [])
            let range = NSRange(location: 0, length: slotNumber.utf16.count)
            
            if regex.firstMatch(in: slotNumber, options: [], range: range) == nil {
                return (nil, "Invalid slot format. Example: A10 (Floor A, Slot 10).")
            }
            
            // Convert first letter to uppercase for consistency
            let formattedSlotNumber = slotNumber.prefix(1).uppercased() + slotNumber.dropFirst()
            let floorChar = formattedSlotNumber.prefix(1)
            let floorIndex = Int(floorChar.unicodeScalars.first!.value) - Int("A".unicodeScalars.first!.value) + 1
            
            if floorIndex < 1 || floorIndex > totalFloors {
                let lastFloor = Character(UnicodeScalar(Int("A".unicodeScalars.first!.value) + Int(totalFloors) - 1)!)
                return (nil, "Invalid floor. Available floors: A-\(lastFloor).")
            }
            
            let slotPart = String(formattedSlotNumber.dropFirst())
            if let slotValue = Int(slotPart), slotValue < 1 || slotValue > slotsPerFloor {
                return (nil, "Invalid slot number. Available slots: 1-\(slotsPerFloor) per floor.")
            }
            
            // Check if the slot is already booked
            let existingSlot = CoreDataManager.shared.fetchAllParkingSlots().first {
                $0.slotNumber.uppercased() == formattedSlotNumber.uppercased()
            }
            if existingSlot != nil {
                return (nil, "Slot \(formattedSlotNumber) is already booked.")
            }
            
            return (formattedSlotNumber, nil)
        }

    
    static func validateTimeDuration(_ duration: String?) -> String? {
        guard let duration = duration, let number = Int(duration), number > 0 else {
            return "Duration must be a positive number."
        }
        return nil
    }
    
    static func validateVehicleNumber(_ vehicleNumber: String?) -> String? {
        guard let vehicleNumber = vehicleNumber, !vehicleNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return "Vehicle number cannot be empty."
        }
        return nil
    }
    
    static func validateStartingTime(_ date: Date?) -> String? {
        guard date != nil else {
            return "Starting time must be selected."
        }
        return nil
    }
}

