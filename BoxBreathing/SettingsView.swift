import SwiftUI

struct SettingsView: View {
    @AppStorage("hapticStyle") private var hapticStyle = "flow"
    @AppStorage("inhaleSeconds") private var inhaleSeconds = 4
    @AppStorage("holdInSeconds") private var holdInSeconds = 4
    @AppStorage("exhaleSeconds") private var exhaleSeconds = 4
    @AppStorage("holdOutSeconds") private var holdOutSeconds = 4
    @AppStorage("cue_0") private var inhaleCue = "directionUp"
    @AppStorage("cue_1") private var holdInCue = "start"
    @AppStorage("cue_2") private var exhaleCue = "directionDown"
    @AppStorage("cue_3") private var holdOutCue = "stop"

    var body: some View {
        Form {
            Section("Feel") {
                Picker("Haptics", selection: $hapticStyle) {
                    Text("Flow").tag("flow")
                    Text("Classic").tag("classic")
                    Text("Off").tag("off")
                }
                Text(hapticDescription)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                NavigationLink("Try the cues") { HapticLabView() }
            }
            Section("Seconds per phase") {
                Stepper("Inhale: \(inhaleSeconds)", value: $inhaleSeconds, in: 2...10)
                Stepper("Hold in: \(holdInSeconds)", value: $holdInSeconds, in: 2...10)
                Stepper("Exhale: \(exhaleSeconds)", value: $exhaleSeconds, in: 2...10)
                Stepper("Hold out: \(holdOutSeconds)", value: $holdOutSeconds, in: 2...10)
            }
            if hapticStyle == "classic" {
                Section("Classic cues") {
                    cuePicker("Inhale", selection: $inhaleCue)
                    cuePicker("Hold in", selection: $holdInCue)
                    cuePicker("Exhale", selection: $exhaleCue)
                    cuePicker("Hold out", selection: $holdOutCue)
                }
            }
        }
        .navigationTitle("Preferences")
    }

    private var hapticDescription: String {
        switch hapticStyle {
        case "flow": "Rising and falling taps for breaths. One tap for holds."
        case "classic": "One chosen cue at each phase change."
        default: "Breathing stays visual and quiet."
        }
    }

    private func cuePicker(_ title: String, selection: Binding<String>) -> some View {
        Picker(title, selection: selection) {
            ForEach(HapticCue.allCases) { cue in
                Text(cue.title).tag(cue.rawValue)
            }
        }
    }
}
