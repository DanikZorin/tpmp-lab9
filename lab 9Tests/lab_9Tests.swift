import XCTest
import CoreData
@testable import lab_9

final class lab_9Tests: XCTestCase {

    var context: NSManagedObjectContext!

    override func setUpWithError() throws {
        let container = NSPersistentContainer(name: "ClinicApp")
        let description = NSPersistentStoreDescription()
        description.url = URL(fileURLWithPath: "/dev/null")
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Core Data error: \(error)")
            }
        }
        context = container.viewContext
    }

    override func tearDownWithError() throws {
        context = nil
    }

    // MARK: - Тесты пользователя (User)

    func testCreateUser() throws {
        let user = User(context: context)
        user.id = 1
        user.login = "test@test.com"
        user.password = "123456"
        user.fullName = "Ivanov Ivan"
        user.birthDate = "01.01.1990"
        try context.save()

        let request: NSFetchRequest<User> = User.fetchRequest()
        request.predicate = NSPredicate(format: "login == %@", "test@test.com")
        let result = try context.fetch(request)

        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.fullName, "Ivanov Ivan")
    }

    func testUserLoginExists() throws {
        let user = User(context: context)
        user.id = 2
        user.login = "existing@test.com"
        user.password = "pass"
        try context.save()

        let request: NSFetchRequest<User> = User.fetchRequest()
        request.predicate = NSPredicate(format: "login == %@", "existing@test.com")
        let result = try context.fetch(request)

        XCTAssertEqual(result.count, 1)
    }

    func testUserLoginDoesNotExist() throws {
        let request: NSFetchRequest<User> = User.fetchRequest()
        request.predicate = NSPredicate(format: "login == %@", "nonexistent@test.com")
        let result = try context.fetch(request)
        XCTAssertEqual(result.count, 0)
    }

    // MARK: - Тесты поликлиники (Clinic)

    func testCreateClinic() throws {
        let clinic = Clinic(context: context)
        clinic.id = 1
        clinic.address = "Minsk, Surganova str., 24"
        try context.save()

        let request: NSFetchRequest<Clinic> = Clinic.fetchRequest()
        let result = try context.fetch(request)
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.address, "Minsk, Surganova str., 24")
    }

    // MARK: - Тесты врачей (Doctor)

    func testCreateDoctor() throws {
        let doctor = Doctor(context: context)
        doctor.id = 101
        doctor.fullName = "Akulich Elena"
        doctor.specialization = "Ophthalmologist"
        doctor.clinicId = 1
        try context.save()

        let request: NSFetchRequest<Doctor> = Doctor.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", 101)
        let result = try context.fetch(request)
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.fullName, "Akulich Elena")
    }

    func testDoctorsForClinic() throws {
        let clinic = Clinic(context: context)
        clinic.id = 5
        try context.save()

        let doctor1 = Doctor(context: context)
        doctor1.id = 501
        doctor1.clinicId = 5
        try context.save()

        let doctor2 = Doctor(context: context)
        doctor2.id = 502
        doctor2.clinicId = 5
        try context.save()

        let request: NSFetchRequest<Doctor> = Doctor.fetchRequest()
        request.predicate = NSPredicate(format: "clinicId == %d", 5)
        let result = try context.fetch(request)
        XCTAssertEqual(result.count, 2)
    }

    // MARK: - Тесты талонов (Ticket)

    func testCreateTicket() throws {
        let ticket = Ticket(context: context)
        ticket.id = 1001
        ticket.userId = 1
        ticket.doctorId = 101
        ticket.appointmentDate = Date()
        ticket.appointmentTime = "10:30"
        try context.save()

        let request: NSFetchRequest<Ticket> = Ticket.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", 1001)
        let result = try context.fetch(request)
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.appointmentTime, "10:30")
    }

    func testTicketsForUser() throws {
        let ticket1 = Ticket(context: context)
        ticket1.id = 2001
        ticket1.userId = 10
        try context.save()

        let ticket2 = Ticket(context: context)
        ticket2.id = 2002
        ticket2.userId = 10
        try context.save()

        let request: NSFetchRequest<Ticket> = Ticket.fetchRequest()
        request.predicate = NSPredicate(format: "userId == %d", 10)
        let result = try context.fetch(request)
        XCTAssertEqual(result.count, 2)
    }

    func testCancelTicket() throws {
        let ticket = Ticket(context: context)
        ticket.id = 3001
        ticket.userId = 20
        try context.save()

        context.delete(ticket)
        try context.save()

        let request: NSFetchRequest<Ticket> = Ticket.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", 3001)
        let result = try context.fetch(request)
        XCTAssertEqual(result.count, 0)
    }

    func testRescheduleTicket() throws {
        let ticket = Ticket(context: context)
        ticket.id = 4001
        ticket.appointmentTime = "09:00"
        try context.save()

        ticket.appointmentTime = "14:00"
        try context.save()

        let request: NSFetchRequest<Ticket> = Ticket.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", 4001)
        let result = try context.fetch(request)
        XCTAssertEqual(result.first?.appointmentTime, "14:00")
    }
}
