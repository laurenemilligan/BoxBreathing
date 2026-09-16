import SwiftUI
import WatchKit

struct HapticLabView: View {
    var body: some View {
        List(HapticCue.allCases) { cue in
            Button(cue.title) {
                WKInterfaceDevice.current().play(cue.watchType)
            }
        }
        .navigationTitle("Haptic Lab")
    }
}
