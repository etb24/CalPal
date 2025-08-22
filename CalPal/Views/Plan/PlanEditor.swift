import SwiftUI
import SwiftData


struct PlanEditor: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Query private var plans: [MacroPlan]

    // parent can decide where to go after save (e.g., set tab to .dashboard and close sheet)
    var onSavedNavigate: (() -> Void)? = nil

    @State private var protein: Double = 150
    @State private var carbs: Double = 200
    @State private var fat: Double = 60
    @State private var initialized = false

    @State private var showSmartPlan = false
    private var calories: Int { Int(protein * 4 + carbs * 4 + fat * 9) }

    var body: some View {
        Form {
            Section("Daily Targets") {
                Stepper(value: $protein, in: 0...400, step: 5) { row("Protein", Int(protein), unit: "g") }
                Stepper(value: $carbs, in: 0...600, step: 5) { row("Carbs", Int(carbs), unit: "g") }
                Stepper(value: $fat, in: 0...250, step: 1) { row("Fat", Int(fat), unit: "g") }
                HStack {
                    Text("Calories"); Spacer()
                    Text("\(calories) kcal").foregroundStyle(.secondary)
                }
            }

            Section {
                Button { showSmartPlan = true } label: {
                    Label("Generate plan for me", systemImage: "wand.and.stars")
                }
            } footer: {
                Text("Use your stats to auto-calculate calories and P/C/F.")
            }
        }
        .navigationTitle("Macro Plan")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) { Button("Save") { saveAndExit() } }
        }
        .onAppear {
            guard !initialized else { return }
            if let plan = plans.first {
                protein = plan.proteinTarget
                carbs = plan.carbTarget
                fat = plan.fatTarget
            }
            initialized = true
        }
        .sheet(isPresented: $showSmartPlan) {
            SmartPlanSheet { generated in
                // apply to editor and persist immediately, then exit via callback
                applyAndPersist(from: generated)
                finishAndExit()
            }
            .presentationDetents([.medium, .large])
        }
    }

    // MARK: - Persistence & Exit

    private func applyAndPersist(from p: ComputedPlan) {
        protein = Double(p.proteinG)
        carbs = Double(p.carbsG)
        fat = Double(p.fatG)
        persistCurrentValues()
    }

    private func saveAndExit() {
        persistCurrentValues()
        finishAndExit()
    }

    private func persistCurrentValues() {
        if let plan = plans.first {
            plan.proteinTarget = protein
            plan.carbTarget = carbs
            plan.fatTarget = fat
            plan.calorieTarget = Double(calories)
        } else {
            context.insert(MacroPlan(proteinTarget: protein, carbTarget: carbs, fatTarget: fat))
        }
        try? context.save()
    }

    private func finishAndExit() {
        if let cb = onSavedNavigate {
            cb() // parent (RootView) will close sheet & set tab
        } else {
            dismiss() // fallback if no callback supplied
        }
    }

    private func row(_ title: String, _ value: Int, unit: String) -> some View {
        HStack { Text(title); Spacer(); Text("\(value) \(unit)") }
    }
}
