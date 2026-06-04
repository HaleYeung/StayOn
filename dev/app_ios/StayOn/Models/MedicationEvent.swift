import Foundation
import SwiftData

@Model
final class MedicationEvent {
    @Attribute(.unique) var id: UUID
    var medicationId: UUID
    var medicationName: String
    var dosageText: String?
    var scheduledAt: Date
    var statusRaw: String
    var confirmedAt: Date?
    var skippedAt: Date?
    var snoozeCount: Int
    var maxSnoozeCount: Int
    var lastNotificationAt: Date?
    var createdAt: Date

    var status: MedicationEventStatus {
        get { MedicationEventStatus(rawValue: statusRaw) ?? .pending }
        set { statusRaw = newValue.rawValue }
    }

    init(
        id: UUID = UUID(),
        medicationId: UUID,
        medicationName: String = "",
        dosageText: String? = nil,
        scheduledAt: Date,
        status: MedicationEventStatus = .pending,
        confirmedAt: Date? = nil,
        skippedAt: Date? = nil,
        snoozeCount: Int = 0,
        maxSnoozeCount: Int = 1,
        lastNotificationAt: Date? = nil,
        createdAt: Date = .now
    ) {
        self.id = id
        self.medicationId = medicationId
        self.medicationName = medicationName
        self.dosageText = dosageText
        self.scheduledAt = scheduledAt
        self.statusRaw = status.rawValue
        self.confirmedAt = confirmedAt
        self.skippedAt = skippedAt
        self.snoozeCount = snoozeCount
        self.maxSnoozeCount = maxSnoozeCount
        self.lastNotificationAt = lastNotificationAt
        self.createdAt = createdAt
    }
}

enum MedicationEventStatus: String, Codable, CaseIterable {
    case pending
    case done
    case skipped
    case unconfirmed

    var displayName: String {
        switch self {
        case .pending: return "待确认"
        case .done: return "已吃"
        case .skipped: return "跳过"
        case .unconfirmed: return "未确认"
        }
    }

    var iconName: String {
        switch self {
        case .pending: return "clock"
        case .done: return "checkmark.circle.fill"
        case .skipped: return "forward.fill"
        case .unconfirmed: return "exclamationmark.circle"
        }
    }
}
