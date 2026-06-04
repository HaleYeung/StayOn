import Foundation
import SwiftData

@Model
final class AppSettings {
    @Attribute(.unique) var id: UUID
    var defaultSnoozeMinutes: Int
    var defaultMaxSnoozeCount: Int
    var toneStyle: String
    var hasSeenNotificationPrompt: Bool
    var mealTemplateTags: [String]

    init(
        id: UUID = UUID(),
        defaultSnoozeMinutes: Int = 10,
        defaultMaxSnoozeCount: Int = 1,
        toneStyle: String = ToneStyle.lightSupervision.rawValue,
        hasSeenNotificationPrompt: Bool = false,
        mealTemplateTags: [String] = ToneStyle.defaultTags
    ) {
        self.id = id
        self.defaultSnoozeMinutes = defaultSnoozeMinutes
        self.defaultMaxSnoozeCount = defaultMaxSnoozeCount
        self.toneStyle = toneStyle
        self.hasSeenNotificationPrompt = hasSeenNotificationPrompt
        self.mealTemplateTags = mealTemplateTags
    }
}

enum ToneStyle: String, CaseIterable, Codable {
    case lightSupervision = "light_supervision"
    case gentle = "gentle"
    case serious = "serious"

    var displayName: String {
        switch self {
        case .lightSupervision: return "轻监督"
        case .gentle: return "温和提醒"
        case .serious: return "严肃提醒"
        }
    }

    var description: String {
        switch self {
        case .lightSupervision: return "轻微吐槽风格，带点调侃"
        case .gentle: return "温和鼓励，不施加压力"
        case .serious: return "直接严肃，不容忽视"
        }
    }

    static let defaultTags: [String] = [
        "少糖", "少盐", "少油", "控碳水",
        "控主食", "不喝含糖饮料", "少吃加工食品", "不吃夜宵"
    ]
}
