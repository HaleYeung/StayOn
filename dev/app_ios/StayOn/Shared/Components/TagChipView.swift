import SwiftUI

struct TagChipView: View {
    let text: String
    var color: Color = .accentColor

    var body: some View {
        Text(text)
            .font(AppTypography.caption)
            .padding(.horizontal, AppSpacing.small)
            .padding(.vertical, AppSpacing.xxSmall)
            .background(color.opacity(0.15))
            .foregroundStyle(color)
            .clipShape(Capsule())
    }
}

#Preview {
    HStack {
        TagChipView(text: "控碳水", color: .orange)
        TagChipView(text: "少油", color: .red)
        TagChipView(text: "不喝含糖饮料", color: .purple)
    }
    .padding()
}
