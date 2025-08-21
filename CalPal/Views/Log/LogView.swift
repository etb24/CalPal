import SwiftUI
import SwiftData


struct LogView: View {
    @Environment(\.modelContext) private var context
    @Query private var entries: [FoodEntry]
    @State private var showingAdd = false


    private var todayEntries: [FoodEntry] {
        let (start, end) = Date.now.dayBounds
        return entries.filter { $0.date >= start && $0.date < end }.sorted { $0.date > $1.date }
    }


    var body: some View {
        NavigationStack {
            List {
                Section {
                    if todayEntries.isEmpty { ContentUnavailableView("Nothing logged today", systemImage: "tray") }
                    ForEach(todayEntries) { item in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(item.name).font(.headline)
                                Spacer()
                                Text(item.date.formatted(date: .omitted, time: .shortened))
                                .font(.caption).foregroundStyle(.secondary)
                            }
                            Text("P \(Int(item.protein)) • C \(Int(item.carbs)) • F \(Int(item.fat)) • \(Int(item.calories)) kcal")
                            .font(.caption).foregroundStyle(.secondary)
                        }
                    }
                    .onDelete { indexSet in
                        for index in indexSet { context.delete(todayEntries[index]) }
                        try? context.save()
                    }
                }
            }
            .navigationTitle("Log")
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button { showingAdd = true } label: { Label("Add", systemImage: "plus.circle.fill") } } }
            .sheet(isPresented: $showingAdd) { AddEntrySheet() }
        }
    }
}
