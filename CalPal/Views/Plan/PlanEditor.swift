import SwiftUI
import SwiftData


struct PlanEditor: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Query private var plans: [MacroPlan]

    @State private var protein: Double = 150
    @State private var carbs: Double = 200
    @State private var fat: Double = 60
    @State private var initialized = false

    var body: some View {
        Form {
            Section("Daily Targets") {
                Stepper(value: $protein, in: 0...400, step: 5) { row("Protein", Int(protein), unit: "g") }
                Stepper(value: $carbs, in: 0...600, step: 5) { row("Carbs",   Int(carbs),   unit: "g") }
                Stepper(value: $fat,   in: 0...250, step: 1) { row("Fat",     Int(fat),     unit: "g") }
                HStack {
                    Text("Calories"); Spacer()
                    Text("\(Int(protein * 4 + carbs * 4 + fat * 9)) kcal").foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Macro Plan")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) { Button("Save") { save() } }
        }
        .onAppear {
            guard !initialized else { return }
            if let plan = plans.first {
                protein = plan.proteinTarget
                carbs   = plan.carbTarget
                fat     = plan.fatTarget
            }
            initialized = true
        }
    }

    private func save() {
        if let plan = plans.first {
            plan.proteinTarget = protein
            plan.carbTarget = carbs
            plan.fatTarget   = fat
            plan.calorieTarget = protein * 4 + carbs * 4 + fat * 9
        } else {
            context.insert(MacroPlan(proteinTarget: protein, carbTarget: carbs, fatTarget: fat))
        }
        try? context.save(); dismiss()
    }

    private func row(_ title: String, _ value: Int, unit: String) -> some View {
        HStack { Text(title); Spacer(); Text("\(value) \(unit)") }
    }
}

