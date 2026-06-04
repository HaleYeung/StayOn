import SwiftUI
import SwiftData

struct MedicationFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let medication: Medication?

    @State private var name: String = ""
    @State private var dosageText: String = ""
    @State private var scheduleType: ScheduleType = .daily
    @State private var selectedWeekdays: Set<Int> = []
    @State private var timesPerDay: Int = 1
    @State private var reminderTimes: [Date] = [Date()]
    @State private var mealNote: MealNoteType = .none
    @State private var note: String = ""
    @State private var isActive: Bool = true
    @State private var snoozeIntervalMinutes: Int = 10
    @State private var maxSnoozeCount: Int = 1

    @State private var showingDeleteAlert = false

    private let weekdays = ["一", "二", "三", "四", "五", "六", "日"]

    var body: some View {
        Form {
            Section {
                TextField("药名（必填）", text: $name)

                TextField("剂量文本（选填，如：10mg）", text: $dosageText)
            } header: {
                Text("基础信息")
            }

            Section {
                Picker("频率", selection: $scheduleType) {
                    Text("每天").tag(ScheduleType.daily)
                    Text("按星期").tag(ScheduleType.weekly)
                }

                if scheduleType == .weekly {
                    HStack {
                        Text("选择星期")
                        Spacer()
                        WeekdayPicker(selectedWeekdays: $selectedWeekdays)
                    }
                }

                Stepper("每天 \(timesPerDay) 次", value: $timesPerDay, in: 1...10)

                ForEach(0..<timesPerDay, id: \.self) { index in
                    DatePicker(
                        "第 \(index + 1) 次",
                        selection: Binding(
                            get: { reminderTimes.indices.contains(index) ? reminderTimes[index] : Date() },
                            set: { newValue in
                                while reminderTimes.count <= index {
                                    reminderTimes.append(Date())
                                }
                                reminderTimes[index] = newValue
                            }
                        ),
                        displayedComponents: .hourAndMinute
                    )
                }
            } header: {
                Text("服用计划")
            }

            Section {
                Picker("饭前/饭后", selection: $mealNote) {
                    ForEach(MealNoteType.allCases, id: \.self) { type in
                        Text(type.displayName).tag(type)
                    }
                }

                TextField("备注（选填）", text: $note, axis: .vertical)
                    .lineLimit(2...4)
            } header: {
                Text("备注")
            }

            Section {
                Toggle("启用提醒", isOn: $isActive)

                Stepper("稍后提醒间隔：\(snoozeIntervalMinutes) 分钟", value: $snoozeIntervalMinutes, in: 5...60, step: 5)

                Stepper("最大追提醒次数：\(maxSnoozeCount) 次", value: $maxSnoozeCount, in: 1...5)
            } header: {
                Text("提醒设置")
            }

            if medication != nil {
                Section {
                    Button("删除药物", role: .destructive) {
                        showingDeleteAlert = true
                    }
                }
            }
        }
        .navigationTitle(medication == nil ? "添加药物" : "编辑药物")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("取消") {
                    dismiss()
                }
            }

            ToolbarItem(placement: .confirmationAction) {
                Button("保存") {
                    saveMedication()
                }
                .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .alert("删除药物", isPresented: $showingDeleteAlert) {
            Button("取消", role: .cancel) {}
            Button("删除", role: .destructive) {
                deleteMedication()
            }
        } message: {
            Text("删除后历史记录会保留，但无法再创建新的服药事件。")
        }
        .onAppear {
            loadMedication()
        }
    }

    private func loadMedication() {
        guard let medication else { return }
        name = medication.name
        dosageText = medication.dosageText ?? ""
        scheduleType = medication.scheduleType
        selectedWeekdays = Set(medication.weekdays)
        timesPerDay = medication.timesPerDay
        reminderTimes = medication.reminderTimes.isEmpty ? [Date()] : medication.reminderTimes
        mealNote = MealNoteType(rawValue: medication.mealNote ?? "") ?? .none
        note = medication.note ?? ""
        isActive = medication.isActive
        snoozeIntervalMinutes = medication.snoozeIntervalMinutes
        maxSnoozeCount = medication.maxSnoozeCount
    }

    private func saveMedication() {
        if let existingMedication = medication {
            existingMedication.name = name.trimmingCharacters(in: .whitespaces)
            existingMedication.dosageText = dosageText.isEmpty ? nil : dosageText
            existingMedication.scheduleType = scheduleType
            existingMedication.weekdays = Array(selectedWeekdays).sorted()
            existingMedication.timesPerDay = timesPerDay
            existingMedication.reminderTimes = Array(reminderTimes.prefix(timesPerDay))
            existingMedication.mealNote = mealNote.rawValue
            existingMedication.note = note.isEmpty ? nil : note
            existingMedication.isActive = isActive
            existingMedication.snoozeIntervalMinutes = snoozeIntervalMinutes
            existingMedication.maxSnoozeCount = maxSnoozeCount
            existingMedication.updatedAt = .now
        } else {
            let newMedication = Medication(
                name: name.trimmingCharacters(in: .whitespaces),
                dosageText: dosageText.isEmpty ? nil : dosageText,
                scheduleType: scheduleType,
                weekdays: Array(selectedWeekdays).sorted(),
                timesPerDay: timesPerDay,
                reminderTimes: Array(reminderTimes.prefix(timesPerDay)),
                mealNote: mealNote == .none ? nil : mealNote.rawValue,
                note: note.isEmpty ? nil : note,
                isActive: isActive,
                snoozeIntervalMinutes: snoozeIntervalMinutes,
                maxSnoozeCount: maxSnoozeCount
            )
            modelContext.insert(newMedication)
        }

        DailyEventGenerator.generateIfNeeded(modelContext: modelContext)

        Task {
            await NotificationManager.shared.requestIfFirstPlan(modelContext: modelContext)
            await NotificationScheduler.scheduleTodayNotifications(modelContext: modelContext)
        }

        dismiss()
    }

    private func deleteMedication() {
        if let medication {
            modelContext.delete(medication)
        }
        dismiss()
    }
}

struct WeekdayPicker: View {
    @Binding var selectedWeekdays: Set<Int>

    private let weekdays = ["一", "二", "三", "四", "五", "六", "日"]

    var body: some View {
        HStack(spacing: 4) {
            ForEach(1...7, id: \.self) { day in
                Button {
                    if selectedWeekdays.contains(day) {
                        selectedWeekdays.remove(day)
                    } else {
                        selectedWeekdays.insert(day)
                    }
                } label: {
                    Text(weekdays[day - 1])
                        .font(AppTypography.caption)
                        .frame(width: 32, height: 32)
                        .background(selectedWeekdays.contains(day) ? Color.accentColor : Color.gray.opacity(0.2))
                        .foregroundStyle(selectedWeekdays.contains(day) ? .white : .primary)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }
        }
    }
}

#Preview {
    NavigationStack {
        MedicationFormView(medication: nil)
    }
    .modelContainer(for: [Medication.self], inMemory: true)
}
