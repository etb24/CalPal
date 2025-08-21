import SwiftUI
import SwiftData


struct TodayListPreview: View {
    @Binding var selectedTab: AppTab
    @Query private var entries: [FoodEntry]


    private var todayEntries: [FoodEntry] {
        let (start, end) = Date.now.dayBounds
        return entries.filter { $0.date >= start && $0.date < end }.sorted { $0.date > $1.date }
    }


    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Today").font(.headline)
                Spacer()
                Button("Open Log") { selectedTab = .log }
            }
            if todayEntries.isEmpty {
                ContentUnavailableView("No entries yet", systemImage: "plus.app", description: Text("Add your first food from the Log tab."))
                .frame(maxWidth: .infinity)
            } else {
                List(todayEntries.prefix(5)) { item in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(item.name).font(.headline)
                            Text("P \(Int(item.protein)) • C \(Int(item.carbs)) • F \(Int(item.fat)) • \(Int(item.calories)) kcal")
                            .font(.caption).foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text(item.date.relativeTime).font(.caption2).foregroundStyle(.secondary)
                    }
                }
                .listStyle(.inset)
                .frame(height: min(CGFloat(todayEntries.count) * 56 + 60, 320))
            }
        }
        .padding(.horizontal)
    }
}
