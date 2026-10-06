# Repository guide

## Scope and layout

SwiftRater is a Swift/Objective-C-compatible review-prompt library for iOS and macOS.

- `SwiftRater/SwiftRater.swift`: public `@MainActor` API, StoreKit/custom dialogs, and App Store lookup.
- `SwiftRater/UsageDataManager.swift`: persistent usage, eligibility, and reminder state.
- `SwiftRater/*.lproj/SwiftRaterLocalization.strings`: localized custom-dialog text.
- `SwiftRater/PrivacyInfo.xcprivacy`: privacy manifest; retain it in every distribution path.
- `SwiftRaterTests/SwiftRaterTests.swift`: regression tests shared by SPM and the Xcode test target.
- `Package.swift`: iOS/macOS Swift Package Manager library and test target.
- `SwiftRater.xcodeproj`: iOS framework and test targets, shared `SwiftRater` scheme (also used by Carthage).
- `SwiftRater.podspec`: CocoaPods distribution metadata.
- `Demo/` and `DemoObjc/`: Swift and Objective-C iOS examples with CocoaPods workspaces.
- `.github/workflows/swift.yml`: Apple-platform build and test checks.

## Compatibility constraints

- Preserve iOS 13.0 and macOS 10.15 minimum deployment targets unless the task explicitly requires a change.
- The package requires Swift tools 5.10 and defaults to Swift 5 language mode. The Xcode project and CocoaPods use Swift 6. Test both language modes when changing concurrency behavior.
- Keep public Swift and Objective-C APIs source-compatible. In particular, preserve `@objc` entry points, actor isolation, and the explicit `rateApp(host:)` custom-dialog flow.
- New Apple APIs need runtime availability guards. APIs first shipped in the Xcode 16 SDK also need compiler guards if used by SPM, because it supports Swift 5.10 toolchains.
- StoreKit may decline to show a prompt. Do not treat a request as proof that the user saw a dialog or submitted a review.
- On iOS, use the visible host's active window scene. Keep the legacy fallback for active apps that have windows without scenes. Do not consume review eligibility for detached or backgrounded hosts.
- `-1` disables an initial eligibility criterion. `.all` combines only configured criteria; no configured criteria means no automatic prompt. Reminders and debug mode have separate behavior.
- Do not rename persisted UserDefaults keys or change reset/reminder behavior without migration analysis and regression tests.

## Development and checks

Use macOS with Xcode and its command-line tools selected. The library imports UIKit/AppKit/StoreKit and cannot be built or tested on Linux.

From the repository root:

```sh
xcodebuild -version
swift --version
swift package dump-package
swift test
swift test -Xswiftc -swift-version -Xswiftc 6
xcodebuild -project SwiftRater.xcodeproj -scheme SwiftRater \
  -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO build
```

Run iOS tests on an installed simulator. Discover destinations rather than hard-coding a device model:

```sh
xcodebuild -project SwiftRater.xcodeproj -scheme SwiftRater -showdestinations
xcodebuild -project SwiftRater.xcodeproj -scheme SwiftRater \
  -destination 'platform=iOS Simulator,id=<simulator-UDID>' \
  CODE_SIGNING_ALLOWED=NO test
```

The Swift 6 command requires Xcode 16 or later. A Swift 5.10 toolchain can run the default package tests but not Swift 6 language-mode tests. Report unavailable checks explicitly; static review is not a successful build.

For CocoaPods changes, use the repository's Ruby/Bundler configuration on a Mac:

```sh
bundle install
bundle exec pod lib lint SwiftRater.podspec
```

For either demo, run `bundle exec pod install --project-directory=Demo` (or `DemoObjc`) from the root, then open its `.xcworkspace`. Do not commit generated Pods, build outputs, or user-specific Xcode settings.

## Change and test expectations

- Follow the existing two-space Swift indentation. Keep changes focused; avoid unrelated formatting and project-file churn.
- Add regression tests for behavior changes in the existing test file so both SPM and the checked-in Xcode target discover them.
- Create isolated UserDefaults suites through `UsageDataManager(userDefaults:)`; clean up each suite. Tests must not rely on the developer's persisted usage or network responses.
- Avoid opening StoreKit dialogs, App Store URLs, or making live network calls in unit tests. Manually check UI changes in the demos when a simulator/device is available.
- Preserve localized string keys and resource inclusion across SPM, Xcode, and CocoaPods. Update README examples if behavior or requirements change.
- Keep release metadata consistent, but do not create tags, publish a pod/release, merge, or deploy unless explicitly requested.
- Include what changed, tests actually run, and any unverified Apple-platform behavior in the PR description.
