import SwiftUI
import WatchKit

struct HapticLabView: View {
    @StateObject private var previewer = HapticPreviewer()

    var body: some View {
        List {
            Section("Flow rhythm") {
                Button("Feel inhale") { previewer.preview(.inhale) }
                Button("Feel exhale") { previewer.preview(.exhale) }
                Button("Feel hold") { previewer.preview(.holdIn) }
            }
            Section("Classic cues") {
                ForEach(HapticCue.allCases) { cue in
                    Button(cue.title) {
                        previewer.cancel()
                        WKInterfaceDevice.current().play(cue.watchType)
                    }
                }
            }
        }
        .navigationTitle("Try the cues")
        .onDisappear { previewer.cancel() }
    }
}

@MainActor
private final class HapticPreviewer: ObservableObject {
    private var previewTask: Task<Void, Never>?

    func cancel() { previewTask?.cancel() }

    func preview(_ phase: BreathingPhase) {
        cancel()
        previewTask = Task {
            let first: WKHapticType = switch phase {
            case .inhale: .directionUp
            case .exhale: .directionDown
            case .holdIn, .holdOut: .click
            }
            WKInterfaceDevice.current().play(first)
            guard phase == .inhale || phase == .exhale else { return }
            let seconds = phase == .inhale ? [1.9, 3.3] : [0.8, 2.2]
            var previous = 0.0
            for second in seconds {
                try? await Task.sleep(nanoseconds: UInt64((second - previous) * 1_000_000_000))
                guard !Task.isCancelled else { return }
                WKInterfaceDevice.current().play(.click)
                previous = second
            }
        }
    }
}
