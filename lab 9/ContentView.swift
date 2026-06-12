import SwiftUI
import CoreData

struct ContentView: View {
    @State private var isLoggedIn: Bool = false

    var body: some View {
        if !isLoggedIn {
            LoginView(isLoggedIn: $isLoggedIn)
        } else {
            MainView(isLoggedIn: $isLoggedIn)
        }
    }
}

struct LeftText: View{
    let text: LocalizedStringKey
    let color: Color
    
    init(text: LocalizedStringKey) {
        self.text = text
        self.color = Color(uiColor: .systemGray3)
    }

    init(text: LocalizedStringKey, color: Color) {
        self.text = text
        self.color = color
    }
    var body: some View{
        HStack{
            Text(text)
                .foregroundStyle(color)
            Spacer()
        }.padding(.horizontal)
    }
}
struct LeftTextAlt: View{
    let text: String
    let color: Color
    
    init(text: String) {
        self.text = text
        self.color = Color(uiColor: .systemGray3)
    }

    init(text: String, color: Color) {
        self.text = text
        self.color = color
    }
    var body: some View{
        HStack{
            Text(text)
                .foregroundStyle(color)
            Spacer()
        }.padding(.horizontal)
    }
}
struct MyTextField: View{
    let title: LocalizedStringKey
    @Binding var value: String
    
    var body: some View{
        TextField("", text: $value)
            .textFieldStyle(.plain)
            .padding(.horizontal)
        Divider()
            .padding(.horizontal)
        
        LeftText(text: title)
    }
}
struct MyPasswordField: View{
    let title: LocalizedStringKey
    @Binding var value: String
    
    var body: some View{
        SecureField("", text: $value)
            .textFieldStyle(.plain)
            .padding(.horizontal)
        Divider()
            .padding(.horizontal)
        
        LeftText(text: title)
    }
}
// MARK: - ЭКРАН АВТОРИЗАЦИИ
struct LoginView: View {

    @Environment(\.managedObjectContext) private var viewContext
    
    @Binding var isLoggedIn: Bool
    @State private var login = ""
    @State private var password = ""
    

    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 7) {
                Group {
                    MyTextField(title: "Телефон/email", value: $login)
                    MyPasswordField(title: "Пароль", value: $password)

                    Button(action: loginUser) {
                        Text("Войти")
                            .foregroundStyle(.black)
                            .padding()
                            .background(.white)
                            .cornerRadius(32)
                            .shadow(radius: 10)
                    }
                    .padding()
                    
                    NavigationLink(destination: RegistrationView(isLoggedIn: $isLoggedIn)) {
                        Text("Зарегистрироваться")
                            .foregroundStyle(.blue)
                    }
                }
                Spacer()
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Вход")
                }
            }
            .alert("Ошибка", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func loginUser() {
        if login.isEmpty || password.isEmpty {
            alertMessage = "Заполните все поля"
            showAlert = true
            return
        }
        
        guard viewContext.persistentStoreCoordinator?.persistentStores.isEmpty == false else {
            alertMessage = "Критическая ошибка: База данных Core Data не загружена!"
            showAlert = true
            return
        }
        
        let request = NSFetchRequest<User>(entityName: "User")
        request.predicate = NSPredicate(format: "login == %@ AND password == %@", login, password)
        
        do {
            let results = try viewContext.fetch(request)
            
            if let foundUser = results.first {
                UserDefaults.standard.set(foundUser.id, forKey: "currentUserId")
                isLoggedIn = true
            } else {
                alertMessage = "Неверный логин или пароль"
                showAlert = true
            }
        } catch {
 
            alertMessage = "Ошибка базы данных: \(error.localizedDescription)"
            showAlert = true
        }
    }

}

