//
//  UsageDataManager.swift
//  SwiftRater
//
//  Created by Fujiki Takeshi on 2017/03/28.
//  Copyright © 2017年 com.takecian. All rights reserved.
//

import UIKit

let SwiftRaterInvalid = -1

class UsageDataManager {

    var daysUntilPrompt: Int = SwiftRaterInvalid
    var usesUntilPrompt: Int = SwiftRaterInvalid
    var significantUsesUntilPrompt: Int = SwiftRaterInvalid
    var daysBeforeReminding: Int = SwiftRaterInvalid

    var showLaterButton: Bool = true
    var debugMode: Bool = false

    static private let keySwiftRaterFirstUseDate = "keySwiftRaterFirstUseDate"
    static private let keySwiftRaterUseCount = "keySwiftRaterUseCount"
    static private let keySwiftRaterSignificantEventCount = "keySwiftRaterSignificantEventCount"
    static private let keySwiftRaterRateDone = "keySwiftRaterRateDone"
    static private let keySwiftRaterTrackingVersion = "keySwiftRaterTrackingVersion"
    static private let keySwiftRaterReminderRequestDate = "keySwiftRaterReminderRequestDate"

    static var shared = UsageDataManager()

    let userDefaults = UserDefaults.standard

    private init() {
        let defaults = [
            UsageDataManager.keySwiftRaterFirstUseDate: 0,
            UsageDataManager.keySwiftRaterUseCount: 0,
            UsageDataManager.keySwiftRaterSignificantEventCount: 0,
            UsageDataManager.keySwiftRaterRateDone: false,
            UsageDataManager.keySwiftRaterTrackingVersion: "",
            UsageDataManager.keySwiftRaterReminderRequestDate: 0
            ] as [String : Any]
        let ud = UserDefaults.standard
        ud.register(defaults: defaults)
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

        if reminderRequestToRate == 0 {
            // check if the app has been used enough days
            if daysUntilPrompt != SwiftRaterInvalid {
                printMessage(message: " will check daysUntilPrompt")
                let dateOfFirstLaunch = Date(timeIntervalSince1970: firstUseDate)
                let timeSinceFirstLaunch = Date().timeIntervalSince(dateOfFirstLaunch)
                let timeUntilRate = 60 * 60 * 24 * daysUntilPrompt;
                guard Int(timeSinceFirstLaunch) < timeUntilRate else { return true }
            }

            // check if the app has been used enough times
            if usesUntilPrompt != SwiftRaterInvalid {
                printMessage(message: " will check usesUntilPrompt")
                guard usesCount <= usesUntilPrompt else { return true }
            }

            // check if the user has done enough significant events
            if significantUsesUntilPrompt != SwiftRaterInvalid {
                printMessage(message: " will check significantUsesUntilPrompt")
                guard significantEventCount <= significantUsesUntilPrompt else { return true }
            }
        } else {
            // if the user wanted to be reminded later, has enough time passed?
            if daysBeforeReminding != SwiftRaterInvalid {
                printMessage(message: " will check daysBeforeReminding")
                let dateOfReminderRequest = Date(timeIntervalSince1970: reminderRequestToRate)
                let timeSinceReminderRequest = Date().timeIntervalSince(dateOfReminderRequest)
                let timeUntilRate = 60 * 60 * 24 * daysBeforeReminding;
                guard Int(timeSinceReminderRequest) < timeUntilRate else { return true }
            }
        }

        return false
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
        usesCount = usesCount + 1
    }

    func incrementSignificantUseCount() {
        significantEventCount = significantEventCount + 1
    }

    func saveReminderRequestDate() {
        reminderRequestToRate = Date().timeIntervalSince1970
    }
    
    private func printMessage(message: String) {
        if SwiftRater.showLog {
            print("[SwiftRater] \(message)")
        }
    }
}
