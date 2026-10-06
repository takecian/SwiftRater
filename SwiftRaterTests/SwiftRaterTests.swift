import XCTest
@testable import SwiftRater

final class SwiftRaterTests: XCTestCase {
  private func makeManager() -> UsageDataManager {
    let suiteName = "SwiftRaterTests.\(UUID().uuidString)"
    let defaults = UserDefaults(suiteName: suiteName)!
    addTeardownBlock {
      UserDefaults(suiteName: suiteName)?.removePersistentDomain(forName: suiteName)
    }
    return UsageDataManager(userDefaults: defaults)
  }

  func testNoConfiguredCriteriaDoesNotPromptInEitherMode() {
    let manager = makeManager()
    for mode in [SwiftRaterConditionsMetMode.all, .any] {
      manager.conditionsMetMode = mode
      XCTAssertFalse(manager.ratingConditionsHaveBeenMet)
    }
  }

  func testAllModeIgnoresUnconfiguredCriteria() {
    let manager = makeManager()
    manager.usesUntilPrompt = 2
    manager.incrementUseCount()
    XCTAssertFalse(manager.ratingConditionsHaveBeenMet)
    manager.incrementUseCount()
    XCTAssertTrue(manager.ratingConditionsHaveBeenMet)
  }

  func testAllModeSupportsOnlyDaysConfigured() {
    let manager = makeManager()
    manager.daysUntilPrompt = 1
    manager.userDefaults.set(Date().addingTimeInterval(-2 * 24 * 60 * 60).timeIntervalSince1970,
                             forKey: "keySwiftRaterFirstUseDate")
    XCTAssertTrue(manager.ratingConditionsHaveBeenMet)
  }

  func testAllModeSupportsOnlySignificantUsesConfigured() {
    let manager = makeManager()
    manager.significantUsesUntilPrompt = 3
    manager.incrementSignificantUseCount(point: 2)
    XCTAssertFalse(manager.ratingConditionsHaveBeenMet)
    manager.incrementSignificantUseCount()
    XCTAssertTrue(manager.ratingConditionsHaveBeenMet)
  }

  func testAllModeRequiresEveryConfiguredCriterion() {
    let manager = makeManager()
    manager.usesUntilPrompt = 1
    manager.significantUsesUntilPrompt = 1
    manager.incrementUseCount()
    XCTAssertFalse(manager.ratingConditionsHaveBeenMet)
    manager.incrementSignificantUseCount()
    XCTAssertTrue(manager.ratingConditionsHaveBeenMet)
  }

  func testAnyModeRequiresAtLeastOneConfiguredCriterion() {
    let manager = makeManager()
    manager.conditionsMetMode = .any
    manager.usesUntilPrompt = 2
    manager.significantUsesUntilPrompt = 1
    XCTAssertFalse(manager.ratingConditionsHaveBeenMet)
    manager.incrementSignificantUseCount()
    XCTAssertTrue(manager.ratingConditionsHaveBeenMet)
  }

  func testFirstUseDateIsRecordedWhenUsageIsCounted() {
    let manager = makeManager()
    let beforeLaunch = Date().timeIntervalSince1970
    manager.incrementUseCount()
    let firstUse = manager.userDefaults.double(forKey: "keySwiftRaterFirstUseDate")
    XCTAssertGreaterThanOrEqual(firstUse, beforeLaunch)
    XCTAssertLessThanOrEqual(firstUse, Date().timeIntervalSince1970)
    manager.incrementUseCount()
    XCTAssertEqual(manager.userDefaults.double(forKey: "keySwiftRaterFirstUseDate"), firstUse)
  }

  func testCompletedRatingBlocksPrompt() {
    let manager = makeManager()
    manager.usesUntilPrompt = 0
    manager.isRateDone = true
    XCTAssertFalse(manager.ratingConditionsHaveBeenMet)
  }

  func testDebugModeOverridesEligibilityAndCompletedRating() {
    let manager = makeManager()
    manager.isRateDone = true
    manager.debugMode = true
    XCTAssertTrue(manager.ratingConditionsHaveBeenMet)
  }

  func testReminderWaitsEvenWhenInitialCriteriaAreMet() {
    let manager = makeManager()
    manager.usesUntilPrompt = 0
    manager.daysBeforeReminding = 1
    manager.saveReminderRequestDate()
    XCTAssertFalse(manager.ratingConditionsHaveBeenMet)
  }

  func testExpiredReminderDoesNotRequireInitialCriteria() {
    let manager = makeManager()
    manager.daysBeforeReminding = 1
    manager.userDefaults.set(Date().addingTimeInterval(-2 * 24 * 60 * 60).timeIntervalSince1970,
                             forKey: "keySwiftRaterReminderRequestDate")
    XCTAssertTrue(manager.ratingConditionsHaveBeenMet)
  }

  func testReminderWithoutDelayDoesNotPrompt() {
    let manager = makeManager()
    manager.usesUntilPrompt = 0
    manager.saveReminderRequestDate()
    XCTAssertFalse(manager.ratingConditionsHaveBeenMet)
  }

  func testResetClearsUsageAndReminderState() {
    let manager = makeManager()
    manager.usesUntilPrompt = 1
    manager.incrementUseCount()
    manager.incrementSignificantUseCount()
    manager.saveReminderRequestDate()
    manager.isRateDone = true
    manager.reset()
    XCTAssertFalse(manager.isRateDone)
    XCTAssertFalse(manager.ratingConditionsHaveBeenMet)
    for key in ["keySwiftRaterFirstUseDate", "keySwiftRaterUseCount",
                "keySwiftRaterSignificantEventCount", "keySwiftRaterReminderRequestDate"] {
      XCTAssertEqual(manager.userDefaults.double(forKey: key), 0)
    }
    XCTAssertEqual(manager.usesUntilPrompt, 1)
  }

  func testAppNameDoesNotChangeCountryCode() async {
    await MainActor.run {
      let appName = SwiftRater.appName
      let countryCode = SwiftRater.countryCode
      defer {
        SwiftRater.appName = appName
        SwiftRater.countryCode = countryCode
      }
      SwiftRater.countryCode = "jp"
      SwiftRater.appName = "Example App"
      XCTAssertEqual(SwiftRater.appName, "Example App")
      XCTAssertEqual(SwiftRater.countryCode, "jp")
    }
  }
}
