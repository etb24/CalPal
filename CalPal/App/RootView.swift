import SwiftUI
import SwiftData


enum AppTab: Hashable { case dashboard, log, settings }


struct RootView: View {
    @Environment(\.modelContext) private var context
    @Query private var plans: [MacroPlan]
    @State private var selection: AppTab = .dashboard
    @State private var showPlanSheet = false


    var body: some View {
        TabView(selection: $selection) {
            DashboardView(selectedTab: $selection)
            .tabItem { Label("Dashboard", systemImage: "chart.pie.fill") }
            .tag(AppTab.dashboard)

            LogView()
            .tabItem { Label("Log", systemImage: "plus.app.fill") }
            .tag(AppTab.log)

            SettingsView()
            .tabItem { Label("Settings", systemImage: "gearshape.fill") }
            .tag(AppTab.settings)
        }
        .onAppear {
            if plans.isEmpty {
                context.insert(MacroPlan()); try? context.save(); showPlanSheet = true
            }
        }
        .sheet(isPresented: $showPlanSheet) { PlanEditor() }
    }
}
