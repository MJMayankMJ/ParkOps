//
//  ParkingSlotData+CoreDataProperties.swift
//  ParkOps
//
//  Created by Mayank Jangid on 3/6/25.
//
//

import Foundation
import CoreData


extension ParkingSlotData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ParkingSlotData> {
        return NSFetchRequest<ParkingSlotData>(entityName: "ParkingSlotData")
    }

    @NSManaged public var name: String
    @NSManaged public var slotNumber: String
    @NSManaged public var timeDurationInHour: Int16
    @NSManaged public var startingTime: Date?
    @NSManaged public var vehicleNumber: String
    @NSManaged public var id: UUID
    @NSManaged public var parkingSlot: ParkingSlot?

}

extension ParkingSlotData : Identifiable {

}
