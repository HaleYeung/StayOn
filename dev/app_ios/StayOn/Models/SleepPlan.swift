import Foundation
import SwiftData

@Model
final class SleepPlan {
    @Attribute(.unique) var id: UUID
    var bedtime: Date
    var preReminderMinutes: Int
    var snoozeIntervalMinutes: Int
    var maxSnoozeCount: Int
    var isActive: Bool
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        bedtime: Date,
        preReminderMinutes: Int = 30,
        snoozeIntervalMinutes: Int = 10,
        maxSnoozeCount: Int = 1,
        isActive: Bool = true,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.bedtime = bedtime
        self.preReminderMinutes = preReminderMinutes
        self.snoozeIntervalMinutes = snoozeIntervalMinutes
        self.maxSnoozeCount = maxSnoozeCount
        self.isActive = isActive
        self.updatedAt = updatedAt
    }
}
