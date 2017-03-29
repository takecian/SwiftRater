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
    fileprivate var appID: Int?
    
    public init() {
        performVersionCheck()
    }
}

private enum SwiftRaterErrorCode: Int {
    case malformedURL = 1000
    case recentlyCheckedAlready
    case noUpdateAvailable
    case appStoreDataRetrievalFailure
    case appStoreJSONParsingFailure
    case appStoreOSVersionNumberFailure
    case appStoreOSVersionUnsupported
    case appStoreVersionNumberFailure
    case appStoreVersionArrayFailure
    case appStoreAppIDFailure
}

private enum SwiftRaterError: Error {
    case malformedURL
    case missingBundleIdOrAppId
}

private extension SwiftRater {
    
    func performVersionCheck() {
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
    
    func processResults(withData data: Data?, response: URLResponse?, error: Error?) {
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
    
    func processVersionCheck(withResults results: [String: Any]) {

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
        
        self.appID = appID
        
    }
    
    func iTunesURLFromString() throws -> URL {
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
    
    func postError(_ code: SwiftRaterErrorCode, underlyingError: Error?) {
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

    func printMessage(message: String) {
//        if debugEnabled {
            print("[Siren] \(message)")
//        }
    }
}
