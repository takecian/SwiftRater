//
//  AppDelegate.swift
//  Demo
//
//  Created by Fujiki Takeshi on 2017/03/28.
//  Copyright © 2017年 com.takecian. All rights reserved.
//

import UIKit
import SwiftRater

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        SwiftRater.conditionsMetMode = .any
        SwiftRater.daysUntilPrompt = 1
        SwiftRater.usesUntilPrompt = 3
        SwiftRater.significantUsesUntilPrompt = 5
        SwiftRater.daysBeforeReminding = 1
        SwiftRater.showLaterButton = true
        SwiftRater.showLog = true
//        SwiftRater.appID = "1104775712" // Optional, if you don't set appId, SwiftRater try to get app id from appstore.
//        SwiftRater.countryCode = "fr" // if your app is only avaiable for some coutnries, please add country code.
//        SwiftRater.debugMode = true // need to set false when submitting to AppStore!!
        SwiftRater.appLaunched()

        return true
    }

}
