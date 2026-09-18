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
            Group {
                if session.isActive || session.stage == .finishing {
                    SessionView(session: session)
                } else if session.stage == .complete {
                    completionView
                } else {
                    homeView
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppTheme.background.ignoresSafeArea())
        }
        .tint(AppTheme.peach)
    }

    private var homeView: some View {
        ScrollView {
            VStack(spacing: 9) {
                ZStack {
                    Circle().fill(AppTheme.peach.opacity(0.13))
                        .frame(width: 70, height: 70)
                    Circle().fill(
                        LinearGradient(colors: [AppTheme.cream, AppTheme.peach],
                                       startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .frame(width: 52, height: 52)
                }
                .accessibilityHidden(true)

                Text("Box Breathing")
                    .font(.system(.headline, design: .rounded, weight: .semibold))
                    .foregroundStyle(AppTheme.cream)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Text("A small pause for yourself")
                    .font(.caption)
                    .foregroundStyle(AppTheme.muted)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                Button("Begin") {
                    session.start(minutes: sessionMinutes,
                                  durations: [inhaleSeconds, holdInSeconds, exhaleSeconds, holdOutSeconds])
                }
                .buttonStyle(.borderedProminent)
                .tint(AppTheme.peach)
                .foregroundStyle(AppTheme.background)

                Picker("Breathing time", selection: $sessionMinutes) {
                    ForEach([1, 3, 5, 10], id: \.self) { minutes in
                        Text("\(minutes) min").tag(minutes)
                    }
                }
                .font(.caption)

                NavigationLink("Preferences") { SettingsView() }
                    .font(.caption)

                Text("30s before + after · saves a workout")
                    .font(.caption2)
                    .foregroundStyle(AppTheme.muted)
                    .multilineTextAlignment(.center)

                if let error = session.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 6)
        }
    }

    private var completionView: some View {
        ScrollView {
            VStack(spacing: 9) {
                Image(systemName: "heart.fill")
                    .font(.title3)
                    .foregroundStyle(AppTheme.peach)
                Text("Well done")
                    .font(.system(.headline, design: .rounded))
                    .foregroundStyle(AppTheme.cream)
                if let comparison = session.comparison {
                    HStack(spacing: 12) {
                        reading("Before", value: comparison.before)
                        reading("After", value: comparison.after)
                    }
                    if let before = comparison.before, let after = comparison.after {
                        Text("\(after - before > 0 ? "+" : "")\(after - before) bpm change")
                            .font(.caption)
                            .foregroundStyle(AppTheme.blue)
                    } else {
                        Text("No reading in one quiet period")
                            .font(.caption)
                            .foregroundStyle(AppTheme.muted)
                            .multilineTextAlignment(.center)
                    }
                    Text(comparison.saved ? "Workout saved to Health" : "Workout was not saved")
                        .font(.caption2)
                        .foregroundStyle(AppTheme.muted)
                }
                Button("Done") { session.reset() }
                    .buttonStyle(.borderedProminent)
                    .tint(AppTheme.peach)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 6)
        }
    }

    private func reading(_ label: String, value: Int?) -> some View {
        VStack(spacing: 2) {
            Text(label).font(.caption2).foregroundStyle(AppTheme.muted)
            Text(value.map(String.init) ?? "—")
                .font(.system(.title3, design: .rounded, weight: .semibold))
                .foregroundStyle(AppTheme.cream)
            Text("bpm").font(.caption2).foregroundStyle(AppTheme.muted)
        }
        .frame(maxWidth: .infinity)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
