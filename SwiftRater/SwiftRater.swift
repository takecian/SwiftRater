//
//  SwiftRater.swift
//  SwiftRater
//
//  Created by Fujiki Takeshi on 2017/03/28.
//  Copyright © 2017年 com.takecian. All rights reserved.
//

import UIKit

public class SwiftRater {

    public let SwiftRaterErrorDomain = "Siren Error Domain"

    public static var daysUntilPrompt: Int {
        get {
            return UsageDataManager.shared.daysUntilPrompt
        }
        set {
            UsageDataManager.shared.daysUntilPrompt = newValue
        }
    }
    public static var usesUntilPrompt: Int {
        get {
            return UsageDataManager.shared.usesUntilPrompt
        }
        set {
            UsageDataManager.shared.usesUntilPrompt = newValue
        }
    }
    public static var significantUsesUntilPrompt: Int {
        get {
            return UsageDataManager.shared.significantUsesUntilPrompt
        }
        set {
            UsageDataManager.shared.significantUsesUntilPrompt = newValue
        }
    }

    public static var daysBeforeReminding: Int {
        get {
            return UsageDataManager.shared.daysBeforeReminding
        }
        set {
            UsageDataManager.shared.daysBeforeReminding = newValue
        }
    }
    public static var debugMode: Bool {
        get {
            return UsageDataManager.shared.debugMode
        }
        set {
            UsageDataManager.shared.debugMode = newValue
        }
    }

    public static var showLaterButton: Bool = true
    public static var resetWhenAppUpdated: Bool = false

    public static var shared = SwiftRater()

    private var appID: Int?
    private var appVersion: String?

    private init() {
    }

    public static func didFinishLaunching() {
        SwiftRater.shared.perform()
    }

    public static func incrementSignificantUsageCount() {
        UsageDataManager.shared.incrementSignificantUseCount()
        if UsageDataManager.shared.ratingConditionsHaveBeenMet {
            SwiftRater.shared.showRatingAlert()
        }
    }

    public static func reset() {
        UsageDataManager.shared.reset()
    }

    private func perform() {
        // get appID from itunes
        do {
            let url = try iTunesURLFromString()
            let request = URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 30)
            URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                self.processResults(withData: data, response: response, error: error)
            }).resume()
        } catch let error {
            postError(.malformedURL, underlyingError: error)
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
                    self.printMessage(message: "JSON results: \(appData)")

                    // Process Results (e.g., extract current version that is available on the AppStore)
                    self.processVersionCheck(withResults: appData)
                }

            } catch let error {
                self.postError(.appStoreDataRetrievalFailure, underlyingError: error)
            }
        }
    }

    private func processVersionCheck(withResults results: [String: Any]) {
        guard let allResults = results["results"] as? [[String: Any]] else {
            self.postError(.appStoreVersionNumberFailure, underlyingError: nil)
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
        guard let appVersion = allResults.first?["version"] as? String else {
            postError(.appStoreAppIDFailure, underlyingError: nil)
            return
        }

        self.appID = appID
        self.appVersion = appVersion
        incrementUsageCountAndVerify()
    }

    private func iTunesURLFromString() throws -> URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "itunes.apple.com"
        components.path = "/lookup"

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
        case .recentlyCheckedAlready:
            description = "Not checking the version, because it already checked recently."
        case .noUpdateAvailable:
            description = "No new update available."
        case .appStoreDataRetrievalFailure:
            description = "Error retrieving App Store data as an error was returned."
        case .appStoreJSONParsingFailure:
            description = "Error parsing App Store JSON data."
        case .appStoreOSVersionNumberFailure:
            description = "Error retrieving iOS version number as there was no data returned."
        case .appStoreOSVersionUnsupported:
            description = "The version of iOS on the device is lower than that of the one required by the app verison update."
        case .appStoreVersionNumberFailure:
            description = "Error retrieving App Store version number as there was no data returned."
        case .appStoreVersionArrayFailure:
            description = "Error retrieving App Store verson number as results.first does not contain a 'version' key."
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
        if SwiftRater.debugMode {
            print("[SwiftRater] \(message)")
        }
    }

    private func incrementUsageCountAndVerify() {
        UsageDataManager.shared.incrementUseCount()
        if UsageDataManager.shared.ratingConditionsHaveBeenMet {
            showRatingAlert()
        }
    }

    private func incrementSignificantUseCountAndVerify() {
        UsageDataManager.shared.incrementSignificantUseCount()
        if UsageDataManager.shared.ratingConditionsHaveBeenMet {
            showRatingAlert()
        }
    }

    private func showRatingAlert() {

    }

    //    - (void)showRatingAlert:(BOOL)displayRateLaterButton {
    //    UIAlertView *alertView = nil;
    //    id <AppiraterDelegate> delegate = _delegate;
    //
    //    if(delegate && [delegate respondsToSelector:@selector(appiraterShouldDisplayAlert:)] && ![delegate appiraterShouldDisplayAlert:self]) {
    //    return;
    //    }
    //
    //    if (displayRateLaterButton) {
    //    alertView = [[UIAlertView alloc] initWithTitle:self.alertTitle
    //    message:self.alertMessage
    //    delegate:self
    //    cancelButtonTitle:self.alertCancelTitle
    //    otherButtonTitles:self.alertRateTitle, self.alertRateLaterTitle, nil];
    //    } else {
    //    alertView = [[UIAlertView alloc] initWithTitle:self.alertTitle
    //    message:self.alertMessage
    //    delegate:self
    //    cancelButtonTitle:self.alertCancelTitle
    //    otherButtonTitles:self.alertRateTitle, nil];
    //    }
    //
    //    self.ratingAlert = alertView;
    //    [alertView show];
    //
    //    if (delegate && [delegate respondsToSelector:@selector(appiraterDidDisplayAlert:)]) {
    //    [delegate appiraterDidDisplayAlert:self];
    //    }
    //    }

    //    [Appirater setDaysUntilPrompt:7];
    //    [Appirater setUsesUntilPrompt:5];
    //    [Appirater setSignificantEventsUntilPrompt:-1];
    //    [Appirater setTimeBeforeReminding:2];
    //    [Appirater setDebug:NO];
    //    [Appirater appLaunched:YES];
}
