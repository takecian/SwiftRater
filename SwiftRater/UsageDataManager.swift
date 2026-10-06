#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

let SwiftRaterInvalid = -1

class UsageDataManager: @unchecked Sendable {
  
  var daysUntilPrompt: Int = SwiftRaterInvalid
  var usesUntilPrompt: Int = SwiftRaterInvalid
  var significantUsesUntilPrompt: Int = SwiftRaterInvalid
  var daysBeforeReminding: Int = SwiftRaterInvalid
  
  var showLaterButton: Bool = true
  var debugMode: Bool = false
  var conditionsMetMode: SwiftRaterConditionsMetMode = .all
  
  static private let keySwiftRaterFirstUseDate = "keySwiftRaterFirstUseDate"
  static private let keySwiftRaterUseCount = "keySwiftRaterUseCount"
  static private let keySwiftRaterSignificantEventCount = "keySwiftRaterSignificantEventCount"
  static private let keySwiftRaterRateDone = "keySwiftRaterRateDone"
  static private let keySwiftRaterTrackingVersion = "keySwiftRaterTrackingVersion"
  static private let keySwiftRaterReminderRequestDate = "keySwiftRaterReminderRequestDate"
  
  static let shared = UsageDataManager()
  
  let userDefaults: UserDefaults
  
  init(userDefaults: UserDefaults = .standard) {
    self.userDefaults = userDefaults
    let defaults = [
      UsageDataManager.keySwiftRaterFirstUseDate: 0,
      UsageDataManager.keySwiftRaterUseCount: 0,
      UsageDataManager.keySwiftRaterSignificantEventCount: 0,
      UsageDataManager.keySwiftRaterRateDone: false,
      UsageDataManager.keySwiftRaterTrackingVersion: "",
      UsageDataManager.keySwiftRaterReminderRequestDate: 0
    ] as [String : Any]
    userDefaults.register(defaults: defaults)
  }
  
  var isRateDone: Bool {
    get {
      return userDefaults.bool(forKey: UsageDataManager.keySwiftRaterRateDone)
    }
    set {
      userDefaults.set(newValue, forKey: UsageDataManager.keySwiftRaterRateDone)
      userDefaults.synchronize()
    }
  }
  
  var trackingVersion: String {
    get {
      return userDefaults.string(forKey: UsageDataManager.keySwiftRaterTrackingVersion) ?? ""
    }
    set {
      userDefaults.set(newValue, forKey: UsageDataManager.keySwiftRaterTrackingVersion)
      userDefaults.synchronize()
    }
  }
  
  private var firstUseDate: TimeInterval {
    get {
      let value = userDefaults.double(forKey: UsageDataManager.keySwiftRaterFirstUseDate)
      
      if value == 0 {
        // store first launch date time
        let firstLaunchTimeInterval = Date().timeIntervalSince1970
        userDefaults.set(firstLaunchTimeInterval, forKey: UsageDataManager.keySwiftRaterFirstUseDate)
        return firstLaunchTimeInterval
      } else {
        return value
      }
    }
  }
  
  private var reminderRequestToRate: TimeInterval {
    get {
      return userDefaults.double(forKey: UsageDataManager.keySwiftRaterReminderRequestDate)
    }
    set {
      userDefaults.set(newValue, forKey: UsageDataManager.keySwiftRaterReminderRequestDate)
      userDefaults.synchronize()
    }
  }
  
  private var usesCount: Int {
    get {
      return userDefaults.integer(forKey: UsageDataManager.keySwiftRaterUseCount)
    }
    set {
      userDefaults.set(newValue, forKey: UsageDataManager.keySwiftRaterUseCount)
      userDefaults.synchronize()
    }
  }
  
  private var significantEventCount: Int {
    get {
      return userDefaults.integer(forKey: UsageDataManager.keySwiftRaterSignificantEventCount)
    }
    set {
      userDefaults.set(newValue, forKey: UsageDataManager.keySwiftRaterSignificantEventCount)
      userDefaults.synchronize()
    }
  }
  
  var ratingConditionsHaveBeenMet: Bool {
    guard !debugMode else { // if debug mode, return always true
      printMessage(message: " In debug mode")
      return true
    }
    guard !isRateDone else { // if already rated, return false
      printMessage(message: " Already rated")
      return false }
    
    // A reminder replaces the initial eligibility criteria until its delay passes.
    if reminderRequestToRate != 0 {
      guard daysBeforeReminding != SwiftRaterInvalid else { return false }
      let timeSinceReminderRequest = Date().timeIntervalSince1970 - reminderRequestToRate
      let timeUntilRate = 60 * 60 * 24 * daysBeforeReminding
      return Int(timeSinceReminderRequest) >= timeUntilRate
    }

    // Unconfigured criteria must not prevent `.all` from matching the enabled ones.
    var conditions: [Bool] = []
    if daysUntilPrompt != SwiftRaterInvalid {
      let timeSinceFirstLaunch = Date().timeIntervalSince1970 - firstUseDate
      let timeUntilRate = 60 * 60 * 24 * daysUntilPrompt
      conditions.append(Int(timeSinceFirstLaunch) > timeUntilRate)
    }
    if usesUntilPrompt != SwiftRaterInvalid {
      conditions.append(usesCount >= usesUntilPrompt)
    }
    if significantUsesUntilPrompt != SwiftRaterInvalid {
      conditions.append(significantEventCount >= significantUsesUntilPrompt)
    }

    // No configured criteria should never trigger an automatic prompt.
    guard !conditions.isEmpty else { return false }
    if conditionsMetMode == .all {
      return conditions.allSatisfy { $0 }
    } else {
      return conditions.contains(true)
    }
  }
  
  func reset() {
    userDefaults.set(0, forKey: UsageDataManager.keySwiftRaterFirstUseDate)
    userDefaults.set(0, forKey: UsageDataManager.keySwiftRaterUseCount)
    userDefaults.set(0, forKey: UsageDataManager.keySwiftRaterSignificantEventCount)
    userDefaults.set(false, forKey: UsageDataManager.keySwiftRaterRateDone)
    userDefaults.set(0, forKey: UsageDataManager.keySwiftRaterReminderRequestDate)
    userDefaults.synchronize()
  }
  
  func incrementUseCount() {
    // Start the day threshold at first use, not at the first eligibility check.
    _ = firstUseDate
    usesCount = usesCount + 1
  }
  
  func incrementSignificantUseCount(point: Int = 1) {
    significantEventCount = significantEventCount + point
  }
  
  func saveReminderRequestDate() {
    reminderRequestToRate = Date().timeIntervalSince1970
  }
  
  private func printMessage(message: String) {
    Task {
      let showLog = await SwiftRater.showLog
      if showLog {
        print("[SwiftRater] \(message)")
      }
    }
  }
}
