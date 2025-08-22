import SwiftUI

extension Binding where Value == Double? {
    func withDefault(_ defaultValue: Double) -> Binding<Double> {
        Binding<Double>(
            get: { self.wrappedValue ?? defaultValue },
            set: { self.wrappedValue = $0 }
        )
    }
}
