import SwiftUI

private enum PlannerDefaultsKey {
    static let sex = "planner.sex"
    static let age = "planner.age"
    static let heightFt = "planner.heightFt"
    static let heightIn = "planner.heightIn"
    static let weightLb = "planner.weightLb"
    static let activity = "planner.activity" // ActivityLevel.rawValue (Double)
    static let goal = "planner.goal" // Goal.rawValue (String)
    static let rate = "planner.rateLbPerWeek"
}

struct SmartPlanSheet: View {
    @Environment(\.dismiss) private var dismiss
    private let defaults = UserDefaults.standard

    // inputs (IMPERIAL)
    @State private var sex: SexForFormula = .male
    @State private var age: Int = 30
    @State private var heightFt: Int = 5
    @State private var heightIn: Int = 10
    @State private var weightLb: Double = 170
    @State private var activity: ActivityLevel = .moderate
    @State private var goal: Goal = .cut
    @State private var rateLbPerWeek: Double = 1.0 // 0...2

    // optional advanced baselines (per lb)
    @State private var proteinGPerLb: Double? = nil // default display 0.82 g/lb
    @State private var fatGPerLb: Double? = nil  // default display 0.36 g/lb

    @State private var preview: ComputedPlan?

    let onApply: (ComputedPlan) -> Void
    private let planner = MacroPlanner()

    var body: some View {
        NavigationStack {
            Form {
                Section("Basics") {
                    Picker("Sex (formula)", selection: $sex) {
                        Text("Male").tag(SexForFormula.male)
                        Text("Female").tag(SexForFormula.female)
                    }
                    Stepper(value: $age, in: 13...89) { Text("Age \(age)") }

                    // HEIGHT - feet + inches text fields
                    HStack(spacing: 8) {
                        Text("Height")
                        Spacer()
                        HStack(spacing: 6) {
                            TextField("ft", value: $heightFt, format: .number)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 48)
                            Text("ft").foregroundStyle(.secondary)

                            TextField("in", value: $heightIn, format: .number)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 48)
                                .onChange(of: heightIn) { oldValue, newValue in
                                    var inches = newValue
                                    if inches > 11 {
                                        heightFt += inches / 12
                                        inches = inches % 12
                                    } else if inches < 0 {
                                        inches = 0
                                    }
                                    if inches != newValue {
                                        heightIn = inches
                                    }
                                }
                            Text("in").foregroundStyle(.secondary)
                        }
                    }

                    // WEIGHT - lb text field
                    HStack {
                        Text("Weight")
                        Spacer()
                        TextField("lb", value: $weightLb, format: .number)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.decimalPad)
                            .frame(width: 80)
                        Text("lb").foregroundStyle(.secondary)
                    }
                }

                Section("Activity") {
                    Picker("Level", selection: $activity) {
                        ForEach(ActivityLevel.allCases, id: \.self) { Text($0.label).tag($0) }
                    }
                }

                Section("Goal") {
                    Picker("Direction", selection: $goal) {
                        Text("Lose").tag(Goal.cut)
                        Text("Maintain").tag(Goal.maintain)
                        Text("Gain").tag(Goal.gain)
                    }
                    .pickerStyle(.segmented)

                    if goal != .maintain {
                        Stepper(value: $rateLbPerWeek, in: 0...2, step: 0.5) {
                            Text("Rate: \(rateLbPerWeek, specifier: "%.1f") lb/week")
                        }
                    } else {
                        Text("Rate: 0.0 lb/week").foregroundStyle(.secondary)
                    }
                }

