import SwiftUI
import SwiftData

struct FullLogView: View {
    @Query(sort: \MedicationEvent.scheduledAt, order: .reverse) private var medicationEvents: [MedicationEvent]
    @Query(sort: \SleepEvent.date, order: .reverse) private var sleepEvents: [SleepEvent]
    @Query(sort: \MealEvent.scheduledAt, order: .reverse) private var mealEvents: [MealEvent]
    @Query(sort: \NightSnackEvent.date, order: .reverse) private var nightSnackEvents: [NightSnackEvent]

    @State private var selectedFilter: EventFilter = .all

    enum EventFilter: String, CaseIterable {
        case all = "全部"
        case medication = "药物"
        case sleep = "睡觉"
        case meal = "饮食"
        case nightSnack = "夜宵"
    }

    var body: some View {
        List {
            Picker("筛选", selection: $selectedFilter) {
                ForEach(EventFilter.allCases, id: \.self) { filter in
                    Text(filter.rawValue).tag(filter)
                }
            }
            .pickerStyle(.segmented)
            .listRowInsets(EdgeInsets())

            if selectedFilter == .all || selectedFilter == .medication {
                ForEach(medicationEvents) { event in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(event.scheduledAt, style: .date)
                                .font(AppTypography.caption)
                                .foregroundStyle(AppColors.textTertiary)
                            Text(event.scheduledAt, style: .time)
                                .font(AppTypography.caption)
                                .foregroundStyle(AppColors.textTertiary)
                        }
                        HStack {
                            Text(event.medicationName)
                                .font(AppTypography.subheadline)
                            Spacer()
                            Text(event.status.displayName)
                                .font(AppTypography.caption)
                                .foregroundStyle(statusColor(event.status))
                        }
                        if let confirmedAt = event.confirmedAt {
                            Text("确认: \(confirmedAt, style: .time)")
                                .font(AppTypography.caption2)
                                .foregroundStyle(AppColors.textSecondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }

            if selectedFilter == .all || selectedFilter == .sleep {
                ForEach(sleepEvents) { event in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(event.date, style: .date)
                            .font(AppTypography.caption)
                            .foregroundStyle(AppColors.textTertiary)
                        HStack {
                            Text("目标 \(event.targetBedtime, style: .time)")
                                .font(AppTypography.subheadline)
                            Spacer()
                            Text(event.status.displayName)
                                .font(AppTypography.caption)
                                .foregroundStyle(event.status == .confirmed ? .green : .orange)
                        }
                        if let confirmedAt = event.confirmedAt {
                            Text("确认: \(confirmedAt, style: .time)")
                                .font(AppTypography.caption2)
                                .foregroundStyle(AppColors.textSecondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }

            if selectedFilter == .all || selectedFilter == .meal {
                ForEach(mealEvents) { event in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(event.scheduledAt, style: .date)
                            .font(AppTypography.caption)
                            .foregroundStyle(AppColors.textTertiary)
                        HStack {
                            Text(event.mealType.displayName)
                                .font(AppTypography.subheadline)
                            Spacer()
                            Text(event.status.displayName)
                                .font(AppTypography.caption)
                                .foregroundStyle(event.status == .acknowledged ? .green : .orange)
                        }
                        if let acknowledgedAt = event.acknowledgedAt {
                            Text("确认: \(acknowledgedAt, style: .time)")
                                .font(AppTypography.caption2)
                                .foregroundStyle(AppColors.textSecondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }

            if selectedFilter == .all || selectedFilter == .nightSnack {
                ForEach(nightSnackEvents) { event in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(event.date, style: .date)
                            .font(AppTypography.caption)
                            .foregroundStyle(AppColors.textTertiary)
                        HStack {
                            Text("夜宵")
                                .font(AppTypography.subheadline)
                            Spacer()
                            Text(event.status.displayName)
                                .font(AppTypography.caption)
                                .foregroundStyle(nsColor(event.status))
                        }
                        if let recordedAt = event.recordedAt {
                            Text("记录: \(recordedAt, style: .time)")
                                .font(AppTypography.caption2)
                                .foregroundStyle(AppColors.textSecondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("完整日志")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func statusColor(_ status: MedicationEventStatus) -> Color {
        switch status {
        case .done: return .green
        case .pending: return .orange
        case .skipped: return .gray
        case .unconfirmed: return .red
        }
    }

    private func nsColor(_ status: NightSnackStatus) -> Color {
        switch status {
        case .noSnack: return .green
        case .ateSnack: return .red
        case .unset: return AppColors.textTertiary
        }
    }
}

#Preview {
    NavigationStack {
        FullLogView()
    }
    .modelContainer(for: [
        MedicationEvent.self,
        SleepEvent.self,
        MealEvent.self,
        NightSnackEvent.self
    ], inMemory: true)
}
