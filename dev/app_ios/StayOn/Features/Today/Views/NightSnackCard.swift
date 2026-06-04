import SwiftUI
import SwiftData

struct NightSnackCard: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var nightSnackEvents: [NightSnackEvent]

    /// Always return the first today's event, or nil.
    private var todayEvent: NightSnackEvent? {
        let today = Calendar.current.startOfDay(for: .now)
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        return nightSnackEvents.first { $0.date >= today && $0.date < tomorrow }
    }

    /// True if the user hasn't recorded anything yet for today.
    private var needsRecording: Bool {
        todayEvent == nil || todayEvent?.status == .unset
    }

    var body: some View {
        StatusCard(title: "夜宵", icon: "moon.fill", iconColor: .purple) {
            VStack(alignment: .leading, spacing: AppSpacing.xSmall) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("今晚")
                            .font(AppTypography.subheadline)
                        Text(needsRecording ? "还没记录" : "已记录")
                            .font(AppTypography.caption)
                            .foregroundStyle(AppColors.textSecondary)
                    }
                    Spacer()
                    if let event = todayEvent {
                        NightSnackStatusBadge(status: event.status)
                    } else {
                        NightSnackStatusBadge(status: .unset)
                    }
                }

                if needsRecording {
                    HStack(spacing: AppSpacing.small) {
                        Button {
                            record(.noSnack)
                        } label: {
                            Text("没吃")
                                .font(AppTypography.subheadline.weight(.medium))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, AppSpacing.xSmall)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.green)

                        Button {
                            record(.ateSnack)
                        } label: {
                            Text("吃了")
                                .font(AppTypography.subheadline.weight(.medium))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, AppSpacing.xSmall)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.red)
                    }
                }
            }
        }
        .padding(.horizontal)
    }

    private func record(_ status: NightSnackStatus) {
        let today = Calendar.current.startOfDay(for: .now)
        if let existing = todayEvent {
            existing.status = status
            existing.recordedAt = .now
        } else {
            let event = NightSnackEvent(
                date: today,
                reminderAt: Date(),
                status: status,
                recordedAt: .now
            )
            modelContext.insert(event)
        }
        try? modelContext.save()
    }
}

struct NightSnackStatusBadge: View {
    let status: NightSnackStatus

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: status.iconName)
            Text(status.displayName)
        }
        .font(AppTypography.caption)
        .foregroundStyle(statusColor)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(statusColor.opacity(0.15))
        .clipShape(Capsule())
    }

    private var statusColor: Color {
        switch status {
        case .unset: return .gray
        case .noSnack: return .green
        case .ateSnack: return .red
        }
    }
}

#Preview {
    NightSnackCard()
        .modelContainer(for: [NightSnackEvent.self], inMemory: true)
}
