import Foundation

enum SexForFormula: String, CaseIterable {
    case male, female
}

enum Goal: String, CaseIterable {
    case cut, maintain, gain, recomp
    var title: String { rawValue.capitalized }
}

enum ActivityLevel: Double, CaseIterable {
    case sedentary  = 1.20
    case light = 1.375
    case moderate = 1.55
    case active = 1.725
    case veryActive = 1.90

    var label: String {
        switch self {
        case .sedentary: return "Sedentary (little/no exercise)"
        case .light: return "Light (1–3x/wk)"
        case .moderate: return "Moderate (3–5x/wk)"
        case .active: return "Active (6–7x/wk)"
        case .veryActive: return "Very Active (hard daily/2x day)"
        }
    }
}
