# ManhuntWatch

Minimal native SwiftUI watchOS project for Codex and Xcode setup. The app currently displays its name only.

## Build from Codex

Open this folder as a local project in Codex. Describe a change in plain language, ask Codex to edit the Swift files and run `./build.sh`, then review the result. The script uses the installed Xcode directly and writes build files into `DerivedData` inside this folder. It checks compilation without needing a signing account or connected watch.

## Test on Apple Watch

1. Open `ManhuntWatch.xcodeproj` in Xcode.
2. In **Xcode > Settings > Apple Accounts**, sign in with your personal Apple Account.
3. Select the **ManhuntWatch** target and open **Signing & Capabilities**. Keep **Automatically manage signing** enabled, choose your **Personal Team**, and replace `com.example.ManhuntWatch` with a unique bundle identifier.
4. Pair the Series 10 with your iPhone and connect the paired iPhone to this Mac if Xcode requests it. Trust the Mac and enable Developer Mode on the watch if prompted.
5. Choose the watch as Xcode's run destination and press **Run**. Xcode should create the development signing credentials and provisioning profile.

Signing and installation require your Apple Account and the watch to be available in Xcode. This project does not store credentials or a Team ID in Git.
