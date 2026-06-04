import SwiftUI
import SwiftData

struct HistoryView: View {
    @Query(sort: \MedicationEvent.scheduledAt) private var medicationEvents: [MedicationEvent]
    @Query(sort: \SleepEvent.date) private var sleepEvents: [SleepEvent]
    @Query(sort: \MealEvent.scheduledAt) private var mealEvents: [MealEvent]
    @Query(sort: \NightSnackEvent.date) private var nightSnackEvents: [NightSnackEvent]
    @Query private var mealRules: [MealRule]

    var body: some View {
        NavigationStack {
            List {
                StreakSection(
                    medicationEvents: medicationEvents,
                    sleepEvents: sleepEvents,
                    mealEvents: mealEvents,
                    mealRules: mealRules
                )

                TodayOverviewSection(
                    medicationEvents: medicationEvents,
                    sleepEvents: sleepEvents,
                    mealEvents: mealEvents,
                    nightSnackEvents: nightSnackEvents
                )

                RecentWeekSection(
                    medicationEvents: medicationEvents,
                    sleepEvents: sleepEvents,
                    mealEvents: mealEvents,
                    nightSnackEvents: nightSnackEvents,
                    mealRules: mealRules
                )
            }
            .navigationTitle("历史")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    NavigationLink {
                        FullLogView()
                    } label: {
                        Image(systemName: "list.bullet.rectangle")
                    }
                }
            }
        }
    }
}

// MARK: - Streak Section

struct StreakSection: View {
    let medicationEvents: [MedicationEvent]
    let sleepEvents: [SleepEvent]
    let mealEvents: [MealEvent]
    let mealRules: [MealRule]

    private var current: Int {
        StreakCalculator.currentStreak(
            medicationEvents: medicationEvents,
            sleepEvents: sleepEvents,
            mealEvents: mealEvents,
            mealRules: mealRules
        )
    }

    private var longest: Int {
        StreakCalculator.longestStreak(
            medicationEvents: medicationEvents,
            sleepEvents: sleepEvents,
            mealEvents: mealEvents,
            mealRules: mealRules
        )
    }

    private var todayComplete: Bool {
        StreakCalculator.isTodayComplete(
            medicationEvents: medicationEvents,
            sleepEvents: sleepEvents,
            mealEvents: mealEvents,
            mealRules: mealRules
        )
    }

    var body: some View {
        Section {
            VStack(spacing: AppSpacing.medium) {
                HStack(spacing: AppSpacing.xxxLarge) {
                    VStack(spacing: 4) {
                        Text("\(current)")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundStyle(.green)
                        Text("当前连续")
                            .font(AppTypography.caption)
                            .foregroundStyle(AppColors.textSecondary)
                    }

                    VStack(spacing: 4) {
                        Text("\(longest)")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundStyle(AppColors.textPrimary)
                        Text("最长连续")
                            .font(AppTypography.caption)
                            .foregroundStyle(AppColors.textSecondary)
                    }
                }

                if !todayComplete && current > 0 {
                    Text("今天还差一些条件")
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.warning)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppSpacing.small)
        }
    }
}

// MARK: - Today Overview Section

struct TodayOverviewSection: View {
    let medicationEvents: [MedicationEvent]
    let sleepEvents: [SleepEvent]
    let mealEvents: [MealEvent]
    let nightSnackEvents: [NightSnackEvent]

    private var todayMedEvents: [MedicationEvent] {
        filterToday(medicationEvents, keyPath: \.scheduledAt)
    }
    private var todaySleepEvents: [SleepEvent] {
        filterToday(sleepEvents, keyPath: \.date)
    }
    private var todayMealEvents: [MealEvent] {
        filterToday(mealEvents, keyPath: \.scheduledAt)
    }
    private var todayNightSnack: NightSnackEvent? {
        let today = Calendar.current.startOfDay(for: .now)
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        return nightSnackEvents.first { $0.date >= today && $0.date < tomorrow }
    }

    private func filterToday<T>(_ items: [T], keyPath: KeyPath<T, Date>) -> [T] {
        let today = Calendar.current.startOfDay(for: .now)
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        return items.filter { $0[keyPath: keyPath] >= today && $0[keyPath: keyPath] < tomorrow }
    }

