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

        SwiftRater.daysUntilPrompt = 1
        SwiftRater.usesUntilPrompt = 1
        SwiftRater.daysBeforeReminding = 1
        SwiftRater.showLaterButton = true
        SwiftRater.showLog = true
//        SwiftRater.debugMode = true // need to set false when submitting to AppStore!!
        SwiftRater.appLaunched()

        return true
    }

}
