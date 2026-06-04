import SwiftUI
import SwiftData
import UserNotifications

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var settings: [AppSettings]
    @Query(sort: \MedicationEvent.scheduledAt) private var allMedicationEvents: [MedicationEvent]
    @Query private var sleepEvents: [SleepEvent]
    @Query private var mealEvents: [MealEvent]
    @Query private var mealRules: [MealRule]

    private var todayMedicationEvents: [MedicationEvent] {
        filterToday(allMedicationEvents, keyPath: \.scheduledAt)
    }

    private var todaySleepEvents: [SleepEvent] {
        filterToday(sleepEvents, keyPath: \.date)
    }

    private var todayMealEvents: [MealEvent] {
        filterToday(mealEvents, keyPath: \.scheduledAt)
    }

    @State private var notificationStatus: UNAuthorizationStatus = .notDetermined

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppSpacing.medium) {
                    PermissionBanner(isVisible: notificationStatus == .denied) {
                        openSystemSettings()
                    }

                    if let nextEvent = todayMedicationEvents.first(where: { $0.status == .pending }) {
                        NextMedicationCard(event: nextEvent)
                    }

                    TodayStatusCard(
                        medicationEvents: todayMedicationEvents,
                        sleepEvents: todaySleepEvents,
                        mealEvents: todayMealEvents,
                        mealRules: mealRules
                    )

                    MealReminderCard()

                    MedicationSummaryCard(events: todayMedicationEvents)

                    SleepSummaryCard()

                    NightSnackCard()
                }
                .padding(.vertical)
            }
            .navigationTitle("今天")
            .task {
                notificationStatus = await NotificationManager.shared.getAuthorizationStatus()
            }
        }
    }

    private func filterToday<T>(_ items: [T], keyPath: KeyPath<T, Date>) -> [T] {
        let today = Calendar.current.startOfDay(for: .now)
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        return items.filter { $0[keyPath: keyPath] >= today && $0[keyPath: keyPath] < tomorrow }
    }

    private func openSystemSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Today Status Card

struct TodayStatusCard: View {
    let medicationEvents: [MedicationEvent]
    let sleepEvents: [SleepEvent]
    let mealEvents: [MealEvent]
    let mealRules: [MealRule]

    private var pendingMedicationCount: Int { medicationEvents.filter { $0.status == .pending }.count }
    private var doneMedicationCount: Int { medicationEvents.filter { $0.status == .done }.count }
    private var sleepConfirmed: Bool { sleepEvents.contains { $0.status == .confirmed } }
    private var mealAcknowledgedCount: Int { mealEvents.filter { $0.status == .acknowledged }.count }

    private var summaryText: String {
        if pendingMedicationCount > 0 {
            return "药还差 \(pendingMedicationCount) 次，别拖。"
        }
        if !sleepConfirmed {
            return "今晚早点收，别又熬。"
        }
        if medicationEvents.isEmpty && mealRules.isEmpty {
            return "今天没有计划，记得去设置。"
        }
        return "今天还稳，继续保持。"
    }

    var body: some View {
        StatusCard(title: "今日概览", icon: "sun.max.fill", iconColor: .orange) {
            VStack(alignment: .leading, spacing: AppSpacing.small) {
                Text(summaryText)
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.textSecondary)

                if !medicationEvents.isEmpty || !sleepEvents.isEmpty || !mealEvents.isEmpty {
                    Divider()
                    HStack(spacing: AppSpacing.xLarge) {
                        VStack(spacing: 2) {
                            Text("\(doneMedicationCount)/\(medicationEvents.count)")
                                .font(AppTypography.title3.weight(.semibold))
                                .foregroundStyle(AppColors.medication)
                            Text("药物")
                                .font(AppTypography.caption2)
                                .foregroundStyle(AppColors.textTertiary)
                        }
                        VStack(spacing: 2) {
                            Image(systemName: sleepConfirmed ? "checkmark.circle.fill" : "circle")
                                .font(AppTypography.title3)
                                .foregroundStyle(sleepConfirmed ? .green : AppColors.textTertiary)
                            Text("晚安")
                                .font(AppTypography.caption2)
                                .foregroundStyle(AppColors.textTertiary)
                        }
                        VStack(spacing: 2) {
                            Text("\(mealAcknowledgedCount)/\(mealRules.filter(\.isActive).count)")
                                .font(AppTypography.title3.weight(.semibold))
                                .foregroundStyle(AppColors.meal)
                            Text("饮食")
                                .font(AppTypography.caption2)
                                .foregroundStyle(AppColors.textTertiary)
                        }
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - Next Medication Card

struct NextMedicationCard: View {
    let event: MedicationEvent

    private var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: event.scheduledAt)
    }

    var body: some View {
        StatusCard(title: "下一条提醒", icon: "clock.fill", iconColor: .blue) {
            VStack(alignment: .leading, spacing: AppSpacing.xSmall) {
                HStack {
                    Text(timeString)
                        .font(AppTypography.title3)
                    Text(event.medicationName)
                        .font(AppTypography.headline)
                }

                if let dosage = event.dosageText, !dosage.isEmpty {
                    Text(dosage)
                        .font(AppTypography.subheadline)
                        .foregroundStyle(AppColors.textSecondary)
                }

                NavigationLink {
                    MedicationEventDetailView(event: event)
                } label: {
                    Text("查看详情")
                        .font(AppTypography.caption)
                }
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - Medication Summary Card

struct MedicationSummaryCard: View {
    let events: [MedicationEvent]

    private var doneCount: Int { events.filter { $0.status == .done }.count }
    private var pendingCount: Int { events.filter { $0.status == .pending }.count }
    private var skippedCount: Int { events.filter { $0.status == .skipped }.count }

    var body: some View {
        StatusCard(title: "今日药物", icon: "pills.fill", iconColor: .blue) {
            if events.isEmpty {
                Text("暂无记录")
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.textSecondary)
            } else {
                HStack(spacing: AppSpacing.large) {
                    SummaryItem(label: "已吃", value: "\(doneCount)", color: .green)
                    SummaryItem(label: "待确认", value: "\(pendingCount)", color: .orange)
                    SummaryItem(label: "跳过", value: "\(skippedCount)", color: .gray)
                }

                Divider()

                ForEach(events.prefix(4)) { event in
                    NavigationLink {
                        MedicationEventDetailView(event: event)
                    } label: {
                        HStack {
                            Text(event.scheduledAt, style: .time)
                                .font(AppTypography.caption)
                                .frame(width: 50, alignment: .leading)
                            Text(event.medicationName)
                                .font(AppTypography.subheadline)
                                .lineLimit(1)
                            Spacer()
                            StatusBadge(status: event.status)
                        }
                    }
                    .buttonStyle(.plain)
                }

                if events.count > 4 {
                    NavigationLink {
                        MedicationListView()
                    } label: {
                        Text("查看全部 (\(events.count) 条)")
                            .font(AppTypography.caption)
                            .foregroundStyle(AppColors.textSecondary)
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}

struct SummaryItem: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(AppTypography.title2)
                .foregroundStyle(color)
            Text(label)
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textSecondary)
        }
    }
}

#Preview {
    TodayView()
        .modelContainer(for: [
            Medication.self,
            MedicationEvent.self,
            SleepPlan.self,
            SleepEvent.self,
            MealRule.self,
            MealEvent.self,
            AppSettings.self
        ], inMemory: true)
}