// MARK: - ЭКРАН РЕГИСТРАЦИИ
struct RegistrationView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @Binding var isLoggedIn: Bool
    @State private var email = ""
    @State private var phone = ""
    @State private var password = ""
    @State private var password2 = ""
    @State private var FIO = ""
    @State private var dateOfBirth = Date()
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        VStack(spacing: 8) {
            Group {
                MyTextField(title: "Телефон", value: $phone)
                MyTextField(title: "Почта", value: $email)
                MyPasswordField(title: "Пароль", value: $password)
                MyPasswordField(title: "Повторите пароль", value: $password2)
                MyTextField(title: "ФИО", value: $FIO)

                HStack {
                    DatePicker("", selection: $dateOfBirth, in: ...Date(), displayedComponents: .date)
                        .labelsHidden()
                        .datePickerStyle(.compact)
                        .padding(.horizontal)
                    Spacer()
                }
                Divider()
                    .padding(.horizontal)
                
                HStack {
                    Text("Дата рождения")
                        .foregroundStyle(Color(.systemGray3))
                    Spacer()
                }.padding(.horizontal)
                
                Button(action: registerUser) {
                    Text("Зарегистрироваться")
                        .foregroundStyle(.black)
                        .padding()
                        .background(.white)
                        .cornerRadius(32)
                        .shadow(radius: 10)
                }
                .padding()
            }
            Spacer()
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Регистрация")
            }
        }
        .alert("Внимание", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func registerUser() {

        if phone.isEmpty || email.isEmpty || password.isEmpty || FIO.isEmpty {
            alertMessage = "Пожалуйста, заполните все поля"
            showAlert = true
            return
        }
        
        if password != password2 {
            alertMessage = "Пароли не совпадают"
            showAlert = true
            return
        }
        
        let userLogin = phone
        
        let request: NSFetchRequest<User> = User.fetchRequest()
        request.predicate = NSPredicate(format: "login == %@", userLogin)
        
        do {
            let count = try viewContext.count(for: request)
            if count > 0 {
                alertMessage = "Пользователь с таким телефоном уже зарегистрирован"
                showAlert = true
                return
            }
            
            let newUser = User(context: viewContext)
            newUser.id = Int64(Date().timeIntervalSince1970)
            newUser.fullName = FIO
            newUser.login = userLogin
            newUser.password = password
            
            let formatter = DateFormatter()
            formatter.dateFormat = "dd.MM.yyyy"
            newUser.birthDate = formatter.string(from: dateOfBirth)
            
            try viewContext.save()
            UserDefaults.standard.set(newUser.id, forKey: "currentUserId")
            isLoggedIn = true
            
        } catch {
            alertMessage = "Не удалось сохранить данные: \(error.localizedDescription)"
            showAlert = true
        }
    }
}
struct RecordView: View{
    @Environment(\.managedObjectContext) private var viewContext
    private func generateSampleData() {
        let clinic1 = Clinic(context: viewContext)
        clinic1.id = 1
        clinic1.address = "г. Минск, ул. Сурганова, д. 24"
        
        let doc1 = Doctor(context: viewContext)
        doc1.id = 101
        doc1.fullName = "Акулич Елена Викторовна"
        doc1.specialization = "Офтальмолог"
        doc1.clinicId = clinic1.id
        clinic1.addToDoctors(doc1)
        
        let doc2 = Doctor(context: viewContext)
        doc2.id = 102
        doc2.fullName = "Борисевич Иван Игоревич"
        doc2.specialization = "Невролог"
        doc2.clinicId = clinic1.id
        clinic1.addToDoctors(doc2)

        let clinic2 = Clinic(context: viewContext)
        clinic2.id = 2
        clinic2.address = "г. Минск, пр-т Победителей, д. 89"
        
        let doc3 = Doctor(context: viewContext)
        doc3.id = 201
        doc3.fullName = "Григорьев Олег Петрович"
        doc3.specialization = "Педиатр"
        doc3.clinicId = clinic2.id
        clinic2.addToDoctors(doc3)

        do {
            try viewContext.save()
        } catch {
            print("Ошибка сохранения: \(error.localizedDescription)")
        }
    }
    @FetchRequest( sortDescriptors: [NSSortDescriptor(keyPath: \Clinic.id, ascending: true)], animation: .default)
   private var clinics: FetchedResults<Clinic>
    var body: some View {
        NavigationView {
                ScrollView {
                    VStack(spacing: 16) {
                        if clinics.isEmpty {

                            VStack(spacing: 20) {
                                Text("Список клиник пуст")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                                
                                Button(action: generateSampleData) {
                                    Text("Загрузить данные")
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .padding()
                                        .background(Color.blue)
                                        .cornerRadius(12)
                                }
                                
                            }
                            .padding(.top, 100)
                        } else {
                            
                            ForEach(clinics) { clinic in
                                NavigationLink(destination: DoctorsListView(clinic: clinic)) {
                                    ClinicCardButton(clinic: clinic)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    .padding()
                }.toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Поликлиники")
                }
            }
        }
    }
}
// MARK: - ЭКРАН СПИСКА ВРАЧЕЙ ВЫБРАННОЙ КЛИНИКИ
struct DoctorsListView: View {
    let clinic: Clinic
    
    var body: some View {
        let doctorsArray = (clinic.doctors?.allObjects as? [Doctor])?
            .sorted { ($0.fullName ?? "") < ($1.fullName ?? "") } ?? []
        
        ScrollView {
            VStack(spacing: 16) {
                if doctorsArray.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "person.crop.circle.badge.exclamationmark")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("В данной клинике нет свободных специалистов")
                            .font(.headline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 100)
                } else {
                    ForEach(doctorsArray) { doctor in
                        NavigationLink(destination: DoctorDetailView(doctor: doctor)) {
                            DoctorCardButton(doctor: doctor)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Врачи поликлиники №\(clinic.id)")
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }
}

// MARK: - КОМПОНЕНТ КНОПКИ-КАРТОЧКИ ВРАЧА
struct DoctorCardButton: View {
    let doctor: Doctor
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "person.fill.viewfinder")
                        .foregroundColor(.blue)
                        .font(.title2)
                    
                    Text(doctor.fullName ?? "Неизвестный специалист")
                        .font(.headline)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                }
                
                Text(doctor.specialization ?? "Общий профиль")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("Личный ID: \(doctor.id)")
                    .font(.caption)
                    .foregroundColor(.blue)
                    .padding(.top, 2)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
                .font(.footnote)
        }
        .padding()
        .background(Color(.white))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Меню врача
struct DoctorDetailView: View {
        @Environment(\.managedObjectContext) private var viewContext
       @Environment(\.dismiss) private var dismiss
       
       let doctor: Doctor
    
        var editingTicket: Ticket? = nil

        @State private var selectedDate = Date()
       @State private var selectedTime = "09:00"
       @State private var showAlert = false
        @State private var alertMessage: LocalizedStringKey = ""
       
       let timeSlots = ["08:30", "09:00", "09:30", "10:00", "10:30", "11:00", "11:30", "14:00", "14:30", "15:00", "15:30", "16:00", "16:30"]
       
       var body: some View {
           ScrollView {
               VStack(spacing: 24) {
                   
                   HStack {
                       VStack(alignment: .leading, spacing: 8) {
                           Text(doctor.fullName ?? "Неизвестный врач")
                               .font(.title2)
                               .bold()
                           
                           Text(doctor.specialization ?? "Специалист")
                               .font(.headline)
                               .foregroundColor(.blue)
                           
                           Text("Личный код сотрудника: \(doctor.id)")
                               .font(.caption)
                               .foregroundColor(.secondary)
                       }
                       Spacer()
                       
                       Image(systemName: "person.crop.circle.fill")
                           .font(.system(size: 60))
                           .foregroundColor(.blue.opacity(0.2))
                   }
                   .padding()
                   .background(Color.white)
                   .cornerRadius(16)
                   .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                   
                   VStack(alignment: .leading, spacing: 12) {
                       LeftText(text: "1. Выберите дату приема", color: .primary)
                           .font(.subheadline)
                       
                       DatePicker("", selection: $selectedDate, in: Date()..., displayedComponents: .date)
                           .datePickerStyle(.graphical)
                           .accentColor(.blue)
                           .padding()
                           .background(Color.white)
                           .cornerRadius(16)
                           .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                   }
                   

                   VStack(alignment: .leading, spacing: 12) {
                       LeftText(text: "2. Выберите доступное время", color: .primary)
                           .font(.subheadline)
                       
                       ScrollView(.horizontal, showsIndicators: false) {
                           HStack(spacing: 12) {
                               ForEach(timeSlots, id: \.self) { time in
                                   Text(time)
                                       .font(.system(size: 16, weight: .medium))
                                       .padding(.horizontal, 16)
                                       .padding(.vertical, 12)
                                       .background(selectedTime == time ? Color.blue : Color.white)
                                       .foregroundColor(selectedTime == time ? .white : .primary)
                                       .cornerRadius(12)
                                       .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 2)
                                       .onTapGesture {
                                           selectedTime = time
                                       }
                               }
                           }
                           .padding(.horizontal, 4)
                           .padding(.vertical, 8)
                       }
                   }
                   

                   Button(action: saveAppointment) {
                       Text("Подтвердить запись")
                           .font(.headline)
                           .foregroundColor(.black)
                           .frame(maxWidth: .infinity)
                           .padding()
                           .background(Color.white)
                           .cornerRadius(32)
                           .shadow(radius: 10)
                   }
                   .padding(.top, 8)
                   
                   Spacer()
               }
               .padding()
           }
           .navigationTitle("Запись на прием")
           .background(Color(.systemGroupedBackground).ignoresSafeArea())
           .alert("Успешно", isPresented: $showAlert) {
               Button("Отлично") {
                   dismiss()
               }
           } message: {
               Text(alertMessage)
           }.onAppear {
               if let oldTime = editingTicket?.appointmentTime { selectedTime = oldTime }
               if let oldDate = editingTicket?.appointmentDate { selectedDate = oldDate }
           }
       }
       
    private func saveAppointment() {
            let calendar = Calendar.current
            let components = calendar.dateComponents([.year, .month, .day], from: selectedDate)
            let formattedDate = calendar.date(from: components)
            
            if let ticket = editingTicket {

                ticket.appointmentDate = formattedDate
                ticket.appointmentTime = selectedTime
                alertMessage = "Запись успешно перенесена!"
            } else {

                let currentUserId = UserDefaults.standard.integer(forKey: "currentUserId")
                let newTicket = Ticket(context: viewContext)
                newTicket.id = Int64(Date().timeIntervalSince1970)
                newTicket.doctorId = doctor.id
                newTicket.userId = Int64(currentUserId)
                newTicket.appointmentTime = selectedTime
                newTicket.appointmentDate = formattedDate
                alertMessage = "Вы успешно записаны!"
            }
            
            try? viewContext.save()
            showAlert = true
        }
   }

struct ClinicCardButton: View {
    let clinic: Clinic
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {

                HStack {
                    Image(systemName: "cross.case.fill")
                        .foregroundColor(.blue)
                        .font(.title2)
                    
                    Text("Поликлиника №\(clinic.id)")
                        .font(.headline)
                        .foregroundColor(.primary)
                }
                
                Text(clinic.address ?? "Адрес не указан")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
                
                let doctorsCount = clinic.doctors?.count ?? 0
                Text("Врачей в клинике: \(doctorsCount)")
                    .font(.caption)
                    .foregroundColor(.blue)
                    .padding(.top, 2)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
                .font(.footnote)
        }
        .padding()
        .background(Color(.white))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}
struct TalonView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest private var myTickets: FetchedResults<Ticket>
    
    @State private var showingDeleteAlert = false
    @State private var ticketToDelete: Ticket? = nil
    
    init() {
        let userId = Int64(UserDefaults.standard.integer(forKey: "currentUserId"))
        _myTickets = FetchRequest<Ticket>(
            sortDescriptors: [NSSortDescriptor(keyPath: \Ticket.appointmentDate, ascending: true)],
            predicate: NSPredicate(format: "userId == %DI", userId),
            animation: .default
        )
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    if myTickets.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "calendar.badge.clock").font(.system(size: 60)).foregroundColor(.gray)
                            Text("У вас пока нет активных записей").font(.headline).foregroundColor(.gray)
                        }
                        .padding(.top, 120)
                    } else {
                        ForEach(myTickets) { ticket in

                            let doctor = fetchDoctor(for: ticket.doctorId)
                            
                            VStack(spacing: 0) {
                                TicketCardView(ticket: ticket, doctor: doctor, onDelete: {
                                    ticketToDelete = ticket
                                    showingDeleteAlert = true
                                })
                                
                                if let doctor = doctor {
                                    NavigationLink(destination: DoctorDetailView(doctor: doctor, editingTicket: ticket)) {
                                        HStack {
                                            Image(systemName: "calendar.badge.clock")
                                            Text("Перенести запись")
                                        }
                                        .font(.subheadline).foregroundColor(.blue)
                                        .frame(maxWidth: .infinity).padding(.vertical, 12)
                                        .background(Color.blue.opacity(0.05)).cornerRadius(12)
                                    }
                                    .padding([.horizontal, .bottom])
                                    .background(Color.white)
                                }
                            }
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Мои записи")
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .alert("Отмена записи", isPresented: $showingDeleteAlert) {
                Button("Да, отменить", role: .destructive) { if let t = ticketToDelete { confirmDelete(t) } }
                Button("Назад", role: .cancel) { ticketToDelete = nil }
            } message: { Text("Вы уверены, что хотите отменить эту запись?") }
        }
    }
    
    private func confirmDelete(_ ticket: Ticket) {
        withAnimation {
            viewContext.delete(ticket)
            try? viewContext.save()
            ticketToDelete = nil
        }
    }
    
    private func fetchDoctor(for doctorId: Int64) -> Doctor? {
        let request = NSFetchRequest<Doctor>(entityName: "Doctor")
        request.predicate = NSPredicate(format: "id == %DI", doctorId)
        request.fetchLimit = 1
        return try? viewContext.fetch(request).first
    }
}