    var body: some View {
        Section {
            NavigationLink {
                HistoryDayDetailView(
                    date: .now,
                    medicationEvents: todayMedEvents,
                    sleepEvents: todaySleepEvents,
                    mealEvents: todayMealEvents,
                    nightSnackEvent: todayNightSnack
                )
            } label: {
                VStack(alignment: .leading, spacing: AppSpacing.xSmall) {
                    HStack {
                        Text("今天")
                            .font(AppTypography.headline)
                        Spacer()
                        Text(overallStatusText)
                            .font(AppTypography.caption)
                            .foregroundStyle(overallStatusColor)
                    }

                    HStack(spacing: AppSpacing.large) {
                        Label("药物 \(doneCount)/\(todayMedEvents.count)", systemImage: "pills")
                        Label("饮食 \(mealAckCount)/\(todayMealEvents.count)", systemImage: "fork.knife")
                    }
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textSecondary)

                    HStack(spacing: AppSpacing.large) {
                        Label(sleepConfirmed ? "已晚安" : "未晚安", systemImage: "moon")
                        if let ns = todayNightSnack {
                            Label(ns.status == .noSnack ? "没吃夜宵" : "吃了夜宵", systemImage: "moon.fill")
                        }
                    }
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textSecondary)
                }
            }
        } header: {
            Text("今天概览")
        }
    }

    private var doneCount: Int { todayMedEvents.filter { $0.status == .done }.count }
    private var mealAckCount: Int { todayMealEvents.filter { $0.status == .acknowledged }.count }
    private var sleepConfirmed: Bool { todaySleepEvents.contains { $0.status == .confirmed } }

    private var overallStatusText: String {
        todayMedEvents.allSatisfy { $0.status == .done } && sleepConfirmed ? "已完成" : "未完成"
    }

    private var overallStatusColor: Color {
        todayMedEvents.allSatisfy { $0.status == .done } && sleepConfirmed ? .green : .orange
    }
}

// MARK: - Recent 7 Days Section

struct RecentWeekSection: View {
    let medicationEvents: [MedicationEvent]
    let sleepEvents: [SleepEvent]
    let mealEvents: [MealEvent]
    let nightSnackEvents: [NightSnackEvent]
    let mealRules: [MealRule]

    private let dayLabels = ["一", "二", "三", "四", "五", "六", "日"]

    var body: some View {
        Section {
            ForEach(0..<7, id: \.self) { offset in
                let date = Calendar.current.date(byAdding: .day, value: -offset, to: .now)!
                HistoryDayRow(
                    date: date,
                    medicationEvents: medicationEvents,
                    sleepEvents: sleepEvents,
                    mealEvents: mealEvents,
                    nightSnackEvents: nightSnackEvents,
                    mealRules: mealRules
                )
            }
        } header: {
            Text("最近 7 天")
        }
    }
}

struct HistoryDayRow: View {
    let date: Date
    let medicationEvents: [MedicationEvent]
    let sleepEvents: [SleepEvent]
    let mealEvents: [MealEvent]
    let nightSnackEvents: [NightSnackEvent]
    let mealRules: [MealRule]

    private var dayStart: Date { Calendar.current.startOfDay(for: date) }
    private var dayEnd: Date { Calendar.current.date(byAdding: .day, value: 1, to: dayStart)! }

    private var medsForDay: [MedicationEvent] {
        medicationEvents.filter { $0.scheduledAt >= dayStart && $0.scheduledAt < dayEnd }
    }
    private var sleepForDay: [SleepEvent] {
        sleepEvents.filter { $0.date >= dayStart && $0.date < dayEnd }
    }
    private var mealForDay: [MealEvent] {
        mealEvents.filter { $0.scheduledAt >= dayStart && $0.scheduledAt < dayEnd }
    }
    private var nsForDay: NightSnackEvent? {
        nightSnackEvents.first { $0.date >= dayStart && $0.date < dayEnd }
    }

    private var doneCount: Int { medsForDay.filter { $0.status == .done }.count }
    private var sleepConfirmed: Bool { sleepForDay.contains { $0.status == .confirmed } }
    private var mealAckCount: Int { mealForDay.filter { $0.status == .acknowledged }.count }

    private var isCompleted: Bool {
        StreakCalculator.isDayCompleted(
            date: date,
            medicationEvents: medicationEvents,
            sleepEvents: sleepEvents,
            mealEvents: mealEvents,
            mealRules: mealRules
        )
    }

    var body: some View {
        NavigationLink {
            HistoryDayDetailView(
                date: date,
                medicationEvents: medsForDay,
                sleepEvents: sleepForDay,
                mealEvents: mealForDay,
                nightSnackEvent: nsForDay
            )
        } label: {
            HStack {
                Text(date, format: .dateTime.month(.defaultDigits).day(.twoDigits))
                    .font(AppTypography.subheadline)
                    .frame(width: 40, alignment: .leading)

                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isCompleted ? .green : AppColors.textTertiary)
                    .font(AppTypography.caption)

                Spacer()

                Text("\(doneCount)/\(medsForDay.count)")
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.medication)
                    .frame(width: 40)

                Image(systemName: sleepConfirmed ? "moon.fill" : "moon")
                    .font(AppTypography.caption)
                    .foregroundStyle(sleepConfirmed ? .indigo : AppColors.textTertiary)
                    .frame(width: 24)

                if let ns = nsForDay {
                    Text(ns.status == .noSnack ? "✓" : "✗")
                        .font(AppTypography.caption)
                        .foregroundStyle(ns.status == .noSnack ? .green : .red)
                        .frame(width: 16)
                }
            }
        }
    }
}

#Preview {
    HistoryView()
        .modelContainer(for: [
            MedicationEvent.self,
            SleepEvent.self,
            MealEvent.self,
            NightSnackEvent.self,
            MealRule.self
        ], inMemory: true)
}
