//
//  User+CoreDataProperties.swift
//  ClinicApp
//
//  Created by macOS on 11.06.26.
//
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var birthDate: String?
    @NSManaged public var fullName: String?
    @NSManaged public var id: Int64
    @NSManaged public var login: String?
    @NSManaged public var password: String?

}

extension User : Identifiable {

}
