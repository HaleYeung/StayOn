import SwiftUI
import SwiftData

struct MealRuleEditView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    let mealType: MealType
    let existingRule: MealRule?

    @State private var isActive: Bool = true
    @State private var reminderTime: Date = Date()
    @State private var selectedTags: Set<String> = []
    @State private var customNote: String = ""
    @State private var saveState: SaveState = .idle

    @Query private var settingsList: [AppSettings]
    private var availableTags: [String] {
        settingsList.first?.mealTemplateTags ?? ToneStyle.defaultTags
    }

    var body: some View {
        Form {
            Section {
                Toggle("启用\(mealType.displayName)提醒", isOn: $isActive)
            }

            Section {
                DatePicker("提醒时间", selection: $reminderTime, displayedComponents: .hourAndMinute)
            } header: {
                Text("时间")
            }

            Section {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 8) {
                    ForEach(availableTags, id: \.self) { tag in
                        TagToggleButton(tag: tag, isSelected: selectedTags.contains(tag)) {
                            if selectedTags.contains(tag) {
                                selectedTags.remove(tag)
                            } else {
                                selectedTags.insert(tag)
                            }
                        }
                    }
                }
                .padding(.vertical, 4)
            } header: {
                Text("模板标签")
            }

            Section {
                TextField("自定义备注（选填）", text: $customNote, axis: .vertical)
                    .lineLimit(2...4)
            } header: {
                Text("自定义备注")
            }

            Section {
                notificationPreview
            } header: {
                Text("通知预览")
            }
        }
        .navigationTitle(mealType.displayName + "提醒")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                saveButton
            }
        }
        .disabled(saveState == .saving)
        .onAppear { loadExistingRule() }
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

    private var notificationPreview: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("吃之前先看一眼")
                .font(AppTypography.subheadline.weight(.medium))
            Text(previewBody)
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textSecondary)
        }
        .padding(.vertical, 4)
    }

    private var previewBody: String {
        var parts = Array(selectedTags)
        if !customNote.isEmpty {
            parts.append(customNote)
        }
        return parts.joined(separator: "，")
    }

    private func loadExistingRule() {
        guard let rule = existingRule else { return }
        isActive = rule.isActive
        reminderTime = rule.reminderTime
        selectedTags = Set(rule.templateTags)
        customNote = rule.customNote ?? ""
    }

    private func performSave() {
        saveState = .saving
        saveRule()
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

    private func saveRule() {
        if let existing = existingRule {
            existing.isActive = isActive
            existing.reminderTime = reminderTime
            existing.templateTags = Array(selectedTags)
            existing.customNote = customNote.isEmpty ? nil : customNote
            existing.updatedAt = .now
        } else {
            let newRule = MealRule(
                mealType: mealType,
                reminderTime: reminderTime,
                templateTags: Array(selectedTags),
                customNote: customNote.isEmpty ? nil : customNote,
                isActive: isActive
            )
            modelContext.insert(newRule)
        }
        try? modelContext.save()
    }
}

enum SaveState: Equatable {
    case idle
    case saving
    case saved
}

struct TagToggleButton: View {
    let tag: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(tag)
                .font(AppTypography.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.orange.opacity(0.2) : Color.gray.opacity(0.1))
                .foregroundStyle(isSelected ? .orange : AppColors.textSecondary)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        MealRuleEditView(mealType: .lunch, existingRule: nil)
    }
    .modelContainer(for: [MealRule.self], inMemory: true)
}
