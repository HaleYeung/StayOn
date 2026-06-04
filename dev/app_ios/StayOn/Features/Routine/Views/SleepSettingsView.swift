import SwiftUI
import SwiftData

struct SleepSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var sleepPlans: [SleepPlan]

    private var sleepPlan: SleepPlan? {
        sleepPlans.first
    }

    @State private var isActive: Bool = true
    @State private var bedtime: Date = Calendar.current.date(bySettingHour: 23, minute: 30, second: 0, of: .now) ?? .now
    @State private var preReminderMinutes: Int = 30
    @State private var snoozeIntervalMinutes: Int = 10
    @State private var maxSnoozeCount: Int = 1
    @State private var saveState: SaveState = .idle

    var body: some View {
        Form {
            Section {
                Toggle("启用睡觉提醒", isOn: $isActive)
            } header: {
                Text("开关")
            }

            Section {
                DatePicker("目标睡觉时间", selection: $bedtime, displayedComponents: .hourAndMinute)

                Stepper("提前 \(preReminderMinutes) 分钟预提醒", value: $preReminderMinutes, in: 10...60, step: 5)

                Text("预提醒时间: \(preReminderTimeString)")
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textSecondary)
            } header: {
                Text("提醒时间")
            }

            Section {
                Stepper("稍后提醒间隔: \(snoozeIntervalMinutes) 分钟", value: $snoozeIntervalMinutes, in: 5...30, step: 5)

                Stepper("最大追提醒次数: \(maxSnoozeCount) 次", value: $maxSnoozeCount, in: 1...5)
            } header: {
                Text("追提醒设置")
            }

            Section {
                Text("到点后你可以点「晚安」确认入睡。\n若未确认，会按设置进行轻提醒。\n第一版不记录睡眠时长。")
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textSecondary)
            } header: {
                Text("说明")
            }
        }
        .navigationTitle("睡觉提醒")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                saveButton
            }
        }
        .disabled(saveState == .saving)
        .onAppear {
            loadSleepPlan()
        }
    }

    private var preReminderTimeString: String {
        let preTime = Calendar.current.date(byAdding: .minute, value: -preReminderMinutes, to: bedtime) ?? bedtime
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: preTime)
    }

    private func loadSleepPlan() {
        guard let plan = sleepPlan else { return }
        isActive = plan.isActive
        bedtime = plan.bedtime
        preReminderMinutes = plan.preReminderMinutes
        snoozeIntervalMinutes = plan.snoozeIntervalMinutes
        maxSnoozeCount = plan.maxSnoozeCount
    }

    @ViewBuilder
    private var saveButton: some View {
        switch saveState {
        case .idle:
            Button("保存") { performSave() }
        case .saving:
            ProgressView()
                .scaleEffect(0.8)
        case .saved:
            Image(systemName: "checkmark")
                .foregroundStyle(.green)
                .transition(.scale.combined(with: .opacity))
        }
    }

    private func performSave() {
        saveState = .saving
        saveSleepPlan()
        DailyEventGenerator.generateIfNeeded(modelContext: modelContext)

        Task {
            await NotificationManager.shared.requestIfFirstPlan(modelContext: modelContext)
            await NotificationScheduler.scheduleTodayNotifications(modelContext: modelContext)

            withAnimation {
                saveState = .saved
            }
            try? await Task.sleep(nanoseconds: 800_000_000)
            dismiss()
        }
    }

    private func saveSleepPlan() {
        if let existing = sleepPlan {
            existing.isActive = isActive
            existing.bedtime = bedtime
            existing.preReminderMinutes = preReminderMinutes
            existing.snoozeIntervalMinutes = snoozeIntervalMinutes
            existing.maxSnoozeCount = maxSnoozeCount
            existing.updatedAt = .now
        } else {
            let newPlan = SleepPlan(
                bedtime: bedtime,
                preReminderMinutes: preReminderMinutes,
                snoozeIntervalMinutes: snoozeIntervalMinutes,
                maxSnoozeCount: maxSnoozeCount,
                isActive: isActive
            )
            modelContext.insert(newPlan)
        }
        try? modelContext.save()

        DailyEventGenerator.generateIfNeeded(modelContext: modelContext)

        Task {
            await NotificationManager.shared.requestIfFirstPlan(modelContext: modelContext)
            await NotificationScheduler.scheduleTodayNotifications(modelContext: modelContext)
        }
    }
}

#Preview {
    NavigationStack {
        SleepSettingsView()
    }
    .modelContainer(for: [SleepPlan.self], inMemory: true)
}
