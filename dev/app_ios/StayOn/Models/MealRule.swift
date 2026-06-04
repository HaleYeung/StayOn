import Foundation
import SwiftData

@Model
final class MealRule {
    @Attribute(.unique) var id: UUID
    var mealTypeRaw: String
    var reminderTime: Date
    var templateTags: [String]
    var customNote: String?
    var isActive: Bool
    var updatedAt: Date

    var mealType: MealType {
        get { MealType(rawValue: mealTypeRaw) ?? .breakfast }
        set { mealTypeRaw = newValue.rawValue }
    }

    init(
        id: UUID = UUID(),
        mealType: MealType,
        reminderTime: Date,
        templateTags: [String] = [],
        customNote: String? = nil,
        isActive: Bool = true,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.mealTypeRaw = mealType.rawValue
        self.reminderTime = reminderTime
        self.templateTags = templateTags
        self.customNote = customNote
        self.isActive = isActive
        self.updatedAt = updatedAt
    }
}

enum MealType: String, Codable, CaseIterable {
    case breakfast
    case lunch
    case dinner
    case nightSnack

    var displayName: String {
        switch self {
        case .breakfast: return "早餐"
        case .lunch: return "午餐"
        case .dinner: return "晚餐"
        case .nightSnack: return "夜宵"
        }
    }
}

enum MealEventStatus: String, Codable, CaseIterable {
    case pending
    case acknowledged
    case unconfirmed

    var displayName: String {
        switch self {
        case .pending: return "待确认"
        case .acknowledged: return "已确认"
        case .unconfirmed: return "未确认"
        }
    }
}
