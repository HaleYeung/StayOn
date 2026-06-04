import SwiftUI
import SwiftData

struct MealTagManagementView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var settingsList: [AppSettings]

    @State private var tags: [String] = []
    @State private var newTagText: String = ""
    @State private var showingAddAlert = false

    var body: some View {
        List {
            Section {
                ForEach(tags, id: \.self) { tag in
                    HStack {
                        Text(tag)
                        Spacer()
                        Button {
                            deleteTag(tag)
                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .foregroundStyle(.red)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        let tag = tags[index]
                        deleteTag(tag)
                    }
                }

                Button {
                    showingAddAlert = true
                } label: {
                    Label("添加标签", systemImage: "plus")
                }
            } header: {
                Text("模板标签")
            } footer: {
                Text("此处添加的标签可在饮食提醒设置中选择")
            }
        }
        .navigationTitle("饮食模板标签")
        .alert("添加标签", isPresented: $showingAddAlert) {
            TextField("标签名", text: $newTagText)
            Button("取消", role: .cancel) {
                newTagText = ""
            }
            Button("添加") {
                addTag()
            }
            .disabled(newTagText.trimmingCharacters(in: .whitespaces).isEmpty)
        } message: {
            Text("输入新的饮食提醒标签")
        }
        .onAppear {
            tags = settingsList.first?.mealTemplateTags ?? ToneStyle.defaultTags
        }
    }

    private func addTag() {
        let tag = newTagText.trimmingCharacters(in: .whitespaces)
        guard !tag.isEmpty, !tags.contains(tag) else { return }
        tags.append(tag)
        settingsList.first?.mealTemplateTags = tags
        try? modelContext.save()
        newTagText = ""
    }

    private func deleteTag(_ tag: String) {
        tags.removeAll { $0 == tag }
        settingsList.first?.mealTemplateTags = tags
        try? modelContext.save()
    }
}

#Preview {
    NavigationStack {
        MealTagManagementView()
    }
    .modelContainer(for: [AppSettings.self], inMemory: true)
}
