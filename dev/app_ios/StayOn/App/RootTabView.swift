import SwiftUI
import SwiftData

struct RootTabView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedTab: Tab = .today
    @State private var hasGeneratedEvents = false

    enum Tab: String, CaseIterable {
        case today = "今天"
        case medication = "药物"
        case routine = "作息"
        case history = "历史"
        case settings = "设置"

        var iconName: String {
            switch self {
            case .today: return "sun.max.fill"
            case .medication: return "pills.fill"
            case .routine: return "moon.stars.fill"
            case .history: return "clock.fill"
            case .settings: return "gearshape.fill"
            }
        }
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            TodayView()
                .tabItem {
                    Label(Tab.today.rawValue, systemImage: Tab.today.iconName)
                }
                .tag(Tab.today)

            MedicationListView()
                .tabItem {
                    Label(Tab.medication.rawValue, systemImage: Tab.medication.iconName)
                }
                .tag(Tab.medication)

            RoutineView()
                .tabItem {
                    Label(Tab.routine.rawValue, systemImage: Tab.routine.iconName)
                }
                .tag(Tab.routine)

            HistoryView()
                .tabItem {
                    Label(Tab.history.rawValue, systemImage: Tab.history.iconName)
                }
                .tag(Tab.history)

            SettingsView()
                .tabItem {
                    Label(Tab.settings.rawValue, systemImage: Tab.settings.iconName)
                }
                .tag(Tab.settings)
        }
        .tint(AppColors.accent)
        .task {
            guard !hasGeneratedEvents else { return }
            hasGeneratedEvents = true
            DailyEventGenerator.generateIfNeeded(modelContext: modelContext)
            await NotificationScheduler.scheduleTodayNotifications(modelContext: modelContext)
            let settingsList = (try? modelContext.fetch(FetchDescriptor<AppSettings>())) ?? []
            if let style = ToneStyle(rawValue: settingsList.first?.toneStyle ?? "") {
                NotificationTextBuilder.currentStyle = style
            }
        }
    }
}

#Preview {
    RootTabView()
        .modelContainer(for: [
            Medication.self,
            MedicationEvent.self,
            SleepPlan.self,
            SleepEvent.self,
            MealRule.self,
            MealEvent.self,
            NightSnackEvent.self,
            AppSettings.self
        ], inMemory: true)
}
