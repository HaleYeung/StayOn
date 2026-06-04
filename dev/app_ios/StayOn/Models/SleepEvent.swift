import Foundation
import SwiftData

@Model
final class SleepEvent {
    @Attribute(.unique) var id: UUID
    var date: Date
    var targetBedtime: Date
    var preReminderAt: Date
    var finalReminderAt: Date
    var statusRaw: String
    var confirmedAt: Date?
    var snoozeCount: Int
    var maxSnoozeCount: Int
    var lastNotificationAt: Date?
    var createdAt: Date

    var status: SleepEventStatus {
        get { SleepEventStatus(rawValue: statusRaw) ?? .pending }
        set { statusRaw = newValue.rawValue }
    }

    init(
        id: UUID = UUID(),
        date: Date,
        targetBedtime: Date,
        preReminderAt: Date,
        finalReminderAt: Date,
        status: SleepEventStatus = .pending,
        confirmedAt: Date? = nil,
        snoozeCount: Int = 0,
        maxSnoozeCount: Int = 1,
        lastNotificationAt: Date? = nil,
        createdAt: Date = .now
    ) {
        self.id = id
        self.date = date
        self.targetBedtime = targetBedtime
        self.preReminderAt = preReminderAt
        self.finalReminderAt = finalReminderAt
        self.statusRaw = status.rawValue
        self.confirmedAt = confirmedAt
        self.snoozeCount = snoozeCount
        self.maxSnoozeCount = maxSnoozeCount
        self.lastNotificationAt = lastNotificationAt
        self.createdAt = createdAt
    }
}

enum SleepEventStatus: String, Codable, CaseIterable {
    case pending
    case confirmed
    case unconfirmed

    var displayName: String {
        switch self {
        case .pending: return "待确认"
        case .confirmed: return "晚安"
        case .unconfirmed: return "未确认"
        }
    }

    var iconName: String {
        switch self {
        case .pending: return "moon"
        case .confirmed: return "checkmark.circle.fill"
        case .unconfirmed: return "exclamationmark.circle"
        }
    }
}
