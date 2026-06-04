import SwiftUI
import SwiftData

struct NightSnackSettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var mealRules: [MealRule]

    private var nightSnackRule: MealRule? {
        mealRules.first { $0.mealType == .nightSnack }
    }

    @State private var isActive: Bool = true
    @State private var reminderTime: Date = Calendar.current.date(bySettingHour: 21, minute: 0, second: 0, of: .now) ?? .now
    @State private var showingSaved = false

    var body: some View {
        Form {
            Section {
                Toggle("启用夜宵提醒", isOn: $isActive)
            }

            Section {
                DatePicker("提醒时间", selection: $reminderTime, displayedComponents: .hourAndMinute)
            }

            Section {
                Text("每天固定时间提醒，帮助控制夜宵。\n记录是否吃夜宵用于历史统计。")
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
        .navigationTitle("夜宵提醒")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("保存") {
                    saveNightSnackRule()
                    showingSaved = true
                }
            }
        }
        .alert("已保存", isPresented: $showingSaved) {
            Button("好", role: .cancel) {}
        }
        .onAppear { loadNightSnackRule() }
    }

    private func loadNightSnackRule() {
        guard let rule = nightSnackRule else { return }
        isActive = rule.isActive
        reminderTime = rule.reminderTime
    }

    private func saveNightSnackRule() {
        if let existing = nightSnackRule {
            existing.isActive = isActive
            existing.reminderTime = reminderTime
            existing.updatedAt = .now
        } else {
            let rule = MealRule(
                mealType: .nightSnack,
                reminderTime: reminderTime,
                isActive: isActive
            )
            modelContext.insert(rule)
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
        NightSnackSettingsView()
    }
    .modelContainer(for: [MealRule.self], inMemory: true)
}
