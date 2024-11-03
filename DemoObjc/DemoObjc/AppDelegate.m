//
//  AppDelegate.m
//  DemoObjc
//
//  Created by Fujiki Takeshi on 2018/07/18.
//  Copyright © 2018 takecian. All rights reserved.
//

#import "AppDelegate.h"
@import SwiftRater;

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  SwiftRater.daysUntilPrompt = 1;
  SwiftRater.usesUntilPrompt = 1;
  SwiftRater.daysBeforeReminding = 1;
  SwiftRater.showLaterButton = true;
  SwiftRater.showLog = true;
//  SwiftRater.appID = @"1104775712"; // Optional, if you don't set appId, SwiftRater try to get app id from appstore.
//  SwiftRater.countryCode = @"fr"; // if your app is only avaiable for some coutnries, please add country code.
//  SwiftRater.debugMode = true; // need to set false when submitting to AppStore!!
  [SwiftRater appLaunched];

  return YES;
}

@end
