# Box Breathing for Apple Watch

A native, watch-only SwiftUI app. The initial pattern is 4 seconds inhale, 4 seconds hold in, 4 seconds exhale, and 4 seconds hold out.

## Use

Choose a 1, 3, 5, or 10 minute breathing period and tap **Begin**. After Health permission, the watch saves a Mind & Body workout: 30 seconds of stillness, your breathing period, and 30 seconds to reflect. The app compares average heart rate recorded during the two stillness periods. If either period has no readable samples, it shows an unavailable reading. You can pause, resume, or end at any time.

The default **Flow** haptic rhythm uses the Watch's Up and Down cues plus two later taps for each inhale and exhale. Each hold gets one Click. This suggests a pull and push through timing; watchOS does not offer a literal directional force effect. **Preferences** lets you switch to the original single-cue **Classic** style, turn cues off, or change each phase's length. **Try the cues** previews Flow and the built-in Watch patterns. The interface uses a growing and shrinking orb and a compact layout for quick glances.

The app requests permission to read heart rate and save workouts. It does not request access to other Health data or display other readings. Apple Watch may automatically record other workout data, such as active energy. Workout mode keeps the session running while the display dims. Heart-rate collection and signing need testing on the physical watch; a command-line build only checks compilation.
