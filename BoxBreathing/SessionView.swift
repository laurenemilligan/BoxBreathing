import SwiftUI

struct SessionView: View {
    @ObservedObject var session: BreathingSession

    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                Text(session.phase.title.uppercased())
                    .font(.headline)
                    .foregroundStyle(tint)
                ZStack {
                    Circle()
                        .stroke(tint.opacity(0.2), lineWidth: 7)
                    Circle()
                        .trim(from: 0, to: session.phaseProgress)
                        .stroke(tint, style: StrokeStyle(lineWidth: 7, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                    Text("\(session.phaseRemaining)")
                        .font(.system(size: 44, weight: .light, design: .rounded))
                        .monospacedDigit()
                }
                .frame(width: 96, height: 96)
                Text("\(session.remaining / 60):\(String(format: "%02d", session.remaining % 60)) left")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                HStack {
                    Button(session.isPaused ? "Resume" : "Pause") {
                        session.isPaused ? session.resume() : session.pause()
                    }
                    Button("End", role: .destructive) { session.end() }
                }
                .font(.caption)
            }
            .frame(maxWidth: .infinity)
        }
    }

    private var tint: Color {
        switch session.phase {
        case .inhale: .mint
        case .holdIn: .cyan
        case .exhale: .blue
        case .holdOut: .indigo
        }
    }
}
