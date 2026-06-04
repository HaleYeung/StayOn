import Foundation
import UserNotifications
import SwiftData

@MainActor
final class NotificationScheduler: Observable {
    static let shared = NotificationScheduler()

    private let center = UNUserNotificationCenter.current()

    private init() {}

    // MARK: - Medication Notifications

    func scheduleMedicationNotification(
        for event: MedicationEvent,
        medicationName: String,
        dosage: String?,
        at date: Date
    ) async {
        let content = UNMutableNotificationContent()
        content.title = NotificationTextBuilder.medicationTitle()
        content.body = NotificationTextBuilder.medicationBody(
            medicationName: medicationName,
            dosage: dosage
        )
        content.sound = .default
        content.categoryIdentifier = "MEDICATION"
        content.userInfo = ["eventId": event.id.uuidString]

        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: date
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let identifier = NotificationIdentifiers.medication(eventId: event.id)
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )

        do {
            try await center.add(request)
        } catch {
            print("Failed to schedule notification: \(error)")
        }
    }

    func scheduleMedicationSnooze(
        for event: MedicationEvent,
        medicationName: String,
        minutes: Int
    ) async {
        let content = UNMutableNotificationContent()
        content.title = NotificationTextBuilder.medicationTitle()
        content.body = NotificationTextBuilder.medicationBody(
            medicationName: medicationName,
            dosage: nil
        )
        content.sound = .default
        content.categoryIdentifier = "MEDICATION"
        content.userInfo = ["eventId": event.id.uuidString]

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: TimeInterval(minutes * 60),
            repeats: false
        )

        let identifier = "\(NotificationIdentifiers.medication(eventId: event.id))-snooze"
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )

        do {
            try await center.add(request)
        } catch {
            print("Failed to schedule snooze notification: \(error)")
        }
    }

    func cancelMedicationNotification(for eventId: UUID) {
        let identifiers = [
            NotificationIdentifiers.medication(eventId: eventId),
            "\(NotificationIdentifiers.medication(eventId: eventId))-snooze"
        ]
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    // MARK: - Sleep Notifications

    func scheduleSleepNotifications(for event: SleepEvent) async {
        await scheduleSleepPreReminder(for: event)
        await scheduleSleepFinalReminder(for: event)
    }

    private func scheduleSleepPreReminder(for event: SleepEvent) async {
        let content = UNMutableNotificationContent()
        content.title = NotificationTextBuilder.sleepPreReminderTitle()
        content.body = NotificationTextBuilder.sleepPreReminderBody(minutes: 30)
        content.sound = .default
        content.categoryIdentifier = "SLEEP"
        content.userInfo = ["eventId": event.id.uuidString, "type": "pre"]

        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: event.preReminderAt
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let identifier = NotificationIdentifiers.sleepPre(eventId: event.id)
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )

        do {
            try await center.add(request)
        } catch {
            print("Failed to schedule sleep pre reminder: \(error)")
        }
    }

    private func scheduleSleepFinalReminder(for event: SleepEvent) async {
        let content = UNMutableNotificationContent()
        content.title = NotificationTextBuilder.sleepReminderTitle()
        content.body = NotificationTextBuilder.sleepReminderBody()
        content.sound = .default
        content.categoryIdentifier = "SLEEP"
        content.userInfo = ["eventId": event.id.uuidString, "type": "final"]

        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: event.finalReminderAt
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let identifier = NotificationIdentifiers.sleepFinal(eventId: event.id)
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )

        do {
            try await center.add(request)
        } catch {
            print("Failed to schedule sleep final reminder: \(error)")
        }
    }

    func scheduleSleepSnooze(for event: SleepEvent, minutes: Int) async {
        let content = UNMutableNotificationContent()
        content.title = NotificationTextBuilder.sleepReminderTitle()
        content.body = NotificationTextBuilder.sleepReminderBody()
        content.sound = .default
        content.categoryIdentifier = "SLEEP"
        content.userInfo = ["eventId": event.id.uuidString, "type": "snooze"]

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: TimeInterval(minutes * 60),
            repeats: false
        )

        let identifier = "\(NotificationIdentifiers.sleepFinal(eventId: event.id))-snooze"
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )

        do {
            try await center.add(request)
        } catch {
            print("Failed to schedule sleep snooze: \(error)")
        }
    }

    func cancelSleepNotification(for eventId: UUID) {
        let identifiers = [
            NotificationIdentifiers.sleepPre(eventId: eventId),
            NotificationIdentifiers.sleepFinal(eventId: eventId),
            "\(NotificationIdentifiers.sleepFinal(eventId: eventId))-snooze"
        ]
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    // MARK: - Meal Notifications

    func scheduleMealNotification(for rule: MealRule) async {
        let content = UNMutableNotificationContent()
        content.title = NotificationTextBuilder.mealReminderTitle()
        content.body = NotificationTextBuilder.mealReminderBody(
            tags: rule.templateTags,
            customNote: rule.customNote
        )
        content.sound = .default
        content.categoryIdentifier = "MEAL"
        content.userInfo = ["mealType": rule.mealTypeRaw]

        let components = Calendar.current.dateComponents(
            [.hour, .minute], from: rule.reminderTime
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

        let identifier = NotificationIdentifiers.meal(mealType: rule.mealType)
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )

        do {
            try await center.add(request)
        } catch {
            print("Failed to schedule meal notification: \(error)")
        }
    }

    func cancelMealNotification(for mealType: MealType) {
        let identifier = NotificationIdentifiers.meal(mealType: mealType)
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
    }

    // MARK: - NightSnack Notifications

    func scheduleNightSnackNotification(at time: Date) async {
        let content = UNMutableNotificationContent()
        content.title = NotificationTextBuilder.nightSnackTitle()
        content.body = NotificationTextBuilder.nightSnackBody()
        content.sound = .default
        content.categoryIdentifier = "NIGHT_SNACK"

        let components = Calendar.current.dateComponents(
            [.hour, .minute], from: time
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

        let identifier = NotificationIdentifiers.nightSnack(identifier: "daily")
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )

        do {
            try await center.add(request)
        } catch {
            print("Failed to schedule night snack notification: \(error)")
        }
    }

    func cancelNightSnackNotification() {
        let identifier = NotificationIdentifiers.nightSnack(identifier: "daily")
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
    }

    // MARK: - Schedule all today's notifications from events

    /// Schedule all pending notifications for today.
    /// Called after DailyEventGenerator has created today's events.
    static func scheduleTodayNotifications(modelContext: ModelContext) async {
        let today = Calendar.current.startOfDay(for: .now)
        guard let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today) else { return }
        let shared = NotificationScheduler.shared

        // Medication events
        let medDescriptor = FetchDescriptor<MedicationEvent>(
            predicate: #Predicate { $0.scheduledAt >= today && $0.scheduledAt < tomorrow && $0.statusRaw == "pending" }
        )
        if let medEvents = try? modelContext.fetch(medDescriptor) {
            for event in medEvents {
                await shared.scheduleMedicationNotification(
                    for: event,
                    medicationName: event.medicationName,
                    dosage: event.dosageText,
                    at: event.scheduledAt
                )
            }
        }

        // Sleep event
        let sleepDescriptor = FetchDescriptor<SleepEvent>(
            predicate: #Predicate { $0.date >= today && $0.statusRaw == "pending" }
        )
        if let sleepEvents = try? modelContext.fetch(sleepDescriptor),
           let sleepEvent = sleepEvents.first {
            await shared.scheduleSleepNotifications(for: sleepEvent)
        }

        // Meal rules (daily repeating)
        let mealDescriptor = FetchDescriptor<MealRule>(
            predicate: #Predicate { $0.isActive == true && $0.mealTypeRaw != "nightSnack" }
        )
        if let mealRules = try? modelContext.fetch(mealDescriptor) {
            for rule in mealRules {
                await shared.scheduleMealNotification(for: rule)
            }
        }

        // Night snack (daily repeating)
        let nsDescriptor = FetchDescriptor<MealRule>(
            predicate: #Predicate { $0.isActive == true && $0.mealTypeRaw == "nightSnack" }
        )
        if let nsRules = try? modelContext.fetch(nsDescriptor),
           let nsRule = nsRules.first {
            await shared.scheduleNightSnackNotification(at: nsRule.reminderTime)
        }
    }

    // MARK: - General

    func cancelAllNotifications() {
        center.removeAllPendingNotificationRequests()
    }
}
