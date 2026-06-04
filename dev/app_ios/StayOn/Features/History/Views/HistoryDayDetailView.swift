import SwiftUI

struct HistoryDayDetailView: View {
    let date: Date
    let medicationEvents: [MedicationEvent]
    let sleepEvents: [SleepEvent]
    let mealEvents: [MealEvent]
    let nightSnackEvent: NightSnackEvent?

    var body: some View {
        List {
            if !medicationEvents.isEmpty {
                Section {
                    ForEach(medicationEvents) { event in
                        HStack {
                            Text(event.scheduledAt, style: .time)
                                .font(AppTypography.caption)
                                .frame(width: 50, alignment: .leading)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(event.medicationName)
                                    .font(AppTypography.subheadline)
                                if let dosage = event.dosageText, !dosage.isEmpty {
                                    Text(dosage)
                                        .font(AppTypography.caption)
                                        .foregroundStyle(AppColors.textSecondary)
                                }
                            }
                            Spacer()
                            StatusBadge(status: event.status)
                        }
                        .padding(.vertical, 4)
                    }
                } header: {
                    Text("药物")
                }
            }

            if !sleepEvents.isEmpty {
                Section {
                    ForEach(sleepEvents) { event in
                        HStack {
                            Image(systemName: "moon.stars.fill")
                                .foregroundStyle(.indigo)
                                .frame(width: 24)
                            VStack(alignment: .leading) {
                                Text("目标 \(event.targetBedtime, style: .time)")
                                    .font(AppTypography.subheadline)
                                if let confirmedAt = event.confirmedAt {
                                    Text("确认于 \(confirmedAt, style: .time)")
                                        .font(AppTypography.caption)
                                        .foregroundStyle(AppColors.textSecondary)
                                }
                            }
                            Spacer()
                            SleepStatusBadge(status: event.status)
                        }
                    }
                } header: {
                    Text("睡觉")
                }
            }

            if !mealEvents.isEmpty {
                Section {
                    ForEach(mealEvents) { event in
                        HStack {
                            Image(systemName: "fork.knife")
                                .foregroundStyle(.orange)
                                .frame(width: 24)
                            VStack(alignment: .leading) {
                                Text(event.mealType.displayName)
                                    .font(AppTypography.subheadline)
                                if let acknowledgedAt = event.acknowledgedAt {
                                    Text("确认于 \(acknowledgedAt, style: .time)")
                                        .font(AppTypography.caption)
                                        .foregroundStyle(AppColors.textSecondary)
                                }
                            }
                            Spacer()
                            Text(event.status.displayName)
                                .font(AppTypography.caption)
                                .foregroundStyle(event.status == .acknowledged ? .green : .orange)
                        }
                    }
                } header: {
                    Text("饮食提醒")
                }
            }

            if let ns = nightSnackEvent {
                Section {
                    HStack {
                        Image(systemName: "moon.fill")
                            .foregroundStyle(.purple)
                            .frame(width: 24)
                        Text("夜宵")
                            .font(AppTypography.subheadline)
                        Spacer()
                        if let recordedAt = ns.recordedAt {
                            Text("\(ns.status.displayName) \(recordedAt, style: .time)")
                                .font(AppTypography.caption)
                                .foregroundStyle(ns.status == .noSnack ? .green : .red)
                        } else {
                            Text(ns.status.displayName)
                                .font(AppTypography.caption)
                                .foregroundStyle(AppColors.textTertiary)
                        }
                    }
                } header: {
                    Text("夜宵")
                }
            }

            if medicationEvents.isEmpty && sleepEvents.isEmpty && mealEvents.isEmpty && nightSnackEvent == nil {
                Section {
                    Text("当天暂无记录")
                        .font(AppTypography.body)
                        .foregroundStyle(AppColors.textSecondary)
                }
            }
        }
        .navigationTitle(dateFormatted)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var dateFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        return formatter.string(from: date)
    }
}

#Preview {
    NavigationStack {
        HistoryDayDetailView(
            date: .now,
            medicationEvents: [],
            sleepEvents: [],
            mealEvents: [],
            nightSnackEvent: nil
        )
    }
}
