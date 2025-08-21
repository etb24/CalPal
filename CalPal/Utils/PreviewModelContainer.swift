import SwiftUI
import SwiftData


enum PreviewHelper {
    static func inMemoryContainer() -> ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        return try! ModelContainer(for: MacroPlan.self, FoodEntry.self, configurations: config)
    }
}
