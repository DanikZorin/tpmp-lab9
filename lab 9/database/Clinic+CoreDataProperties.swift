//
//  Clinic+CoreDataProperties.swift
//  ClinicApp
//
//  Created by macOS on 11.06.26.
//
//

import Foundation
import CoreData


extension Clinic {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Clinic> {
        return NSFetchRequest<Clinic>(entityName: "Clinic")
    }

    @NSManaged public var address: String?
    @NSManaged public var id: Int64
    @NSManaged public var doctors: NSSet?

}

// MARK: Generated accessors for doctors
extension Clinic {

    @objc(addDoctorsObject:)
    @NSManaged public func addToDoctors(_ value: Doctor)

    @objc(removeDoctorsObject:)
    @NSManaged public func removeFromDoctors(_ value: Doctor)

    @objc(addDoctors:)
    @NSManaged public func addToDoctors(_ values: NSSet)

    @objc(removeDoctors:)
    @NSManaged public func removeFromDoctors(_ values: NSSet)

}

extension Clinic : Identifiable {

}
