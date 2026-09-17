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

enum SessionStage {
    case ready, settlingBefore, breathing, settlingAfter, finishing, complete
}

@MainActor
final class BreathingSession: ObservableObject {
    @Published private(set) var isActive = false
    @Published private(set) var isPaused = false
    @Published private(set) var phase: BreathingPhase = .inhale
    @Published private(set) var phaseRemaining = 4
    @Published private(set) var remaining = 0
    @Published private(set) var phaseProgress = 0.0
    @Published private(set) var stage: SessionStage = .ready
    @Published private(set) var comparison: HeartRateComparison?
    @Published private(set) var errorMessage: String?
    @Published private(set) var stageRemaining = 30

    private var durations = [4, 4, 4, 4]
    private var totalSeconds = 0.0
    private var startUptime = 0.0
    private var pausedElapsed = 0.0
    private var lastPhaseNumber = 0
    private var timer: Timer?
    private var workout: HeartRateWorkout?
    private var stageStartUptime = 0.0
    private let settlingSeconds = 30.0

    func start(minutes: Int, durations: [Int]) {
        guard stage == .ready, durations.count == 4 else { return }
        errorMessage = nil
        comparison = nil
        self.durations = durations.map { max(1, $0) }
        totalSeconds = Double(minutes * 60)
        pausedElapsed = 0
        lastPhaseNumber = 0
        phase = .inhale
        stage = .finishing
        let workout = HeartRateWorkout()
        self.workout = workout
        workout.onUnexpectedEnd = { [weak self] in
            guard let self, self.isActive, self.stage != .finishing else { return }
            self.errorMessage = "The workout ended unexpectedly."
            self.end()
        }
        workout.start { [weak self] error in
            guard let self else { return }
            if let error {
                self.errorMessage = error.localizedDescription
                self.stage = .ready
                self.workout = nil
                return
            }
            self.isActive = true
            self.isPaused = false
            self.stage = .settlingBefore
            self.stageStartUptime = ProcessInfo.processInfo.systemUptime
            self.stageRemaining = Int(self.settlingSeconds)
            self.scheduleTimer()
        }
    }

    func pause() {
        guard isActive, !isPaused else { return }
        pausedElapsed = ProcessInfo.processInfo.systemUptime
        isPaused = true
        timer?.invalidate()
        timer = nil
    }

    func resume() {
        guard isActive, isPaused else { return }
        let pauseLength = ProcessInfo.processInfo.systemUptime - pausedElapsed
        startUptime += pauseLength
        stageStartUptime += pauseLength
        isPaused = false
        if stage == .breathing { HapticCue.play(for: phase) }
        tick()
        scheduleTimer()
    }

    func end() {
        guard isActive else { return }
        timer?.invalidate()
        timer = nil
        isActive = false
        isPaused = false
        stage = .finishing
        workout?.onUnexpectedEnd = nil
        workout?.finish { [weak self] result in
            self?.comparison = result
            self?.stage = .complete
            self?.workout = nil
        }
    }

    func reset() {
        guard !isActive else { return }
        stage = .ready
        comparison = nil
        errorMessage = nil
    }

    private func scheduleTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.tick() }
        }
    }

    private func tick() {
        guard isActive, !isPaused else { return }
        if stage == .settlingBefore || stage == .settlingAfter {
            let elapsed = ProcessInfo.processInfo.systemUptime - stageStartUptime
            stageRemaining = max(0, Int(ceil(settlingSeconds - elapsed)))
            if elapsed >= settlingSeconds {
                if stage == .settlingBefore {
                    workout?.markBeforeEnd()
                    stage = .breathing
                    startUptime = ProcessInfo.processInfo.systemUptime
                    HapticCue.play(for: .inhale)
                } else {
                    end()
                    WKInterfaceDevice.current().play(.success)
                }
            }
            return
        }
        guard stage == .breathing else { return }
        let elapsed = min(totalSeconds, ProcessInfo.processInfo.systemUptime - startUptime)
        remaining = max(0, Int(ceil(totalSeconds - elapsed)))
        if elapsed >= totalSeconds {
            stage = .settlingAfter
            stageStartUptime = ProcessInfo.processInfo.systemUptime
            stageRemaining = Int(settlingSeconds)
            workout?.markAfterStart()
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
