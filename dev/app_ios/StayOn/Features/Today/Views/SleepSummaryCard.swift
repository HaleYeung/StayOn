import SwiftUI
import SwiftData

struct SleepSummaryCard: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var sleepPlans: [SleepPlan]
    @Query private var sleepEvents: [SleepEvent]

    private var sleepPlan: SleepPlan? { sleepPlans.first }

    private var todayEvent: SleepEvent? {
        let today = Calendar.current.startOfDay(for: .now)
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        return sleepEvents.first { $0.date >= today && $0.date < tomorrow }
    }

    private var shouldShowCard: Bool {
        guard let plan = sleepPlan, plan.isActive else { return false }
        return true
    }

    /// "晚安" button is available whenever a sleep plan exists.
    private var canSayGoodnight: Bool {
        sleepPlan != nil && sleepPlan!.isActive
    }

    var body: some View {
        if shouldShowCard, let plan = sleepPlan {
            StatusCard(title: "今晚睡觉", icon: "moon.stars.fill", iconColor: .indigo) {
                VStack(alignment: .leading, spacing: AppSpacing.xSmall) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("目标: \(bedtimeString)")
                                .font(AppTypography.subheadline)
                            Text("预提醒: \(preReminderString)")
                                .font(AppTypography.caption)
                                .foregroundStyle(AppColors.textSecondary)
                        }

                        Spacer()

                        if let event = todayEvent {
                            SleepStatusBadge(status: event.status)
                        }
                    }

                    if canSayGoodnight, (todayEvent == nil || todayEvent?.status == .pending) {
                        HStack(spacing: AppSpacing.small) {
                            Button {
                                confirmGoodNight()
                            } label: {
                                Text("晚安")
                                    .font(AppTypography.subheadline.weight(.medium))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, AppSpacing.xSmall)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.indigo)

                            NavigationLink {
                                if let event = todayEvent {
                                    SleepEventDetailView(event: event)
                                }
                            } label: {
                                Text("详情")
                                    .font(AppTypography.subheadline)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, AppSpacing.xSmall)
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
    }

    private var bedtimeString: String {
        guard let plan = sleepPlan else { return "--:--" }
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: plan.bedtime)
    }

    private var preReminderString: String {
        guard let plan = sleepPlan else { return "--:--" }
        let preTime = Calendar.current.date(byAdding: .minute, value: -plan.preReminderMinutes, to: plan.bedtime) ?? plan.bedtime
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: preTime)
    }

    private func confirmGoodNight() {
        guard let plan = sleepPlan else { return }

        let today = Calendar.current.startOfDay(for: .now)
        guard let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today) else { return }

        var bedtime = combine(date: today, time: plan.bedtime)
        if bedtime < .now {
            bedtime = combine(date: tomorrow, time: plan.bedtime)
        }
        let preTime = Calendar.current.date(byAdding: .minute, value: -plan.preReminderMinutes, to: bedtime) ?? bedtime

        // Update existing event or create new one
        if let existingEvent = todayEvent {
            existingEvent.status = .confirmed
            existingEvent.confirmedAt = .now
        } else {
            let event = SleepEvent(
                date: today,
                targetBedtime: bedtime,
                preReminderAt: preTime,
                finalReminderAt: bedtime,
                status: .confirmed,
                confirmedAt: .now,
                snoozeCount: 0,
                maxSnoozeCount: plan.maxSnoozeCount
            )
            modelContext.insert(event)
        }
        try? modelContext.save()
    }

    private func combine(date: Date, time: Date) -> Date {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: time)
        var combined = DateComponents()
        combined.year = dateComponents.year
        combined.month = dateComponents.month
        combined.day = dateComponents.day
        combined.hour = timeComponents.hour
        combined.minute = timeComponents.minute
        combined.second = timeComponents.second
        return calendar.date(from: combined) ?? date
    }
}

struct SleepStatusBadge: View {
    let status: SleepEventStatus

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
        case .pending: return .orange
        case .confirmed: return .green
        case .unconfirmed: return .red
        }
    }
}

struct SleepEventDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var event: SleepEvent

    private var bedtimeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: event.targetBedtime)
    }

    private var preReminderString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: event.preReminderAt)
    }

    var body: some View {
        List {
            Section {
                LabeledContent("目标睡觉时间") {
                    Text(bedtimeString)
                }

                LabeledContent("预提醒时间") {
                    Text(preReminderString)
                }

                LabeledContent("状态") {
                    SleepStatusBadge(status: event.status)
                }

                if let confirmedAt = event.confirmedAt {
                    LabeledContent("确认时间") {
                        Text(confirmedAt, style: .time)
                    }
                }

                if event.snoozeCount > 0 {
                    LabeledContent("已稍后提醒") {
                        Text("\(event.snoozeCount) 次")
                    }
                }
            } header: {
                Text("今晚睡觉")
            }

            if event.status == .pending {
                Section {
                    Button {
                        confirmGoodNight()
                    } label: {
                        Label("晚安", systemImage: "checkmark.moon.fill")
                            .foregroundStyle(.green)
                    }

                    Button {
                        snooze()
                    } label: {
                        Label("稍后提醒", systemImage: "clock")
                            .foregroundStyle(.orange)
                    }
                    .disabled(event.snoozeCount >= event.maxSnoozeCount)
                } header: {
                    Text("操作")
                }
            }
        }
        .navigationTitle("今晚睡觉")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func confirmGoodNight() {
        event.status = .confirmed
        event.confirmedAt = .now
        try? modelContext.save()
    }

    private func snooze() {
        event.snoozeCount += 1
        event.lastNotificationAt = .now
        try? modelContext.save()

        Task {
            await NotificationScheduler.shared.scheduleSleepSnooze(
                for: event,
                minutes: 10
            )
        }
    }
}

#Preview {
    SleepSummaryCard()
        .modelContainer(for: [SleepPlan.self, SleepEvent.self], inMemory: true)
}
