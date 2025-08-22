import SwiftUI

struct PlanPreviewCard: View {
    let plan: ComputedPlan

    var body: some View {
        let pPct = Int(round(Double(plan.proteinG) * 4.0 / Double(plan.calories) * 100))
        let cPct = Int(round(Double(plan.carbsG) * 4.0 / Double(plan.calories) * 100))
        let fPct = Int(round(Double(plan.fatG) * 9.0 / Double(plan.calories) * 100))

        VStack(alignment: .leading, spacing: 8) {
            Text("Your Plan").font(.headline)
            Text("\(plan.calories) kcal/day")
            VStack(alignment: .leading, spacing: 4) {
                Text("Protein: \(plan.proteinG) g • \(pPct)%")
                Text("Carbs: \(plan.carbsG) g • \(cPct)%")
                Text("Fat: \(plan.fatG) g • \(fPct)%")
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}
