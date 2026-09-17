# Box Breathing for Apple Watch

A native, watch-only SwiftUI app. Each breathing phase gets a distinct haptic cue. The initial pattern is 4 seconds inhale, 4 seconds hold in, 4 seconds exhale, and 4 seconds hold out.

## Use

Choose a 1, 3, 5, or 10 minute session and tap **Start**. The current phase, phase countdown, and overall time remaining appear on the watch. You can pause, resume, or end at any time. The app plays a haptic once at each phase transition. **Timing & cues** lets you change each phase's length and choose its haptic. **Haptic Lab** lets you feel the available built-in cues on your actual watch before deciding.

The app starts a mindfulness extended runtime session so it can continue while the display dims. If the system ends that session, the breathing session stops. This needs testing on a physical Series 10; a command-line build cannot verify how cues feel or behave on your wrist.

## Build from Codex

Open this folder as a local project in Codex. Describe a change in plain language and ask Codex to edit the Swift files and run `./build.sh`. The script uses the installed Xcode directly, writes build files into `DerivedData`, and checks compilation without signing.

## Run on Apple Watch

1. Open `BoxBreathing.xcodeproj` in Xcode.
2. In **Xcode > Settings > Apple Accounts**, sign in with your personal Apple Account.
3. Select the **BoxBreathing** target and open **Signing & Capabilities**. Keep **Automatically manage signing** enabled and choose your **Personal Team**. The bundle identifier has already been set for this project.
4. Pair the Series 10 with your iPhone and connect the paired iPhone to this Mac if Xcode requests it. Trust the Mac and enable Developer Mode on the watch if prompted.
5. Choose the watch as Xcode's run destination and press **Run**.

Signing and installation require your Apple Account and the watch to be available in Xcode. Credentials and a Team ID are not stored in Git.
