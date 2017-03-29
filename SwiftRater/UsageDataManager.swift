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
    static private let keySwiftRaterCurrentVersion = "keySwiftRaterCurrentVersion"
    static private let keySwiftRaterRatedCurrentVersion = "keySwiftRaterRatedCurrentVersion"
    static private let keySwiftRaterDeclinedToRate = "keySwiftRaterDeclinedToRate"
    static private let keySwiftRaterReminderRequestDate = "keySwiftRaterReminderRequestDate"

    static var shared = UsageDataManager()

    let userDefaults = UserDefaults.standard

    private init() {
        let defaults = [
            UsageDataManager.keySwiftRaterFirstUseDate: 0,
            UsageDataManager.keySwiftRaterUseCount: 0,
            UsageDataManager.keySwiftRaterSignificantEventCount: 0,
            UsageDataManager.keySwiftRaterDeclinedToRate: false,
            UsageDataManager.keySwiftRaterReminderRequestDate: 0
            ] as [String : Any]
        let ud = UserDefaults.standard
        ud.register(defaults: defaults)
    }

    var firstUseDate: TimeInterval {
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

    var ratingConditionsHaveBeenMet: Bool {
        guard !debugMode else { return true }

        return false
    }

    func reset() {
        userDefaults.set(0, forKey: UsageDataManager.keySwiftRaterFirstUseDate)
        userDefaults.set(0, forKey: UsageDataManager.keySwiftRaterUseCount)
        userDefaults.set(0, forKey: UsageDataManager.keySwiftRaterSignificantEventCount)
        userDefaults.set(false, forKey: UsageDataManager.keySwiftRaterDeclinedToRate)
        userDefaults.set(0, forKey: UsageDataManager.keySwiftRaterReminderRequestDate)
        userDefaults.synchronize()
    }

    func incrementUseCount() {

    }

    func incrementSignificantUseCount() {

    }
}
