#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif
import StoreKit

@objc public enum SwiftRaterConditionsMetMode: Int {
  case all
  case any
}

@MainActor
@objc public class SwiftRater: NSObject, @unchecked Sendable {

  private static let staticLock = NSLock()
  private let lock = NSLock()

  enum ButtonIndex: Int {
    case cancel = 0
    case rate = 1
    case later = 2
  }
  
  @objc public let SwiftRaterErrorDomain = "Siren Error Domain"
  
  @objc public static var daysUntilPrompt: Int {
    get {
      staticLock.lock()
      defer {
        staticLock.unlock()
      }
      return UsageDataManager.shared.daysUntilPrompt
    }
    set {
      staticLock.lock()
      defer {
        staticLock.unlock()
      }
      UsageDataManager.shared.daysUntilPrompt = newValue
    }
  }
  @objc public static var usesUntilPrompt: Int {
    get {
      staticLock.lock()
      defer {
        staticLock.unlock()
      }
      return UsageDataManager.shared.usesUntilPrompt
    }
    set {
      staticLock.lock()
      defer {
        staticLock.unlock()
      }
      UsageDataManager.shared.usesUntilPrompt = newValue
    }
  }
  @objc public static var significantUsesUntilPrompt: Int {
    get {     
      staticLock.lock()
      defer {
        staticLock.unlock()
      }
      return UsageDataManager.shared.significantUsesUntilPrompt
    }
    set {
      staticLock.lock()
      defer {
        staticLock.unlock()
      }
      UsageDataManager.shared.significantUsesUntilPrompt = newValue
    }
  }
  
  @objc public static var daysBeforeReminding: Int {
    get {
      staticLock.lock()
      defer {
        staticLock.unlock()
      }
      return UsageDataManager.shared.daysBeforeReminding
    }
    set {
      staticLock.lock()
      defer {
        staticLock.unlock()
      }
      UsageDataManager.shared.daysBeforeReminding = newValue
    }
  }
  @objc public static var debugMode: Bool {
    get {
      staticLock.lock()
      defer {
        staticLock.unlock()
      }
      return UsageDataManager.shared.debugMode
    }
    set {
      staticLock.lock()
      defer {
        staticLock.unlock()
      }
      UsageDataManager.shared.debugMode = newValue
    }
  }
  @objc public static var conditionsMetMode: SwiftRaterConditionsMetMode {
    get {
      staticLock.lock()
      defer {
        staticLock.unlock()
      }
      return UsageDataManager.shared.conditionsMetMode
    }
    set {
      staticLock.lock()
      defer {
        staticLock.unlock()
      }
      UsageDataManager.shared.conditionsMetMode = newValue
    }
  }
  
  nonisolated(unsafe) private static var _useStoreKitIfAvailable = true
  @objc public static var useStoreKitIfAvailable: Bool {
    get {
      _useStoreKitIfAvailable
    }
    set {
      _useStoreKitIfAvailable = newValue
    }
  }

  nonisolated(unsafe) private static var _showLaterButton = true
  @objc public static var showLaterButton: Bool {
    get {
      _showLaterButton
    }
    set {
      _showLaterButton = newValue
    }
  }

  nonisolated(unsafe) private static var _countryCode: String?
  @objc public static var countryCode: String? {
    get {
      _countryCode
    }
    set {
      _countryCode = newValue
    }
  }

  nonisolated(unsafe) private static var _alertTitle: String?
  @objc public static var alertTitle: String? {
    get {
      _alertTitle
    }
    set {
      _alertTitle = newValue
    }
  }

  nonisolated(unsafe) private static var _alertMessage: String?
  @objc public static var alertMessage: String? {
    get {
      _alertMessage
    }
    set {
      _alertMessage = newValue
    }
  }

  nonisolated(unsafe) private static var _alertCancelTitle: String?
  @objc public static var alertCancelTitle: String? {
    get {
      _alertCancelTitle
    }
    set {
      _alertCancelTitle = newValue
    }
  }

