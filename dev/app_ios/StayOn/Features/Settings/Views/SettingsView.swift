import SwiftUI
import SwiftData
import UserNotifications

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var settingsList: [AppSettings]

    @State private var notificationStatus: UNAuthorizationStatus = .notDetermined

    private var settings: AppSettings? { settingsList.first }

    @State private var defaultSnoozeMinutes: Int = 10
    @State private var defaultMaxSnoozeCount: Int = 1
    @State private var selectedTone: ToneStyle = .lightSupervision

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Label("通知权限", systemImage: "bell.fill")
                        Spacer()
                        Text(notificationStatusText)
                            .foregroundStyle(AppColors.textSecondary)
                        Image(systemName: notificationStatusIcon)
                            .foregroundStyle(notificationStatusColor)
                    }
                    .onTapGesture {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }
                } header: {
                    Text("通知")
                }

                Section {
                    Stepper("稍后提醒间隔: \(defaultSnoozeMinutes) 分钟", value: Binding(
                        get: { defaultSnoozeMinutes },
                        set: { defaultSnoozeMinutes = $0; settings?.defaultSnoozeMinutes = $0; try? modelContext.save() }
                    ), in: 5...60, step: 5)

                    Stepper("最大追提醒次数: \(defaultMaxSnoozeCount) 次", value: Binding(
                        get: { defaultMaxSnoozeCount },
                        set: { defaultMaxSnoozeCount = $0; settings?.defaultMaxSnoozeCount = $0; try? modelContext.save() }
                    ), in: 1...5)
                } header: {
                    Text("默认提醒行为")
                }

                Section {
                    Picker("文案风格", selection: $selectedTone) {
                        ForEach(ToneStyle.allCases, id: \.self) { style in
                            VStack(alignment: .leading) {
                                Text(style.displayName)
                                Text(style.description)
                                    .font(AppTypography.caption)
                                    .foregroundStyle(AppColors.textSecondary)
                            }
                            .tag(style)
                        }
                    }
                    .pickerStyle(.menu)
                    .onChange(of: selectedTone) { _, newValue in
                        settings?.toneStyle = newValue.rawValue
                        NotificationTextBuilder.currentStyle = newValue
                        try? modelContext.save()
                    }
                } header: {
                    Text("文案风格")
                }

                Section {
                    NavigationLink {
                        MealTagManagementView()
                    } label: {
                        Label("饮食模板标签", systemImage: "tag")
                    }
                } footer: {
                    Text("管理可在饮食提醒中使用的模板标签")
                }

                Section {
                    NavigationLink {
                        Text("数据导出")
                    } label: {
                        Label("数据导出", systemImage: "square.and.arrow.up")
                    }

                    NavigationLink {
                        Text("iCloud 同步")
                    } label: {
                        Label("iCloud 同步", systemImage: "icloud")
                    }

                    NavigationLink {
                        Text("Apple Health")
                    } label: {
                        Label("Apple Health", systemImage: "heart.fill")
                    }
                } header: {
                    Text("扩展")
                }

                Section {
                    HStack {
                        Text("版本")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(AppColors.textSecondary)
                    }
                } header: {
                    Text("关于")
                }
            }
            .navigationTitle("设置")
            .task {
                notificationStatus = await NotificationManager.shared.getAuthorizationStatus()
                loadSettings()
            }
        }
    }

    private func loadSettings() {
        guard let s = settings else { return }
        defaultSnoozeMinutes = s.defaultSnoozeMinutes
        defaultMaxSnoozeCount = s.defaultMaxSnoozeCount
        selectedTone = ToneStyle(rawValue: s.toneStyle) ?? .lightSupervision
    }

    private var notificationStatusText: String {
        switch notificationStatus {
        case .authorized: return "已开启"
        case .denied: return "已关闭"
        case .notDetermined: return "未设置"
        case .provisional: return "临时"
        case .ephemeral: return "临时"
        @unknown default: return "未知"
        }
    }

    private var notificationStatusIcon: String {
        switch notificationStatus {
        case .authorized: return "checkmark.circle.fill"
        case .denied: return "xmark.circle.fill"
        default: return "questionmark.circle.fill"
        }
    }

    private var notificationStatusColor: Color {
        switch notificationStatus {
        case .authorized: return .green
        case .denied: return .red
        default: return .orange
        }
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: [AppSettings.self], inMemory: true)
}
