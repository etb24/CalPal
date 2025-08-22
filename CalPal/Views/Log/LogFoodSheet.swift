import SwiftUI
import SwiftData


struct LogFoodSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context


    @State private var name: String = ""
    @State private var protein: Double = 0
    @State private var carbs: Double = 0
    @State private var fat: Double = 0


    private var calories: Double { protein * 4 + carbs * 4 + fat * 9 }


    var body: some View {
        NavigationStack {
            Form {
                Section("Food") { TextField("Name (e.g. Chicken breast)", text: $name) }
                Section("Macros (grams)") {
                    Stepper(value: $protein, in: 0...500, step: 1) { row("Protein", Int(protein), unit: "g") }
                    Stepper(value: $carbs, in: 0...500, step: 1) { row("Carbs", Int(carbs), unit: "g") }
                    Stepper(value: $fat, in: 0...300, step: 1) { row("Fat", Int(fat), unit: "g") }
                }
                Section("Summary") { row("Calories", Int(calories), unit: "kcal") }
            }
            .navigationTitle("Quick Add")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        context.insert(FoodEntry(name: name.isEmpty ? "Food" : name, protein: protein, carbs: carbs, fat: fat))
                        try? context.save(); dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && protein + carbs + fat == 0)
                }
            }
        }
    }


    private func row(_ title: String, _ value: Int, unit: String) -> some View {
        HStack { Text(title); Spacer(); Text("\(value) \(unit)") }
    }
}
