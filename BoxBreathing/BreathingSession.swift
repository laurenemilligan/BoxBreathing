import Foundation
import WatchKit

enum BreathingPhase: Int, CaseIterable {
    case inhale, holdIn, exhale, holdOut

    var title: String {
        switch self {
        case .inhale: "Inhale"
        case .holdIn: "Hold in"
        case .exhale: "Exhale"
        case .holdOut: "Hold out"
        }
    }
}

@MainActor
final class BreathingSession: ObservableObject {
    @Published private(set) var isActive = false
    @Published private(set) var isPaused = false
    @Published private(set) var phase: BreathingPhase = .inhale
    @Published private(set) var phaseRemaining = 4
    @Published private(set) var remaining = 0
    @Published private(set) var phaseProgress = 0.0

    private var durations = [4, 4, 4, 4]
    private var totalSeconds = 0.0
    private var startUptime = 0.0
    private var pausedElapsed = 0.0
    private var lastPhaseNumber = 0
    private var timer: Timer?
    private let runtime = ExtendedSessionManager()

    func start(minutes: Int, durations: [Int]) {
        guard !isActive, durations.count == 4 else { return }
        self.durations = durations.map { max(1, $0) }
        totalSeconds = Double(minutes * 60)
        startUptime = ProcessInfo.processInfo.systemUptime
        pausedElapsed = 0
        lastPhaseNumber = 0
        phase = .inhale
        isActive = true
        isPaused = false
        runtime.start { [weak self] in self?.end() }
        HapticCue.play(for: .inhale)
        tick()
        scheduleTimer()
    }

    func pause() {
        guard isActive, !isPaused else { return }
        pausedElapsed = ProcessInfo.processInfo.systemUptime - startUptime
        isPaused = true
        timer?.invalidate()
        timer = nil
    }

    func resume() {
        guard isActive, isPaused else { return }
        startUptime = ProcessInfo.processInfo.systemUptime - pausedElapsed
        isPaused = false
        HapticCue.play(for: phase)
        tick()
        scheduleTimer()
    }

    func end() {
        guard isActive else { return }
        timer?.invalidate()
        timer = nil
        runtime.stop()
        isActive = false
        isPaused = false
    }

    private func scheduleTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.tick() }
        }
    }

    private func tick() {
        guard isActive, !isPaused else { return }
        let elapsed = min(totalSeconds, ProcessInfo.processInfo.systemUptime - startUptime)
        remaining = max(0, Int(ceil(totalSeconds - elapsed)))
        if elapsed >= totalSeconds {
            end()
            WKInterfaceDevice.current().play(.success)
            return
        }

        let cycle = durations.reduce(0, +)
        let cycleNumber = Int(elapsed) / cycle
        let cycleElapsed = elapsed.truncatingRemainder(dividingBy: Double(cycle))
        var boundary = 0.0
        for candidate in BreathingPhase.allCases {
            let duration = Double(durations[candidate.rawValue])
            if cycleElapsed < boundary + duration {
                let phaseNumber = cycleNumber * 4 + candidate.rawValue
                if phaseNumber != lastPhaseNumber {
                    lastPhaseNumber = phaseNumber
                    HapticCue.play(for: candidate)
                }
                phase = candidate
                phaseRemaining = Int(ceil(boundary + duration - cycleElapsed))
                phaseProgress = (cycleElapsed - boundary) / duration
                break
            }
            boundary += duration
        }
    }
}
