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
            if session.isActive {
                SessionView(session: session)
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        Image(systemName: "circle.dotted.circle")
                            .font(.system(size: 32))
                            .foregroundStyle(.mint)
                        Text("Box Breathing")
                            .font(.headline)
                        Text("Follow four cues on your wrist")
                            .font(.caption)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)
                        Picker("Length", selection: $sessionMinutes) {
                            ForEach([1, 3, 5, 10], id: \.self) { minutes in
                                Text("\(minutes) min").tag(minutes)
                            }
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
