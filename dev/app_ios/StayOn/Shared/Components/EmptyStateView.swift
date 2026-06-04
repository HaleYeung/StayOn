import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        VStack(spacing: AppSpacing.medium) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundStyle(AppColors.textTertiary)

            Text(title)
                .font(AppTypography.title2)
                .foregroundStyle(AppColors.textPrimary)

            Text(message)
                .font(AppTypography.body)
                .foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.center)

            if let actionTitle, let action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(AppTypography.headline)
                }
                .buttonStyle(.borderedProminent)
                .padding(.top, AppSpacing.small)
            }
        }
        .padding(AppSpacing.xxLarge)
    }
}

#Preview {
    EmptyStateView(
        icon: "pills",
        title: "还没有药物",
        message: "添加第一种药物，开始管理你的服药计划",
        actionTitle: "添加药物"
    ) {
        print("Action tapped")
    }
}
