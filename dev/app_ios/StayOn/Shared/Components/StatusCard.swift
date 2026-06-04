import SwiftUI

struct StatusCard<Content: View>: View {
    let title: String
    let icon: String
    let iconColor: Color
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(iconColor)
                Text(title)
                    .font(AppTypography.headline)
                Spacer()
            }

            content()
        }
        .padding(AppSpacing.medium)
        .background(AppColors.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    StatusCard(title: "今日状态", icon: "sun.max.fill", iconColor: .orange) {
        Text("今天还稳")
            .font(AppTypography.body)
    }
    .padding()
}
