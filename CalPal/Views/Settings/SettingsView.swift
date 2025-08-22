import SwiftUI


struct SettingsView: View {
    @State private var showPlan = false
    var body: some View {
        NavigationStack {
            List {
                Section("Goals & Data") {
                    NavigationLink { PlanEditor() } label: { Label("Edit Targets", systemImage: "slider.horizontal.3") }
                }
                Section("About") { LabeledContent("Version", value: "0.1 (MVP)") }
            }
            .navigationTitle("Settings")
        }
    }
}
