import Foundation
import SwiftData

@Model
final class Medication {
    @Attribute(.unique) var id: UUID
    var name: String
    var dosageText: String?
    var scheduleTypeRaw: String
    var weekdays: [Int]
    var timesPerDay: Int
    var reminderTimes: [Date]
    var mealNote: String?
    var note: String?
    var isActive: Bool
    var snoozeIntervalMinutes: Int
    var maxSnoozeCount: Int
    var createdAt: Date
    var updatedAt: Date

    var scheduleType: ScheduleType {
        get { ScheduleType(rawValue: scheduleTypeRaw) ?? .daily }
        set { scheduleTypeRaw = newValue.rawValue }
    }

    init(
        id: UUID = UUID(),
        name: String,
        dosageText: String? = nil,
        scheduleType: ScheduleType = .daily,
        weekdays: [Int] = [],
        timesPerDay: Int = 1,
        reminderTimes: [Date] = [],
        mealNote: String? = nil,
        note: String? = nil,
        isActive: Bool = true,
        snoozeIntervalMinutes: Int = 10,
        maxSnoozeCount: Int = 1,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.name = name
        self.dosageText = dosageText
        self.scheduleTypeRaw = scheduleType.rawValue
        self.weekdays = weekdays
        self.timesPerDay = timesPerDay
        self.reminderTimes = reminderTimes
        self.mealNote = mealNote
        self.note = note
        self.isActive = isActive
        self.snoozeIntervalMinutes = snoozeIntervalMinutes
        self.maxSnoozeCount = maxSnoozeCount
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

enum ScheduleType: String, Codable, CaseIterable {
    case daily
    case weekly
}

enum MealNoteType: String, Codable, CaseIterable {
    case none
    case beforeMeal
    case afterMeal

    var displayName: String {
        switch self {
        case .none: return "无"
        case .beforeMeal: return "饭前"
        case .afterMeal: return "饭后"
        }
    }
}