struct TicketCardView: View {
    let ticket: Ticket
    let doctor: Doctor?
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                    Text(formatDate(ticket.appointmentDate))
                }
                .font(.subheadline).foregroundColor(.blue)
                Spacer()
                Text(ticket.appointmentTime ?? "--:--")
                    .font(.subheadline).fontWeight(.bold).padding(.horizontal, 10).padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1)).foregroundColor(.blue).cornerRadius(8)
            }
            Divider()
            HStack(spacing: 12) {
                Image(systemName: "stethoscope").font(.title).foregroundColor(.gray).frame(width: 40, height: 40).background(Color(.systemGray6)).cornerRadius(8)
                VStack(alignment: .leading, spacing: 4) {
                    Text(doctor?.fullName ?? "Врач не найден").font(.headline)
                    Text(doctor?.specialization ?? "Специализация неизвестна").font(.subheadline).foregroundColor(.secondary)
                }
            }
            Divider()
            Button(action: onDelete) {
                HStack { Image(systemName: "trash"); Text("Отменить эту запись") }
                    .font(.subheadline).foregroundColor(.red).frame(maxWidth: .infinity).padding(.vertical, 8)
            }
        }
        .padding([.horizontal, .top])
        .background(Color.white)
    }
    
    private func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        let savedLanguage = UserDefaults.standard.string(forKey: "selectedLanguageCode") ?? "RU"
            
        switch savedLanguage {
        case "EN":
            formatter.locale = Locale(identifier: "en_US")
        case "BE":
            formatter.locale = Locale(identifier: "be_BY")
        default:
            formatter.locale = Locale(identifier: "ru_RU")
        }
        return formatter.string(from: date)
    }
}
struct ProfileView: View{
    @AppStorage("selectedLanguageCode") private var selectedLanguage = "RU"
    @Binding var isLoggedIn: Bool

