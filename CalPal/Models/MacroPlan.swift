import Foundation
import SwiftData


@Model
final class MacroPlan {
    var proteinTarget: Double
    var carbTarget: Double
    var fatTarget: Double
    var calorieTarget: Double


    init(proteinTarget: Double = 150, carbTarget: Double = 200, fatTarget: Double = 60) {
        self.proteinTarget = proteinTarget
        self.carbTarget = carbTarget
        self.fatTarget = fatTarget
        self.calorieTarget = proteinTarget * 4 + carbTarget * 4 + fatTarget * 9
    }
}
