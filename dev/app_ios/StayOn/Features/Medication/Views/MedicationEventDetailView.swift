import SwiftUI
import SwiftData

struct MedicationEventDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var event: MedicationEvent
    @State private var mealNoteText: String?

    private var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: event.scheduledAt)
    }

    var body: some View {
        List {
            Section {
                LabeledContent("计划时间") {
                    Text(timeString)
                }

                LabeledContent("状态") {
                    StatusBadge(status: event.status)
                }

                if let dosage = event.dosageText, !dosage.isEmpty {
                    LabeledContent("剂量") {
                        Text(dosage)
                    }
                }

                if let mealNote = mealNoteText, !mealNote.isEmpty {
                    LabeledContent("饭前/饭后") {
                        Text(mealNote)
                            .foregroundStyle(.orange)
                    }
                }

                if event.snoozeCount > 0 {
                    LabeledContent("已稍后提醒") {
                        Text("\(event.snoozeCount) 次")
                    }
                }
            } header: {
                Text("服药信息")
            }

            if let confirmedAt = event.confirmedAt {
                Section {
                    LabeledContent("确认时间") {
                        Text(confirmedAt, style: .time)
                    }
                    Button("撤回", role: .destructive) {
                        undoStatus()
                    }
                } header: {
                    Text("已吃")
                }
            }

            if let skippedAt = event.skippedAt {
                Section {
                    LabeledContent("跳过时间") {
                        Text(skippedAt, style: .time)
                    }
                    Button("撤回", role: .destructive) {
                        undoStatus()
                    }
                } header: {
                    Text("已跳过")
                }
            }

            if event.status == .pending {
                Section {
                    Button {
                        markAsDone()
                    } label: {
                        Label("已吃", systemImage: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    }

                    Button {
                        markAsSkipped()
                    } label: {
                        Label("跳过", systemImage: "forward.fill")
                            .foregroundStyle(.secondary)
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
        .navigationTitle(event.medicationName)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            let allMeds = (try? modelContext.fetch(FetchDescriptor<Medication>())) ?? []
            let medication = allMeds.first { $0.id == event.medicationId }
            if let medication,
               let rawNote = medication.mealNote,
               let noteType = MealNoteType(rawValue: rawNote),
               noteType != .none {
                mealNoteText = noteType.displayName
            }
        }
    }

    private func markAsDone() {
        event.status = .done
        event.confirmedAt = .now
        try? modelContext.save()
    }

    private func markAsSkipped() {
        event.status = .skipped
        event.skippedAt = .now
        try? modelContext.save()
    }

    private func undoStatus() {
        event.status = .pending
        event.confirmedAt = nil
        event.skippedAt = nil
        try? modelContext.save()
    }

    private func snooze() {
        event.snoozeCount += 1
        event.lastNotificationAt = .now
        try? modelContext.save()

        Task {
            await NotificationScheduler.shared.scheduleMedicationSnooze(
                for: event,
                medicationName: event.medicationName,
                minutes: 10
            )
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Medication.self, MedicationEvent.self, configurations: config)

    let event = MedicationEvent(
        medicationId: UUID(),
        medicationName: "阿托伐他汀",
        dosageText: "20mg",
        scheduledAt: Date()
    )
    container.mainContext.insert(event)

    return NavigationStack {
        MedicationEventDetailView(event: event)
    }
    .modelContainer(container)
}
