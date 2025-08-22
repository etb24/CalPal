import Foundation

struct MacroPlanner {

    struct Options {
        var goal: Goal
        // daily kcal change from the goal rate
        var dailyCalorieDelta: Double
        // optional overrides (g per kg bodyweight) if null defaults are used
        var proteinGPerKg: Double?
        var fatGPerKg: Double?
    }

    // MARK: - Public
    func makePlan(for profile: UserProfile, options: Options) -> ComputedPlan {
        let bmr = mifflinStJeorBMR(weightKg: profile.weightKg, heightCm: profile.heightCm, age: profile.age, sex: profile.sexForFormula)
        let tdee = bmr * profile.activity.rawValue
        var calories = Int(round(tdee + options.dailyCalorieDelta))

        let proteinG = proteinTarget(profile: profile, goal: options.goal, overridePerKg: options.proteinGPerKg)
        var fatG     = fatTarget(profile: profile, overridePerKg: options.fatGPerKg)
        var carbsG   = Int(round((Double(calories) - 4.0*Double(proteinG) - 9.0*Double(fatG)) / 4.0))

        // guardrails: keep fat >= 0.6 g/kg, no negative carbs, raise kcal if macros exceed kcal
        if carbsG < 0 {
            let minFat = Int(round(0.6 * profile.weightKg))
            if fatG > minFat {
                let delta = min(fatG - minFat, (abs(carbsG) * 4) / 9 + 1)
                fatG -= delta
                carbsG = Int(round((Double(calories) - 4.0*Double(proteinG) - 9.0*Double(fatG)) / 4.0))
            }
            carbsG = max(0, carbsG)
        }

        let macroCals = 4*proteinG + 9*fatG + 4*carbsG
        if macroCals > calories { calories = macroCals }

        return ComputedPlan(
            calories: calories,
            proteinG: round5(proteinG),
            carbsG:   round5(carbsG),
            fatG:     round5(fatG)
        )
    }

    // MARK: - BMR (Mifflin–St Jeor)
    private func mifflinStJeorBMR(weightKg: Double, heightCm: Double, age: Int, sex: SexForFormula) -> Double {
        let s = (sex == .male) ? 5.0 : -161.0
        return 10.0*weightKg + 6.25*heightCm - 5.0*Double(age) + s
    }

    // MARK: - Macro targets
    private func proteinTarget(profile: UserProfile, goal: Goal, overridePerKg: Double?) -> Int {
        if let perKg = overridePerKg {
            return Int(round(perKg * profile.weightKg))
        }
        // slightly higher default on cuts cap at 2.2 g/kg BW
        let perKgDefault = (goal == .cut) ? 2.0 : 1.8
        let grams = min(2.2, perKgDefault) * profile.weightKg
        return Int(round(grams))
    }

    private func fatTarget(profile: UserProfile, overridePerKg: Double?) -> Int {
        let perKg = overridePerKg ?? 0.8
        let grams = max(0.6 * profile.weightKg, perKg * profile.weightKg) // >= 0.6 g/kg
        return Int(round(grams))
    }

    private func round5(_ x: Int) -> Int {
        Int(round(Double(x) / 5.0) * 5.0)
    }
}