                DisclosureGroup("Advanced baselines (per lb)") {
                    Stepper(value: $proteinGPerLb.withDefault(0.82), in: 0.60...1.20, step: 0.05) {
                        Text("Protein \(proteinGPerLb ?? 0.82, specifier: "%.2f") g/lb")
                    }
                    Stepper(value: $fatGPerLb.withDefault(0.36), in: 0.27...0.55, step: 0.02) {
                        Text("Fat \(fatGPerLb ?? 0.36, specifier: "%.2f") g/lb")
                    }
                    Text("Defaults ≈ 0.82 g/lb protein, 0.36 g/lb fat.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                if let p = preview {
                    PlanPreviewCard(plan: p)

                    // modify inputs
                    Button {
                        preview = nil
                    } label: {
                        Label("Change inputs", systemImage: "arrow.uturn.left")
                    }

                    Button {
                        // save defaults and apply
                        saveDefaults()
                        onApply(p)
                        dismiss()
                    } label: {
                        Label("Apply & save", systemImage: "checkmark.circle.fill")
                    }
                    .buttonStyle(.borderedProminent)
                } else {
                    Button {
                        preview = computePlan()
                        saveDefaults() // persist fields after creating the preview
                    } label: {
                        Label("Compute plan", systemImage: "wand.and.stars")
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .navigationTitle("Smart Plan")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Close") { dismiss() } }
            }
            .onAppear { loadDefaults() }
        }
    }

    // MARK: - Compute (imperial to metric)

    private func computePlan() -> ComputedPlan {
        let heightCm = Double(heightFt * 12 + max(heightIn, 0)) * 2.54
        let weightKg = weightLb * 0.453_592_37

        let proteinPerKg = proteinGPerLb.map { $0 * 2.204_622_62 }
        let fatPerKg = fatGPerLb.map { $0 * 2.204_622_62 }

        let sign: Double = (goal == .cut ? -1 : (goal == .gain ? 1 : 0))
        let kcalPerDayDelta = sign * rateLbPerWeek * 3500.0 / 7.0 // roughly 500 kcal per 1 lb/week

        let profile = UserProfile(
            heightCm: heightCm,
            weightKg: weightKg,
            age: age,
            sexForFormula: sex,
            activity: activity
        )

        let opts = MacroPlanner.Options(
            goal: goal,
            dailyCalorieDelta: kcalPerDayDelta,
            proteinGPerKg: proteinPerKg,
            fatGPerKg: fatPerKg
        )

        return planner.makePlan(for: profile, options: opts)
    }

    // MARK: - Persist / Restore

    private func saveDefaults() {
        defaults.set(sex.rawValue, forKey: PlannerDefaultsKey.sex)
        defaults.set(age, forKey: PlannerDefaultsKey.age)
        defaults.set(heightFt, forKey: PlannerDefaultsKey.heightFt)
        defaults.set(heightIn, forKey: PlannerDefaultsKey.heightIn)
        defaults.set(weightLb, forKey: PlannerDefaultsKey.weightLb)
        defaults.set(activity.rawValue, forKey: PlannerDefaultsKey.activity)
        defaults.set(goal.rawValue, forKey: PlannerDefaultsKey.goal)
        defaults.set(rateLbPerWeek, forKey: PlannerDefaultsKey.rate)
    }

    private func loadDefaults() {
        if let raw = defaults.string(forKey: PlannerDefaultsKey.sex), let s = SexForFormula(rawValue: raw) {
            sex = s
        }
        
        let a = defaults.integer(forKey: PlannerDefaultsKey.age)
        
        if a != 0 {
            age = a
        } // 0 means 'not set'
        
        let ft = defaults.integer(forKey: PlannerDefaultsKey.heightFt)
        if ft != 0 {
            heightFt = ft
        }
        
        let inch = defaults.integer(forKey: PlannerDefaultsKey.heightIn)
        
        if inch != 0 {
            heightIn = inch
        }
        
        let w = defaults.double(forKey: PlannerDefaultsKey.weightLb)
        
        if w != 0 {
            weightLb = w
        }
        
        let act = defaults.double(forKey: PlannerDefaultsKey.activity)
        
        if let lvl = ActivityLevel(rawValue: act) {
            activity = lvl
        }
        
        if let g = defaults.string(forKey: PlannerDefaultsKey.goal), let gg = Goal(rawValue: g) {
            goal = gg
        }
        
        let r = defaults.double(forKey: PlannerDefaultsKey.rate)
        
        if r != 0 {
            rateLbPerWeek = r
        }
    }
}