  nonisolated(unsafe) private static var _alertRateTitle: String?
  @objc public static var alertRateTitle: String? {
    get {
      _alertRateTitle
    }
    set {
      _alertRateTitle = newValue
    }
  }

  nonisolated(unsafe) private static var _alertRateLaterTitle: String?
  @objc public static var alertRateLaterTitle: String? {
    get {
      _alertRateLaterTitle
    }
    set {
      _alertRateLaterTitle = newValue
    }
  }

  nonisolated(unsafe) private static var _appName: String?
  @objc public static var appName: String? {
    get {
      _appName
    }
    set {
      _countryCode = newValue
    }
  }

  nonisolated(unsafe) private static var _showLog: Bool = false
  @objc public static var showLog: Bool {
    get {
      _showLog
    }
    set {
      _showLog = newValue
    }
  }

  nonisolated(unsafe) private static var _resetWhenAppUpdated: Bool = false
  @objc public static var resetWhenAppUpdated: Bool {
    get {
      _resetWhenAppUpdated
    }
    set {
      _resetWhenAppUpdated = newValue
    }
  }

  @objc public static let shared = SwiftRater()
  
  @objc public static var isRateDone: Bool {

    UsageDataManager.shared.isRateDone
  }
  
  @objc public static var isMetConditions : Bool {
    UsageDataManager.shared.ratingConditionsHaveBeenMet
  }

  nonisolated(unsafe) private static var _appID: String?
  @objc public static var appID: String? {
    get {
      staticLock.lock()
      defer {
        staticLock.unlock()
      }
      return _appID
    }
    set {
      staticLock.lock()
      defer {
        staticLock.unlock()
      }
      _appID = newValue
    }
  }

  private static var appVersion: String {
    get {
      Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String ?? "0.0.0"
    }
  }
  
  private var titleText: String {
    SwiftRater.alertTitle ?? String.init(format: localize("Rate %@"), mainAppName)
  }
  
  private var messageText: String {
    SwiftRater.alertMessage ?? String.init(format: localize("Rater.title"), mainAppName)
  }
  
  private var rateText: String {
    SwiftRater.alertRateTitle ?? String.init(format: localize("Rate %@"), mainAppName)
  }
  
  private var cancelText: String {
    SwiftRater.alertCancelTitle ?? String.init(format: localize("No, Thanks"), mainAppName)
  }
  
  private var laterText: String {
    SwiftRater.alertRateLaterTitle ?? String.init(format: localize("Remind me later"), mainAppName)
  }
  
  private func localize(_ key: String) -> String {
    NSLocalizedString(key, tableName: "SwiftRaterLocalization", bundle: Bundle.module, comment: "")
  }
  
  private var mainAppName: String {
    if let name = SwiftRater.appName {
      return name
    }
    if let name = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String {
      return name
    } else if let name = Bundle.main.infoDictionary?["CFBundleName"] as? String {
      return name
    } else {
      return "App"
    }
  }
  
  private override init() {
    super.init()
  }
  
  @objc public static func appLaunched() {
    if SwiftRater.resetWhenAppUpdated && SwiftRater.appVersion != UsageDataManager.shared.trackingVersion {
      UsageDataManager.shared.reset()
      UsageDataManager.shared.trackingVersion = SwiftRater.appVersion
    }
    
    SwiftRater.shared.perform()
  }
  
