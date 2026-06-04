import SwiftUI

enum AppColors {
    static let accent = Color("AccentColor", bundle: .main)

    static let background = Color(uiColor: .systemBackground)
    static let secondaryBackground = Color(uiColor: .secondarySystemBackground)
    static let tertiaryBackground = Color(uiColor: .tertiarySystemBackground)

    static let textPrimary = Color(uiColor: .label)
    static let textSecondary = Color(uiColor: .secondaryLabel)
    static let textTertiary = Color(uiColor: .tertiaryLabel)

    static let success = Color.green
    static let warning = Color.orange
    static let error = Color.red

    static let medication = Color.blue
    static let sleep = Color.indigo
    static let meal = Color.orange
    static let nightSnack = Color.purple
}