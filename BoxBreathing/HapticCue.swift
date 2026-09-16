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
        let defaults = ["directionUp", "start", "directionDown", "stop"]
        let key = "cue_\(phase.rawValue)"
        let saved = UserDefaults.standard.string(forKey: key) ?? defaults[phase.rawValue]
        let cue = HapticCue(rawValue: saved) ?? .click
        WKInterfaceDevice.current().play(cue.watchType)
    }
}
