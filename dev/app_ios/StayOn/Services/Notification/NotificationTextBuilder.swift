import Foundation

enum NotificationTextBuilder {
    /// Current tone style, set from settings when user changes it.
    static var currentStyle: ToneStyle = .lightSupervision
    static func medicationTitle(style: ToneStyle = .lightSupervision) -> String {
        switch style {
        case .lightSupervision: return "该吃药了，别拖。"
        case .gentle: return "该吃药了，记得按时。"
        case .serious: return "请立即服药！"
        }
    }

    static func medicationBody(medicationName: String, dosage: String?) -> String {
        if let dosage, !dosage.isEmpty {
            return "\(medicationName) \(dosage)"
        }
        return medicationName
    }

    static func sleepPreReminderTitle(style: ToneStyle = .lightSupervision) -> String {
        switch style {
        case .lightSupervision: return "差不多该收了。"
        case .gentle: return "准备睡觉了。"
        case .serious: return "请注意休息时间。"
        }
    }

    static func sleepPreReminderBody(minutes: Int, style: ToneStyle = .lightSupervision) -> String {
        switch style {
        case .lightSupervision: return "\(minutes)分钟后准备睡觉，别又拖到太晚。"
        case .gentle: return "\(minutes)分钟后该休息了，早点睡。"
        case .serious: return "您将在\(minutes)分钟后到达目标就寝时间。"
        }
    }

    static func sleepReminderTitle(style: ToneStyle = .lightSupervision) -> String {
        switch style {
        case .lightSupervision: return "到点了，该睡了。"
        case .gentle: return "到睡觉时间了。"
        case .serious: return "就寝时间已到。"
        }
    }

    static func sleepReminderBody(style: ToneStyle = .lightSupervision) -> String {
        switch style {
        case .lightSupervision: return "今晚别乱来，按时收工。"
        case .gentle: return "好好休息，明天会更好。"
        case .serious: return "睡眠不足影响健康，请立即休息。"
        }
    }

    static func mealReminderTitle(style: ToneStyle = .lightSupervision) -> String {
        switch style {
        case .lightSupervision: return "吃之前先看一眼。"
        case .gentle: return "吃饭前注意一下。"
        case .serious: return "饮食提醒。"
        }
    }

    static func mealReminderBody(tags: [String], customNote: String?) -> String {
        var parts: [String] = tags
        if let note = customNote, !note.isEmpty {
            parts.append(note)
        }
        return parts.joined(separator: "，")
    }

    static func nightSnackTitle(style: ToneStyle = .lightSupervision) -> String {
        switch style {
        case .lightSupervision: return "今晚夜宵就算了。"
        case .gentle: return "晚上少吃点。"
        case .serious: return "请控制夜宵摄入。"
        }
    }

    static func nightSnackBody(style: ToneStyle = .lightSupervision) -> String {
        switch style {
        case .lightSupervision: return "现在忍住，明天会感谢你。"
        case .gentle: return "早点休息，对胃好。"
        case .serious: return "夜宵会增加身体负担。"
        }
    }
}
