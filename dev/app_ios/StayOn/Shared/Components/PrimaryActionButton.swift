import SwiftUI

struct PrimaryActionButton: View {
    let title: String
    var style: ActionButtonStyle = .primary
    let action: () -> Void

    enum ActionButtonStyle {
        case primary
        case secondary
        case destructive
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppTypography.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppSpacing.medium)
                .background(backgroundColor)
                .foregroundStyle(foregroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }

    private var backgroundColor: Color {
        switch style {
        case .primary: return .accentColor
        case .secondary: return .gray.opacity(0.15)
        case .destructive: return .red.opacity(0.15)
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .primary: return .white
        case .secondary: return .primary
        case .destructive: return .red
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        PrimaryActionButton(title: "已吃", style: .primary) {
            print("Primary action")
        }

        PrimaryActionButton(title: "稍后提醒", style: .secondary) {
            print("Secondary action")
        }

        PrimaryActionButton(title: "跳过", style: .destructive) {
            print("Destructive action")
        }
    }
    .padding()
}
