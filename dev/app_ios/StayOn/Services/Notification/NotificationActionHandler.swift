import Foundation
import UserNotifications
import SwiftData

@MainActor
final class NotificationActionHandler: NSObject, Observable {
    static let shared = NotificationActionHandler()

    private var modelContext: ModelContext?

    private override init() {
        super.init()
    }

    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }

    func handle(action: String, eventId: UUID) async {
        guard let context = modelContext else { return }

        let descriptor = FetchDescriptor<MedicationEvent>()
        let allEvents = (try? context.fetch(descriptor)) ?? []
        guard let event = allEvents.first(where: { $0.id == eventId }) else { return }

        switch action {
        case "DONE":
            event.status = .done
            event.confirmedAt = .now
            NotificationScheduler.shared.cancelMedicationNotification(for: eventId)

        case "SNOOZE":
            event.snoozeCount += 1
            if event.snoozeCount < event.maxSnoozeCount {
                await NotificationScheduler.shared.scheduleMedicationSnooze(
                    for: event,
                    medicationName: event.medicationName,
                    minutes: 10
                )
            }

        case "SKIP":
            event.status = .skipped
            event.skippedAt = .now
            NotificationScheduler.shared.cancelMedicationNotification(for: eventId)

        default:
            break
        }

        try? context.save()
    }
}

extension NotificationActionHandler: UNUserNotificationCenterDelegate {
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let actionIdentifier = response.actionIdentifier
        let userInfo = response.notification.request.content.userInfo

        if let eventIdString = userInfo["eventId"] as? String,
           let eventId = UUID(uuidString: eventIdString) {
            Task { @MainActor in
                await handle(action: actionIdentifier, eventId: eventId)
                completionHandler()
            }
        } else {
            completionHandler()
        }
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }
}
