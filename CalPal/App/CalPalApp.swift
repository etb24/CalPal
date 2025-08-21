import SwiftUI
import SwiftData


@main
struct CalPalApp: App {
    var body: some Scene {
        WindowGroup { RootView() }
            .modelContainer(for: [MacroPlan.self, FoodEntry.self])
    }
}
