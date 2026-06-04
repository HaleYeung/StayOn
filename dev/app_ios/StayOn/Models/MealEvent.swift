import Foundation
import SwiftData

@Model
final class MealEvent {
    @Attribute(.unique) var id: UUID
    var mealTypeRaw: String
    var scheduledAt: Date
    var statusRaw: String
    var acknowledgedAt: Date?
    var noteSnapshot: String?
    var tagsSnapshot: [String]
    var createdAt: Date

    var mealType: MealType {
        get { MealType(rawValue: mealTypeRaw) ?? .lunch }
        set { mealTypeRaw = newValue.rawValue }
    }

    var status: MealEventStatus {
        get { MealEventStatus(rawValue: statusRaw) ?? .pending }
        set { statusRaw = newValue.rawValue }
    }

    init(
        id: UUID = UUID(),
        mealType: MealType,
        scheduledAt: Date,
        status: MealEventStatus = .pending,
        acknowledgedAt: Date? = nil,
        noteSnapshot: String? = nil,
        tagsSnapshot: [String] = [],
        createdAt: Date = .now
    ) {
        self.id = id
        self.mealTypeRaw = mealType.rawValue
        self.scheduledAt = scheduledAt
        self.statusRaw = status.rawValue
        self.acknowledgedAt = acknowledgedAt
        self.noteSnapshot = noteSnapshot
        self.tagsSnapshot = tagsSnapshot
        self.createdAt = createdAt
    }
}
