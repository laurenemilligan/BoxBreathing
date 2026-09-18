import Foundation
import WatchKit

enum HapticCue: String, CaseIterable, Identifiable {
    case directionUp, directionDown, start, stop, click, success, retry, notification

    var id: String { rawValue }

    var title: String {
        switch self {
        case .directionUp: "Up"
        case .directionDown: "Down"
        case .start: "Start"
        case .stop: "Stop"
        case .click: "Click"
        case .success: "Success"
        case .retry: "Retry"
        case .notification: "Notification"
        }
    }

    var watchType: WKHapticType {
        switch self {
        case .directionUp: .directionUp
        case .directionDown: .directionDown
        case .start: .start
        case .stop: .stop
        case .click: .click
        case .success: .success
        case .retry: .retry
        case .notification: .notification
        }
    }

    static func play(for phase: BreathingPhase) {
        let style = UserDefaults.standard.string(forKey: "hapticStyle") ?? "flow"
        guard style != "off" else { return }
        if style == "flow" {
            let type: WKHapticType = switch phase {
            case .inhale: .directionUp
            case .exhale: .directionDown
            case .holdIn, .holdOut: .click
            }
            WKInterfaceDevice.current().play(type)
            return
        }
        let defaults = ["directionUp", "start", "directionDown", "stop"]
        let key = "cue_\(phase.rawValue)"
        let saved = UserDefaults.standard.string(forKey: key) ?? defaults[phase.rawValue]
        let cue = HapticCue(rawValue: saved) ?? .click
        WKInterfaceDevice.current().play(cue.watchType)
    }

    static func playFlowPulse(for phase: BreathingPhase, progress: Double, lastPulse: inout Int) {
        let style = UserDefaults.standard.string(forKey: "hapticStyle") ?? "flow"
        guard style == "flow" else { return }
        let thresholds: [Double] = switch phase {
        case .inhale: [0.48, 0.82]
        case .exhale: [0.20, 0.54]
        case .holdIn, .holdOut: []
        }
        guard lastPulse < thresholds.count, progress >= thresholds[lastPulse] else { return }
        lastPulse = thresholds.lastIndex(where: { progress >= $0 })! + 1
        WKInterfaceDevice.current().play(.click)
    }
}
