import Foundation
import SwiftData


@Model
final class FoodEntry {
    var name: String
    var protein: Double
    var carbs: Double
    var fat: Double
    var calories: Double
    var date: Date


    init(name: String, protein: Double, carbs: Double, fat: Double, date: Date = .now) {
        self.name = name
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        self.calories = protein * 4 + carbs * 4 + fat * 9
        self.date = date
    }
}
