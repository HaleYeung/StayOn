import SwiftUI
import SwiftData

struct MealRuleListView: View {
    @Query private var mealRules: [MealRule]

    private var breakfastRule: MealRule? { mealRules.first { $0.mealType == .breakfast } }
    private var lunchRule: MealRule? { mealRules.first { $0.mealType == .lunch } }
    private var dinnerRule: MealRule? { mealRules.first { $0.mealType == .dinner } }

    var body: some View {
        List {
            Section {
                NavigationLink {
                    MealRuleEditView(mealType: .breakfast, existingRule: breakfastRule)
                } label: {
                    MealRuleRow(mealType: .breakfast, rule: breakfastRule)
                }
            }

            Section {
                NavigationLink {
                    MealRuleEditView(mealType: .lunch, existingRule: lunchRule)
                } label: {
                    MealRuleRow(mealType: .lunch, rule: lunchRule)
                }
            }

            Section {
                NavigationLink {
                    MealRuleEditView(mealType: .dinner, existingRule: dinnerRule)
                } label: {
                    MealRuleRow(mealType: .dinner, rule: dinnerRule)
                }
            }
        }
        .navigationTitle("饮食提醒")
    }
}

struct MealRuleRow: View {
    let mealType: MealType
    let rule: MealRule?

    private var timeString: String {
        guard let rule else { return "未设置" }
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: rule.reminderTime)
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(mealType.displayName)
                    .font(AppTypography.headline)

                if let rule, rule.isActive {
                    Text(timeString)
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.textSecondary)
                } else {
                    Text("已关闭")
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.textTertiary)
                }
            }

            Spacer()

            if let rule, rule.isActive, !rule.templateTags.isEmpty {
                HStack(spacing: 4) {
                    ForEach(rule.templateTags.prefix(2), id: \.self) { tag in
                        Text(tag)
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.orange.opacity(0.15))
                            .foregroundStyle(.orange)
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        MealRuleListView()
    }
    .modelContainer(for: [MealRule.self], inMemory: true)
}