  @objc public static func incrementSignificantUsageCount() {
    UsageDataManager.shared.incrementSignificantUseCount()
  }
  
#if os(iOS)
  @discardableResult
  @objc public static func check(host: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> Bool {
    guard UsageDataManager.shared.ratingConditionsHaveBeenMet else {
      return false
    }
    
    SwiftRater.shared.showRatingAlert(host: host, force: false)
    return true
  }
  
  @objc public static func rateApp(host: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) {
    NSLog("[SwiftRater] Trying to show review request dialog.")
    SwiftRater.shared.showRatingAlert(host: host, force: true)
    
    UsageDataManager.shared.isRateDone = true
  }
#endif
  
#if os(macOS)
  @discardableResult
  @objc public static func check(host: NSViewController? = NSApplication.shared.keyWindow?.contentViewController) -> Bool {
    guard UsageDataManager.shared.ratingConditionsHaveBeenMet else {
      return false
    }
    
    SwiftRater.shared.showRatingAlert(host: host, force: false)
    return true
  }
  
  @objc public static func rateApp(host: NSViewController? = NSApplication.shared.keyWindow?.contentViewController) {
    NSLog("[SwiftRater] Trying to show review request dialog.")
    SwiftRater.shared.showRatingAlert(host: host, force: true)
    
    UsageDataManager.shared.isRateDone = true
  }
#endif
  
  @objc public static func reset() {
    UsageDataManager.shared.reset()
  }
  
  private func perform() {
    if SwiftRater.appName != nil {
      incrementUsageCount()
    } else {
      // If not set, get appID and version from itunes
      do {
        let url = try iTunesURLFromString()
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 30)
        URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
          Task { @MainActor in
            self.processResults(withData: data, response: response, error: error)
          }
        }).resume()
      } catch let error {
        postError(.malformedURL, underlyingError: error)
      }
    }
  }
  
  private func processResults(withData data: Data?, response: URLResponse?, error: Error?) {
    if let error = error {
      self.postError(.appStoreDataRetrievalFailure, underlyingError: error)
    } else {
      guard let data = data else {
        self.postError(.appStoreDataRetrievalFailure, underlyingError: nil)
        return
      }
      
      do {
        let jsonData = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)
        guard let appData = jsonData as? [String: Any] else {
          self.postError(.appStoreJSONParsingFailure, underlyingError: nil)
          return
        }
        
        DispatchQueue.main.async {
          // Print iTunesLookup results from appData
          //                    self.printMessage(message: "JSON results: \(appData)")
          
          // Process Results (e.g., extract current version that is available on the AppStore)
          self.processVersionCheck(withResults: appData)
        }
        
      } catch let error {
        self.postError(.appStoreDataRetrievalFailure, underlyingError: error)
      }
    }
  }
  
  private func processVersionCheck(withResults results: [String: Any]) {
    defer {
      incrementUsageCount()
    }
    guard let allResults = results["results"] as? [[String: Any]] else {
      self.postError(.appStoreDataRetrievalFailure, underlyingError: nil)
      return
    }
    
    /// App not in App Store
    guard !allResults.isEmpty else {
      postError(.appStoreDataRetrievalFailure, underlyingError: nil)
      return
    }
    
    guard let appID = allResults.first?["trackId"] as? Int else {
      postError(.appStoreAppIDFailure, underlyingError: nil)
      return
    }
    
    SwiftRater.appID = String(appID)
  }
  
  private func iTunesURLFromString() throws -> URL {
    var components = URLComponents()
    components.scheme = "https"
    components.host = "itunes.apple.com"
    if let countryCode = SwiftRater.countryCode {
      components.path = "/\(countryCode)/lookup"
    } else {
      components.path = "/lookup"
    }
    
    let items: [URLQueryItem] = [URLQueryItem(name: "bundleId", value: Bundle.bundleID())]
    
    components.queryItems = items
    
    guard let url = components.url, !url.absoluteString.isEmpty else {
      throw SwiftRaterError.malformedURL
    }
    
    return url
  }
  
  private func postError(_ code: SwiftRaterErrorCode, underlyingError: Error?) {
    let description: String
    
    switch code {
    case .malformedURL:
      description = "The iTunes URL is malformed. Please leave an issue on http://github.com/ArtSabintsev/Siren with as many details as possible."
    case .appStoreDataRetrievalFailure:
      description = "Error retrieving App Store data as an error was returned."
    case .appStoreJSONParsingFailure:
      description = "Error parsing App Store JSON data."
    case .appStoreAppIDFailure:
      description = "Error retrieving trackId as results.first does not contain a 'trackId' key."
    }
    
    var userInfo: [String: Any] = [NSLocalizedDescriptionKey: description]
    
    if let underlyingError = underlyingError {
      userInfo[NSUnderlyingErrorKey] = underlyingError
    }
    
    let error = NSError(domain: SwiftRaterErrorDomain, code: code.rawValue, userInfo: userInfo)
    printMessage(message: error.localizedDescription)
  }
  
  private func printMessage(message: String) {
    if SwiftRater.showLog {
      print("[SwiftRater] \(message)")
    }
  }
  
  private func incrementUsageCount() {
    UsageDataManager.shared.incrementUseCount()
  }
  
  private func incrementSignificantUseCount() {
    UsageDataManager.shared.incrementSignificantUseCount()
  }
  
