import Foundation
import UserNotifications
import SwiftData

@MainActor
final class NotificationManager: NSObject, Observable {
    static let shared = NotificationManager()

    private let center = UNUserNotificationCenter.current()

    override private init() {
        super.init()
    }

    func requestAuthorization() async -> Bool {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            return granted
        } catch {
            return false
        }
    }

    /// Request notification permission after user saves their first plan.
    /// Only prompts if permission has never been asked before (PRD 10.1).
    func requestIfFirstPlan(modelContext: ModelContext) async {
        let status = await getAuthorizationStatus()
        guard status == .notDetermined else { return }

        let descriptor = FetchDescriptor<AppSettings>()
        let settings = (try? modelContext.fetch(descriptor))?.first

        let granted = await requestAuthorization()
        if let settings {
            settings.hasSeenNotificationPrompt = granted
        }
        try? modelContext.save()
    }

    func getAuthorizationStatus() async -> UNAuthorizationStatus {
        let settings = await center.notificationSettings()
        return settings.authorizationStatus
    }

    func registerCategories() {
        let doneAction = UNNotificationAction(
            identifier: "DONE",
            title: "已吃",
            options: []
        )

        let snoozeAction = UNNotificationAction(
            identifier: "SNOOZE",
            title: "稍后提醒",
            options: []
        )

        let skipAction = UNNotificationAction(
            identifier: "SKIP",
            title: "跳过",
            options: [.destructive]
        )

        let goodNightAction = UNNotificationAction(
            identifier: "GOOD_NIGHT",
            title: "晚安",
            options: []
        )

        let acknowledgeAction = UNNotificationAction(
            identifier: "ACKNOWLEDGE",
            title: "知道了",
            options: []
        )

        let medicationCategory = UNNotificationCategory(
            identifier: "MEDICATION",
            actions: [doneAction, snoozeAction, skipAction],
            intentIdentifiers: [],
            options: []
        )

        let sleepCategory = UNNotificationCategory(
            identifier: "SLEEP",
            actions: [goodNightAction, snoozeAction],
            intentIdentifiers: [],
            options: []
        )

        let mealCategory = UNNotificationCategory(
            identifier: "MEAL",
            actions: [acknowledgeAction],
            intentIdentifiers: [],
            options: []
        )

        let nightSnackCategory = UNNotificationCategory(
            identifier: "NIGHT_SNACK",
            actions: [acknowledgeAction],
            intentIdentifiers: [],
            options: []
        )

        center.setNotificationCategories([
            medicationCategory,
            sleepCategory,
            mealCategory,
            nightSnackCategory
        ])
    }
}