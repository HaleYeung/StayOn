import SwiftUI
import SwiftData

struct MealReminderCard: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var mealRules: [MealRule]

    /// Show the active meal rule whose time matches the current time of day.
    /// Compares only hour/minute, ignoring the date part.
    private var currentMealRule: MealRule? {
        let now = Date()
        let nowComponents = Calendar.current.dateComponents([.hour, .minute], from: now)
        let nowMinutes = nowComponents.hour! * 60 + nowComponents.minute!

        // Find active rule whose reminder time is closest to now (within 4 hours window)
        let activeRules = mealRules.filter { $0.isActive && $0.mealType != .nightSnack }
        var bestRule: MealRule?
        var bestDiff = Int.max

        for rule in activeRules {
            let ruleComponents = Calendar.current.dateComponents([.hour, .minute], from: rule.reminderTime)
            let ruleMinutes = ruleComponents.hour! * 60 + ruleComponents.minute!
            let diff = nowMinutes - ruleMinutes

            // Show if within 1 hour before to 3 hours after reminder time
            if diff >= -60 && diff <= 180 {
                if abs(diff) < abs(bestDiff) {
                    bestDiff = diff
                    bestRule = rule
                }
            }
        }

        return bestRule
    }

    var body: some View {
        if let rule = currentMealRule {
            NavigationLink {
                MealDetailView(rule: rule)
            } label: {
                StatusCard(title: "\(rule.mealType.displayName)前提醒", icon: "fork.knife", iconColor: .orange) {
                    VStack(alignment: .leading, spacing: AppSpacing.xSmall) {
                        if !rule.templateTags.isEmpty {
                            FlowLayout(spacing: 4) {
                                ForEach(rule.templateTags, id: \.self) { tag in
                                    TagChipView(text: tag, color: .orange)
                                }
                            }
                        }

                        if let note = rule.customNote, !note.isEmpty {
                            Text(note)
                                .font(AppTypography.caption)
                                .foregroundStyle(AppColors.textSecondary)
                        }

                        Button {
                            acknowledgeMeal(rule: rule)
                        } label: {
                            Text("知道了")
                                .font(AppTypography.subheadline.weight(.medium))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, AppSpacing.xSmall)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.orange)
                        .padding(.top, AppSpacing.xSmall)
                    }
                }
                .padding(.horizontal)
            }
            .buttonStyle(.plain)
        }
    }

    private func acknowledgeMeal(rule: MealRule) {
        let event = MealEvent(
            mealType: rule.mealType,
            scheduledAt: Date(),
            status: .acknowledged,
            acknowledgedAt: .now,
            noteSnapshot: rule.customNote,
            tagsSnapshot: rule.templateTags
        )
        modelContext.insert(event)
        try? modelContext.save()
    }
}

struct MealDetailView: View {
    @Environment(\.modelContext) private var modelContext
    let rule: MealRule
    @State private var hasAcknowledged = false

    private var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: rule.reminderTime)
    }

    var body: some View {
        List {
            Section {
                LabeledContent("餐次") {
                    Text(rule.mealType.displayName)
                }

                LabeledContent("提醒时间") {
                    Text(timeString)
                }
            } header: {
                Text("提醒信息")
            }

            if !rule.templateTags.isEmpty {
                Section {
                    FlowLayout(spacing: 4) {
                        ForEach(rule.templateTags, id: \.self) { tag in
                            TagChipView(text: tag, color: .orange)
                        }
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("注意事项")
                }
            }

            if let note = rule.customNote, !note.isEmpty {
                Section {
                    Text(note)
                        .font(AppTypography.body)
                } header: {
                    Text("备注")
                }
            }

            Section {
                Button {
                    acknowledgeMeal()
                } label: {
                    Label("知道了", systemImage: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                }
                .disabled(hasAcknowledged)
            } header: {
                Text("操作")
            }
        }
        .navigationTitle(rule.mealType.displayName + "提醒")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func acknowledgeMeal() {
        hasAcknowledged = true
        let event = MealEvent(
            mealType: rule.mealType,
            scheduledAt: Date(),
            status: .acknowledged,
            acknowledgedAt: .now,
            noteSnapshot: rule.customNote,
            tagsSnapshot: rule.templateTags
        )
        modelContext.insert(event)
        try? modelContext.save()
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? UIScreen.main.bounds.width
        let result = FlowResult(in: width, subviews: subviews, spacing: spacing)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x, y: bounds.minY + result.positions[index].y), proposal: .unspecified)
        }
    }

    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []

        init(in width: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var rowHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                if x + size.width > width, x > 0 {
                    x = 0
                    y += rowHeight + spacing
                    rowHeight = 0
                }
                positions.append(CGPoint(x: x, y: y))
                rowHeight = max(rowHeight, size.height)
                x += size.width + spacing
                self.size.width = max(self.size.width, x)
                self.size.height = y + rowHeight
            }
        }
    }
}

#Preview {
    MealReminderCard()
        .modelContainer(for: [MealRule.self], inMemory: true)
}
