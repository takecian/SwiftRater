# SwiftRater

[![Version](https://img.shields.io/cocoapods/v/SwiftRater.svg?style=flat)](http://cocoapods.org/pods/SwiftRater)
[![License](https://img.shields.io/cocoapods/l/SwiftRater.svg?style=flat)](http://cocoapods.org/pods/SwiftRater)
[![Platform](https://img.shields.io/cocoapods/p/SwiftRater.svg?style=flat)](http://cocoapods.org/pods/SwiftRater)

SwiftRater is a class that you can drop into any iPhone app that will help remind your users to review your app on the App Store.

This app is written in pure Swift.

## iOS 10.3 〜
![SwiftRater1](./Resource/later1.gif)

## 〜 iOS 10.2
![SwiftRater2](./Resource/later2.gif)

## Requirements

iOS 8.0 or later, written in Swift3.

## Installation

### Cocoapods

SwiftRater is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "SwiftRater"
```
### Carthage

SwiftRoutes is compatible with [Carthage](https://github.com/Carthage/Carthage). Add it to your `Cartfile`:

```ruby
github "takecian/SwiftRater"
```

## Usage

Setup SwiftRater in AppDelegate.swift.

```
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        SwiftRater.daysUntilPrompt = 7
        SwiftRater.usesUntilPrompt = 10
        SwiftRater.significantUsesUntilPrompt = 3
        SwiftRater.daysBeforeReminding = 1
        SwiftRater.showLaterButton = true
        SwiftRater.debugMode = true
        SwiftRater.appLaunched()

        return true
    }

```

| Property      | Description           |
| ------------- |:-------------:|
| debugMode      | Shows review request every time. Default false, **need to set false when you submit app to AppStore**. |
| daysUntilPrompt      | Shows review request if `daysUntilPrompt` days passed since first app launch. |
| usesUntilPrompt      | Shows review request if users launch more than `usesUntilPrompt` times.      |
| significantUsesUntilPrompt | Shows review request if user does significant actions more than `significantUsesUntilPrompt` |
| showLaterButton | Show Later button in review request dialong, valid for iOS10.2 or before devices.|
| daysBeforeReminding | Days until reminder popup if the user chooses `rate later`,  valid for iOS10.2 or before devices.      |

Call `SwiftRater.check()` in `viewDidAppear` of ViewController when you want to show review request dialog.
```
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        SwiftRater.check()
    }

```

For `significantUsesUntilPrompt`, you need to add `SwiftRater.incrementSignificantUsageCount`

```
func postComment() {
    // do something ..

	SwiftRater.incrementSignificantUsageCount()
}

```

## Customize text

You can customize text in review request dialog for iOS10.2 or before devices. Set text in following properties.
- SwiftRater.alertTitle
- SwiftRater.alertMessage
- SwiftRater.alertCancelTitle
- SwiftRater.alertRateTitle
- SwiftRater.alertRateLaterTitle

## Example

You can find Demo app in this repo.

## Author

takecian, takecian@gmail.com

## License

SwiftRater is available under the MIT license. See the LICENSE file for more info.
