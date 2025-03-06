//
//  ParkingSlot+CoreDataProperties.swift
//  ParkOps
//
//  Created by Mayank Jangid on 3/6/25.
//
//

import Foundation
import CoreData


extension ParkingSlot {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ParkingSlot> {
        return NSFetchRequest<ParkingSlot>(entityName: "ParkingSlot")
    }

    @NSManaged public var totalSlots: Int16
    @NSManaged public var slots: NSSet?

}

// MARK: Generated accessors for slots
extension ParkingSlot {

    @objc(addSlotsObject:)
    @NSManaged public func addToSlots(_ value: ParkingSlotData)

    @objc(removeSlotsObject:)
    @NSManaged public func removeFromSlots(_ value: ParkingSlotData)

    @objc(addSlots:)
    @NSManaged public func addToSlots(_ values: NSSet)

    @objc(removeSlots:)
    @NSManaged public func removeFromSlots(_ values: NSSet)

}

extension ParkingSlot : Identifiable {

}
