//
//  Ticket+CoreDataProperties.swift
//  ClinicApp
//
//  Created by macOS on 11.06.26.
//
//

import Foundation
import CoreData


extension Ticket {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Ticket> {
        return NSFetchRequest<Ticket>(entityName: "Ticket")
    }

    @NSManaged public var id: Int64
    @NSManaged public var userId: Int64
    @NSManaged public var doctorId: Int64
    @NSManaged public var appointmentDate: Date?
    @NSManaged public var appointmentTime: String?

}

extension Ticket : Identifiable {

}
