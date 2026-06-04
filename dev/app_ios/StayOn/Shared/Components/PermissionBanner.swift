import SwiftUI
import UserNotifications

struct PermissionBanner: View {
    let isVisible: Bool
    let onRequestPermission: () -> Void

    var body: some View {
        if isVisible {
            HStack {
                Image(systemName: "bell.slash.fill")
                    .foregroundStyle(.orange)

                VStack(alignment: .leading, spacing: 2) {
                    Text("通知权限未开启")
                        .font(AppTypography.subheadline.weight(.medium))
                    Text("你让谁提醒你？")
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.textSecondary)
                }

                Spacer()

                Button("去设置") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                .font(AppTypography.subheadline)
            }
            .padding(AppSpacing.medium)
            .background(Color.orange.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal)
        }
    }
}

#Preview {
    VStack {
        PermissionBanner(isVisible: true) {
            print("Request permission")
        }
    }
}
