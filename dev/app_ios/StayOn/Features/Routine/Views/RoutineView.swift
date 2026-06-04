import SwiftUI
import SwiftData

struct RoutineView: View {
    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink {
                        SleepSettingsView()
                    } label: {
                        Label("睡觉提醒", systemImage: "moon.stars.fill")
                    }
                } header: {
                    Text("作息")
                }

                Section {
                    NavigationLink {
                        MealRuleListView()
                    } label: {
                        Label("饮食提醒", systemImage: "fork.knife")
                    }
                } header: {
                    Text("饮食")
                }

                Section {
                    NavigationLink {
                        NightSnackSettingsView()
                    } label: {
                        Label("夜宵提醒", systemImage: "moon.fill")
                    }
                }
            }
            .navigationTitle("作息")
        }
    }
}

#Preview {
    RoutineView()
        .modelContainer(for: [
            SleepPlan.self,
            MealRule.self,
            NightSnackEvent.self
        ], inMemory: true)
}