    let languages = ["RU", "BE", "EN"]
    
    @Environment(\.managedObjectContext) private var viewContext
        
    private var currentUserId: Int64 {
        Int64(UserDefaults.standard.integer(forKey: "currentUserId"))
    }
        
    @FetchRequest private var currentUserResults: FetchedResults<User>
        
    init(isLoggedIn: Binding<Bool>) {
        self._isLoggedIn = isLoggedIn
        let userId = Int64(UserDefaults.standard.integer(forKey: "currentUserId"))
        _currentUserResults = FetchRequest<User>(
            sortDescriptors: [],
            predicate: NSPredicate(format: "id == %DI", userId)
        )
    }
    
    var body: some View{
        NavigationView {
            VStack(spacing: 20) {

                if let user = currentUserResults.first {
                
                VStack {
                    LeftTextAlt(text: user.fullName ?? "Не указано", color: Color.black)
                    Divider()
                        .padding(.horizontal)
                    LeftText(text: "ФИО")
                }
                
                VStack {
                    LeftTextAlt(text: user.birthDate ?? "Не указано", color: Color.black)
                    Divider()
                        .padding(.horizontal)
                    LeftText(text: "Дата рождения")
                }
                
                VStack {
                    LeftTextAlt(text: user.login ?? "Не указано", color: Color.black)
                    Divider()
                        .padding(.horizontal)
                    LeftText(text: "Телефон")
                }

                HStack{
                    Text("Язык").padding(.horizontal)
                    Spacer()
                    Picker("Выбор языка", selection: $selectedLanguage) {
                        ForEach(languages, id: \.self) { language in
                            Text(language)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 250)
                    .padding(4)
                    .cornerRadius(20)
                }
                
                Button(action: {
                    isLoggedIn = false
                }) {
                    Text("Выйти из системы")
                        .foregroundStyle(.red)
                        .padding()
                        .background(.white)
                        .cornerRadius(32)
                        .shadow(radius: 10)
                }
                .padding()
                Spacer()
                }
                else {
                    Text("Ошибка загрузки профиля")
                        .foregroundColor(.red)
                        .font(.headline)
                }
            }.toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Профиль")
                }
            }
        }
    }
}
// MARK: - ОСНОВНОЙ ЭКРАН С НАВИГАЦИЕЙ
struct MainView: View {
    @Binding var isLoggedIn: Bool
    init(isLoggedIn: Binding<Bool>) {
        self._isLoggedIn = isLoggedIn
        
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        UITabBar.appearance().scrollEdgeAppearance = appearance
        UITabBar.appearance().standardAppearance = appearance
    }
    
    var body: some View {
        TabView {
            RecordView()
                .tabItem {
                    "🏡".toTabIcon()
                    Text("Запись")
                }
                      
            TalonView()
                .tabItem {
                    "📋".toTabIcon()
                    Text("Мои талоны")
                }
                  
                  
            ProfileView(isLoggedIn: $isLoggedIn)
                .tabItem {
                    "👤".toTabIcon()
                    Text("Профиль")
                }
          }
      
    }
}
extension String {
    func toTabIcon() -> Image {
        let size = CGSize(width: 30, height: 30)
        let renderer = UIGraphicsImageRenderer(size: size)
        let uiImage = renderer.image { _ in
            let rect = CGRect(origin: .zero, size: size)

            (self as NSString).draw(in: rect, withAttributes: [
                .font: UIFont.systemFont(ofSize: 26)
            ])
        }

        return Image(uiImage: uiImage.withRenderingMode(.alwaysOriginal))
    }
}
// MARK: - ПРЕВЬЮ
struct SimplifiedAppView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
