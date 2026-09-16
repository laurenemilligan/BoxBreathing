#!/bin/sh
set -eu
cd "$(dirname "$0")"
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
xcodebuild -quiet -project ManhuntWatch.xcodeproj -scheme ManhuntWatch -configuration Debug -destination 'generic/platform=watchOS' -derivedDataPath "$PWD/DerivedData" CODE_SIGNING_ALLOWED=NO build
