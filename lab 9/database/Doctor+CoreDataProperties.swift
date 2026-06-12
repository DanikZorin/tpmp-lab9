//
//  Doctor+CoreDataProperties.swift
//  ClinicApp
//
//  Created by macOS on 11.06.26.
//
//

import Foundation
import CoreData


extension Doctor {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Doctor> {
        return NSFetchRequest<Doctor>(entityName: "Doctor")
    }

    @NSManaged public var clinicId: Int64
    @NSManaged public var fullName: String?
    @NSManaged public var id: Int64
    @NSManaged public var specialization: String?
    @NSManaged public var clinic: Clinic?

}

extension Doctor : Identifiable {

}
