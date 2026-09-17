import SwiftUI

struct SessionView: View {
    @ObservedObject var session: BreathingSession

    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(tint)
                if session.stage == .breathing {
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
                } else if session.stage == .settlingBefore || session.stage == .settlingAfter {
                    Text("\(session.stageRemaining)")
                        .font(.system(size: 44, weight: .light, design: .rounded))
                        .monospacedDigit()
                    Text("Be still for a heart-rate reading")
                        .font(.caption).foregroundStyle(.secondary)
                } else {
                    ProgressView("Saving workout")
                }
                HStack {
                    Button(session.isPaused ? "Resume" : "Pause") {
                        session.isPaused ? session.resume() : session.pause()
                    }
                    .disabled(!session.isActive)
                    Button("End", role: .destructive) { session.end() }
                        .disabled(!session.isActive)
                }
                .font(.caption)
            }
            .frame(maxWidth: .infinity)
        }
    }

    private var title: String {
        switch session.stage {
        case .settlingBefore: "SETTLE IN"
        case .settlingAfter: "REFLECT"
        case .breathing: session.phase.title.uppercased()
        case .finishing: "FINISHING"
        default: "BOX BREATHING"
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
