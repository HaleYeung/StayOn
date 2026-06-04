import SwiftUI
import SwiftData

@main
struct StayOnApp: App {
    let modelContainer: ModelContainer

    init() {
        func createContainer() throws -> ModelContainer {
            try ModelContainer(
                for: Medication.self,
                     MedicationEvent.self,
                     SleepPlan.self,
                     SleepEvent.self,
                     MealRule.self,
                     MealEvent.self,
                     NightSnackEvent.self,
                     AppSettings.self
            )
        }

        do {
            modelContainer = try createContainer()
        } catch {
            // Schema changed — delete old store files and create fresh one
            let defaultConfig = ModelConfiguration()
            let storeUrl = defaultConfig.url
            try? FileManager.default.removeItem(at: storeUrl)
            try? FileManager.default.removeItem(at: storeUrl.appendingPathExtension("sqlite-wal"))
            try? FileManager.default.removeItem(at: storeUrl.appendingPathExtension("sqlite-shm"))
            do {
                modelContainer = try createContainer()
            } catch {
                fatalError("Could not initialize ModelContainer: \(error)")
            }
        }

        UNUserNotificationCenter.current().delegate = NotificationActionHandler.shared
        NotificationActionHandler.shared.setModelContext(modelContainer.mainContext)
        NotificationManager.shared.registerCategories()
    }

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .modelContainer(modelContainer)
        }
    }
}