#if os(iOS)
  private func showRatingAlert(host: UIViewController?, force: Bool) {
    NSLog("[SwiftRater] Trying to show review request dialog.")
    if #available(iOS 10.3, *), SwiftRater.useStoreKitIfAvailable, !force {
      SKStoreReviewController.requestReview()
      UsageDataManager.shared.isRateDone = true
    } else {
      let alertController = UIAlertController(title: titleText, message: messageText, preferredStyle: .alert)
      
      let rateAction = UIAlertAction(title: rateText, style: .default, handler: {
        [unowned self] action -> Void in
        self.rateAppWithAppStore()
        UsageDataManager.shared.isRateDone = true
      })
      alertController.addAction(rateAction)
      
      if SwiftRater.showLaterButton {
        alertController.addAction(UIAlertAction(title: laterText, style: .default, handler: {
          action -> Void in
          UsageDataManager.shared.saveReminderRequestDate()
        }))
      }
      
      alertController.addAction(UIAlertAction(title: cancelText, style: .cancel, handler: {
        action -> Void in
        UsageDataManager.shared.isRateDone = true
      }))
      
      if #available(iOS 9.0, *) {
        alertController.preferredAction = rateAction
      }
      
      host?.present(alertController, animated: true, completion: nil)
    }
  }
  
  private func rateAppWithAppStore() {
#if arch(i386) || arch(x86_64)
    print("APPIRATER NOTE: iTunes App Store is not supported on the iOS simulator. Unable to open App Store page.");
#else
    guard let appId = SwiftRater.appID else { return }
    let reviewURL = "itms-apps://itunes.apple.com/app/id\(appId)?action=write-review";
    guard let url = URL(string: reviewURL) else { return }
    UIApplication.shared.open(url, options: [:], completionHandler: nil)
#endif
  }
#endif
  
#if os(macOS)
  private func showRatingAlert(host: NSViewController?, force: Bool) {
    NSLog("[SwiftRater] Trying to show review request dialog.")
    if #available(macOS 10.14, *), SwiftRater.useStoreKitIfAvailable, !force {
      SKStoreReviewController.requestReview()
      UsageDataManager.shared.isRateDone = true
    } else {
      let alert = NSAlert()
      alert.messageText = titleText
      alert.informativeText = messageText
      alert.alertStyle = .warning
      alert.addButton(withTitle: rateText)
      if SwiftRater.showLaterButton {
        alert.addButton(withTitle: laterText)
      }
      alert.addButton(withTitle: cancelText)
      
      let result = alert.runModal()
      
      switch result {
      case .alertFirstButtonReturn:
        self.rateAppWithAppStore()
        UsageDataManager.shared.isRateDone = true
      case .alertSecondButtonReturn:
        if SwiftRater.showLaterButton {
          UsageDataManager.shared.saveReminderRequestDate()
        } else {
          UsageDataManager.shared.isRateDone = true
        }
      case .alertThirdButtonReturn:
        UsageDataManager.shared.isRateDone = true
      default:
        break
      }
    }
  }
  
  private func rateAppWithAppStore() {
    guard let appId = SwiftRater.appID else { return }
    let reviewURL = "itms-apps://itunes.apple.com/app/id\(appId)?action=write-review";
    guard let url = URL(string: reviewURL) else { return }
    NSWorkspace.shared.open(url)
  }
#endif
}

#if !SWIFT_PACKAGE
extension Bundle {
  static var module: Bundle {
    Bundle(for: SwiftRater.self)
  }
}
#endif
