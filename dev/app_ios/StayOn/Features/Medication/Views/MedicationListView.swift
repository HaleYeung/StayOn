import SwiftUI
import SwiftData

struct MedicationListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Medication.createdAt, order: .reverse) private var medications: [Medication]
    @Query(sort: \MedicationEvent.scheduledAt) private var allEvents: [MedicationEvent]

    private var todayEvents: [MedicationEvent] {
        let today = Calendar.current.startOfDay(for: .now)
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        return allEvents.filter { $0.scheduledAt >= today && $0.scheduledAt < tomorrow }
    }

    @State private var showingAddMedication = false
    @State private var selectedMedication: Medication?

    var body: some View {
        NavigationStack {
            Group {
                if medications.isEmpty {
                    EmptyStateView(
                        icon: "pills",
                        title: "还没有药物",
                        message: "添加第一种药物，开始管理你的服药计划",
                        actionTitle: "添加药物"
                    ) {
                        showingAddMedication = true
                    }
                } else {
                    List {
                        if !todayEvents.isEmpty {
                            Section {
                                TodayMedicationSection(events: todayEvents)
                            } header: {
                                Text("今日记录")
                            }
                        }

                        Section {
                            ForEach(medications) { medication in
                                MedicationRowView(medication: medication)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        selectedMedication = medication
                                    }
                            }
                            .onDelete(perform: deleteMedications)
                        } header: {
                            Text("药物列表")
                        }
                    }
                }
            }
            .navigationTitle("药物")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddMedication = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddMedication) {
                NavigationStack {
                    MedicationFormView(medication: nil)
                }
            }
            .sheet(item: $selectedMedication) { medication in
                NavigationStack {
                    MedicationFormView(medication: medication)
                }
            }
        }
    }

    private func deleteMedications(at offsets: IndexSet) {
        for index in offsets {
            let medication = medications[index]
            modelContext.delete(medication)
        }
    }
}

struct TodayMedicationSection: View {
    let events: [MedicationEvent]

    var body: some View {
        ForEach(events) { event in
            NavigationLink {
                MedicationEventDetailView(event: event)
            } label: {
                MedicationEventRowView(event: event)
            }
        }
    }
}

struct MedicationRowView: View {
    let medication: Medication

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xxSmall) {
            HStack {
                Text(medication.name)
                    .font(AppTypography.headline)

                if !medication.isActive {
                    Text("已停用")
                        .font(AppTypography.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.gray.opacity(0.2))
                        .clipShape(Capsule())
                }
            }

            if let dosage = medication.dosageText, !dosage.isEmpty {
                Text(dosage)
                    .font(AppTypography.subheadline)
                    .foregroundStyle(AppColors.textSecondary)
            }

            HStack {
                Label("\(medication.timesPerDay)次/天", systemImage: "clock")
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textTertiary)

                if let mealNote = medication.mealNote, let noteType = MealNoteType(rawValue: mealNote), noteType != .none {
                    Text(noteType.displayName)
                        .font(AppTypography.caption)
                        .foregroundStyle(.orange)
                }
            }
        }
        .padding(.vertical, AppSpacing.xxSmall)
    }
}

struct MedicationEventRowView: View {
    let event: MedicationEvent

    private var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: event.scheduledAt)
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(timeString)
                        .font(AppTypography.subheadline.weight(.medium))
                    Text(event.medicationName)
                        .font(AppTypography.body)
                }

                if let dosage = event.dosageText, !dosage.isEmpty {
                    Text(dosage)
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.textSecondary)
                }
            }

            Spacer()

            StatusBadge(status: event.status)
        }
    }
}

struct StatusBadge: View {
    let status: MedicationEventStatus

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
        case .done: return .green
        case .skipped: return .gray
        case .unconfirmed: return .red
        }
    }
}

#Preview {
    MedicationListView()
        .modelContainer(for: [
            Medication.self,
            MedicationEvent.self
        ], inMemory: true)
}
