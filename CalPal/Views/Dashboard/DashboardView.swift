import SwiftUI
import SwiftData


struct DashboardView: View {
    @Binding var selectedTab: AppTab
    @Query private var entries: [FoodEntry]
    @Query private var plans: [MacroPlan]


    private var todayEntries: [FoodEntry] {
        let (start, end) = Date.now.dayBounds
        return entries.filter { $0.date >= start && $0.date < end }.sorted { $0.date > $1.date }
    }


    private var totals: (p: Double, c: Double, f: Double, k: Double) {
        let p = todayEntries.reduce(0) { $0 + $1.protein }
        let c = todayEntries.reduce(0) { $0 + $1.carbs }
        let f = todayEntries.reduce(0) { $0 + $1.fat }
        let k = todayEntries.reduce(0) { $0 + $1.calories }
        return (p, c, f, k)
    }
    
    private var plan: MacroPlan? { plans.first }


    private var progress: (p: Double, c: Double, f: Double, k: Double) {
        guard let plan else { return (0,0,0,0) }
        func pct(_ v: Double, _ t: Double) -> Double { t == 0 ? 0 : min(max(v/t, 0), 1) }
        return (
            pct(totals.p, plan.proteinTarget),
            pct(totals.c, plan.carbTarget),
            pct(totals.f, plan.fatTarget),
            pct(totals.k, plan.calorieTarget)
        )
    }

//    Future xp implementation
//    private var dailyXP: Int {
//        guard let plan else { return 0 }
//        var xp = 0
//        if totals.p >= plan.proteinTarget * 0.95 { xp += 25 }
//        if totals.c >= plan.carbTarget * 0.95 { xp += 25 }
//        if totals.f >= plan.fatTarget * 0.95 { xp += 25 }
//        let within = totals.k >= plan.calorieTarget * 0.9 && totals.k <= plan.calorieTarget * 1.1
//        if progress.p >= 0.95 && progress.c >= 0.95 && progress.f >= 0.95 && within { xp += 50 }
//        return xp
//    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                HStack(spacing: 16) {
                    MacroRing(title: "Protein", value: progress.p, current: totals.p, target: plan?.proteinTarget ?? 0, unit: "g", systemImage: "p.circle.fill", color: .orange, )
                    MacroRing(title: "Carbs", value: progress.c, current: totals.c, target: plan?.carbTarget ?? 0, unit: "g", systemImage: "c.circle.fill", color: .green, )
                    MacroRing(title: "Fat", value: progress.f, current: totals.f, target: plan?.fatTarget ?? 0, unit: "g", systemImage: "f.circle.fill", color: .yellow, )
                }
                .padding(.horizontal)


                VStack(alignment: .leading, spacing: 6) {
                    Text("Calories").font(.headline)
                    Gauge(value: progress.k) { Text("\(Int(totals.k)) / \(Int(plan?.calorieTarget ?? 0)) kcal") } currentValueLabel: { Text("\(Int(totals.k))") }
                    .gaugeStyle(.accessoryLinear)
                    .tint(.secondary)
                }
                .padding(.horizontal)


//                Future xp implementation
                
                HStack {
//                    Label("Today's XP: \(dailyXP)", systemImage: "star.fill")
//                    Spacer()
                    NavigationLink { PlanEditor() } label: { Label("Edit Targets", systemImage: "slider.horizontal.3") }
                }
                .padding(.horizontal)


                Divider()


                TodayListPreview(selectedTab: $selectedTab)
            }
            .navigationTitle("CalPal")
        }
    }
}
    
