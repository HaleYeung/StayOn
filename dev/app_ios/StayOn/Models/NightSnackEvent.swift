import Foundation
import SwiftData

@Model
final class NightSnackEvent {
    @Attribute(.unique) var id: UUID
    var date: Date
    var reminderAt: Date
    var statusRaw: String
    var recordedAt: Date?

    var status: NightSnackStatus {
        get { NightSnackStatus(rawValue: statusRaw) ?? .unset }
        set { statusRaw = newValue.rawValue }
    }

    init(
        id: UUID = UUID(),
        date: Date,
        reminderAt: Date,
        status: NightSnackStatus = .unset,
        recordedAt: Date? = nil
    ) {
        self.id = id
        self.date = date
        self.reminderAt = reminderAt
        self.statusRaw = status.rawValue
        self.recordedAt = recordedAt
    }
}

enum NightSnackStatus: String, Codable, CaseIterable {
    case unset
    case noSnack
    case ateSnack

    var displayName: String {
        switch self {
        case .unset: return "未记录"
        case .noSnack: return "没吃"
        case .ateSnack: return "吃了"
        }
    }

    var iconName: String {
        switch self {
        case .unset: return "questionmark.circle"
        case .noSnack: return "checkmark.circle.fill"
        case .ateSnack: return "xmark.circle.fill"
        }
    }
}
