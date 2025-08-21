import SwiftUI


struct MacroRing: View {
    let title: String
    let value: Double // 0...1
    let current: Double
    let target: Double
    let unit: String
    let systemImage: String


    var body: some View {
        VStack(spacing: 8) {
            Gauge(value: value) { } currentValueLabel: { Text("\(Int(current))") }
            .gaugeStyle(.accessoryCircularCapacity)
            .frame(width: 90, height: 90)
            VStack(spacing: 2) {
                Label(title, systemImage: systemImage).font(.subheadline)
                Text("Target: \(Int(target)) \(unit)").font(.caption).foregroundStyle(.secondary)
            }
        }
        .padding(10)
        .background(.ultraThinMaterial, in: .rect(cornerRadius: 16))
    }
}
