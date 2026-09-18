import SwiftUI

struct SessionView: View {
    @ObservedObject var session: BreathingSession

    var body: some View {
        ScrollView {
            VStack(spacing: 5) {
                Text(title)
                    .font(.system(.headline, design: .rounded, weight: .semibold))
                    .foregroundStyle(AppTheme.cream)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                ZStack {
                    Circle()
                        .stroke(tint.opacity(0.25), lineWidth: 2)
                        .frame(width: 94, height: 94)
                    Circle()
                        .fill(LinearGradient(colors: [AppTheme.cream, tint],
                                             startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 82, height: 82)
                        .scaleEffect(orbScale)
                    if session.stage != .finishing {
                        Text(countdown)
                            .font(.system(size: 34, weight: .semibold, design: .rounded))
                            .foregroundStyle(AppTheme.background)
                            .monospacedDigit()
                    } else {
                        ProgressView().tint(AppTheme.background)
                    }
                }
                .frame(height: 98)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(session.stage == .finishing
                                    ? "Saving workout"
                                    : "\(title), \(countdown) seconds")

                Text(subtitle)
                    .font(.caption2)
                    .foregroundStyle(AppTheme.muted)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                HStack(spacing: 6) {
                    Button(session.isPaused ? "Resume" : "Pause") {
                        session.isPaused ? session.resume() : session.pause()
                    }
                    .disabled(!session.isActive)
                    Button("End", role: .destructive) { session.end() }
                        .disabled(!session.isActive)
                }
                .font(.caption)
                .buttonStyle(.bordered)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 6)
        }
    }

    private var title: String {
        switch session.stage {
        case .settlingBefore: "Settle in"
        case .settlingAfter: "Reflect"
        case .breathing: session.phase.title
        case .finishing: "Saving"
        default: "Box Breathing"
        }
    }

    private var countdown: String {
        switch session.stage {
        case .breathing: String(session.phaseRemaining)
        case .settlingBefore, .settlingAfter: String(session.stageRemaining)
        default: ""
        }
    }

    private var subtitle: String {
        switch session.stage {
        case .breathing:
            "Workout · \(session.remaining / 60):\(String(format: "%02d", session.remaining % 60)) left"
        case .settlingBefore, .settlingAfter: "Workout · heart rate reading"
        case .finishing: "Saving your workout"
        default: ""
        }
    }

    private var orbScale: CGFloat {
        guard session.stage == .breathing else { return 0.85 }
        let progress = CGFloat(session.phaseProgress)
        switch session.phase {
        case .inhale: return 0.68 + 0.32 * progress
        case .holdIn: return 1
        case .exhale: return 1 - 0.32 * progress
        case .holdOut: return 0.68
        }
    }

    private var tint: Color {
        switch session.stage {
        case .settlingBefore, .settlingAfter: AppTheme.blue
        case .breathing:
            switch session.phase {
            case .inhale, .holdIn: AppTheme.peach
            case .exhale, .holdOut: AppTheme.blue
            }
        default: AppTheme.peach
        }
    }
}
