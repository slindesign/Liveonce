import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Bindable var profile: UserProfile

    var body: some View {
        NavigationStack {
            Form {
                DatePicker("Birth Date", selection: $profile.birthDate, displayedComponents: .date)
                Stepper(value: $profile.lifeExpectancyYears, in: 50...120) {
                    Text("Life Expectancy: \(profile.lifeExpectancyYears)")
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        profile.updatedAt = Date()
                        WidgetSummaryUpdater.refresh(modelContext: modelContext)
                        dismiss()
                    }
                }
            }
        }
    }
}
