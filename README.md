# Box Breathing for Apple Watch

A native, watch-only SwiftUI app. The initial pattern is 4 seconds inhale, 4 seconds hold in, 4 seconds exhale, and 4 seconds hold out.

## Use

Choose a 1, 3, 5, or 10 minute breathing period and tap **Begin**. After Health permission, the watch saves a Mind & Body workout: 30 seconds of stillness, your breathing period, and 30 seconds to reflect. The app compares average heart rate recorded during the two stillness periods. If either period has no readable samples, it shows an unavailable reading. You can pause, resume, or end at any time.

The default **Flow** haptic rhythm uses the Watch's Up and Down cues plus two later taps for each inhale and exhale. Each hold gets one Click. This suggests a pull and push through timing; watchOS does not offer a literal directional force effect. **Preferences** lets you switch to the original single-cue **Classic** style, turn cues off, or change each phase's length. **Try the cues** previews Flow and the built-in Watch patterns. The interface uses a growing and shrinking orb and a compact layout for quick glances.

The app requests permission to read heart rate and save workouts. It does not request access to other Health data or display other readings. Apple Watch may automatically record other workout data, such as active energy. Workout mode keeps the session running while the display dims. Heart-rate collection and signing need testing on the physical watch; a command-line build only checks compilation.

## Build from Codex

Open this folder as a local project in Codex. Describe a change in plain language and ask Codex to edit the Swift files and run `./build.sh`. The script uses the installed Xcode directly, writes build files into `DerivedData`, and checks compilation without signing.

## Run on Apple Watch

1. Open `BoxBreathing.xcodeproj` in Xcode.
2. In **Xcode > Settings > Apple Accounts**, sign in with your personal Apple Account.
3. Select the **BoxBreathing** target and open **Signing & Capabilities**. Keep **Automatically manage signing** enabled and choose your **Personal Team**. The bundle identifier and HealthKit entitlement are set in the project. Xcode must update the provisioning profile for HealthKit.
4. Pair the Series 10 with your iPhone and connect the paired iPhone to this Mac if Xcode requests it. Trust the Mac and enable Developer Mode on the watch if prompted.
5. Choose the watch as Xcode's run destination and press **Run**.

Signing and installation require your Apple Account and the watch to be available in Xcode. Your Team ID is in the project settings; no account credentials are stored in Git.
