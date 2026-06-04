import Foundation

enum NotificationIdentifiers {
    static func medication(eventId: UUID) -> String {
        "medication-\(eventId.uuidString)"
    }

    static func sleepPre(eventId: UUID) -> String {
        "sleep-pre-\(eventId.uuidString)"
    }

    static func sleepFinal(eventId: UUID) -> String {
        "sleep-final-\(eventId.uuidString)"
    }

    static func meal(eventId: UUID) -> String {
        "meal-\(eventId.uuidString)"
    }

    static func meal(mealType: MealType) -> String {
        "meal-daily-\(mealType.rawValue)"
    }

    static func nightSnack(eventId: UUID) -> String {
        "nightSnack-\(eventId.uuidString)"
    }

    static func nightSnack(identifier: String) -> String {
        "nightSnack-daily-\(identifier)"
    }
}