import SwiftUI


struct SettingsView: View {
    @State private var showPlan = false
    var body: some View {
        NavigationStack {
            List {
                Section("Goals & Data") {
                    Button { showPlan = true } label: { Label("Macro Plan", systemImage: "slider.horizontal.3") }
                }
                Section("About") { LabeledContent("Version", value: "0.1 (MVP)") }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showPlan) { PlanEditor() }
        }
    }
}
