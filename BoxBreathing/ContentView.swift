import SwiftUI

struct ContentView: View {
    @AppStorage("sessionMinutes") private var sessionMinutes = 3
    @AppStorage("inhaleSeconds") private var inhaleSeconds = 4
    @AppStorage("holdInSeconds") private var holdInSeconds = 4
    @AppStorage("exhaleSeconds") private var exhaleSeconds = 4
    @AppStorage("holdOutSeconds") private var holdOutSeconds = 4
    @StateObject private var session = BreathingSession()

    var body: some View {
        NavigationStack {
            if session.isActive || session.stage == .finishing {
                SessionView(session: session)
            } else if session.stage == .complete {
                ScrollView {
                    VStack(spacing: 10) {
                        Text("Session complete").font(.headline)
                        if let comparison = session.comparison {
                            Text("Before: \(comparison.before.map(String.init) ?? "—") bpm")
                            Text("After: \(comparison.after.map(String.init) ?? "—") bpm")
                            if let before = comparison.before, let after = comparison.after {
                                Text("Change: \(after - before > 0 ? "+" : "")\(after - before) bpm")
                                    .foregroundStyle(.mint)
                            } else {
                                Text("A reading was unavailable in one of the quiet periods.")
                                    .font(.caption).foregroundStyle(.secondary)
                            }
                            Text(comparison.saved ? "Workout saved to Health" : "Workout could not be saved")
                                .font(.caption).foregroundStyle(.secondary)
                        }
                        Button("Done") { session.reset() }
                            .buttonStyle(.borderedProminent)
                    }
                    .frame(maxWidth: .infinity)
                }
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        Image(systemName: "circle.dotted.circle")
                            .font(.system(size: 32))
                            .foregroundStyle(.mint)
                        Text("Box Breathing")
                            .font(.headline)
                        Text("Breathe, then compare heart rate")
                            .font(.caption)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)
                        Picker("Length", selection: $sessionMinutes) {
                            ForEach([1, 3, 5, 10], id: \.self) { minutes in
                                Text("\(minutes) min").tag(minutes)
                            }
                        }
                        Text("30 seconds of stillness before and after. Saves a Mind & Body workout.")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                        if let error = session.errorMessage {
                            Text(error).font(.caption).foregroundStyle(.red)
                        }
                        Button("Start") {
                            session.start(minutes: sessionMinutes,
                                durations: [inhaleSeconds, holdInSeconds, exhaleSeconds, holdOutSeconds])
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.mint)
                        NavigationLink("Timing & cues") { SettingsView() }
                        NavigationLink("Haptic Lab") { HapticLabView() }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 8)
                }
            }
        }
    }
}
