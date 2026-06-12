import SwiftUI

@main
struct lab_9App: App {
    let persistenceController = PersistenceController.shared
    @AppStorage("selectedLanguageCode") private var selectedLanguage = "RU"

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environment(\.locale, Locale(identifier: selectedLanguage.lowercased()))
                        
        }
    }
}
