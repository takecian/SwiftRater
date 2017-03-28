//
//  SwiftRater.swift
//  SwiftRater
//
//  Created by Fujiki Takeshi on 2017/03/28.
//  Copyright © 2017年 com.takecian. All rights reserved.
//

import UIKit

public class SwiftRater {

    public static var daysUntilPrompt: Int {
        get {
            return UsageDataManager.shared.daysUntilPrompt
        }
        set {
            UsageDataManager.shared.daysUntilPrompt = newValue
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

    public static var showLaterButton: Bool = true
    public static var debugMode: Bool = false

    public static func didFinishLaunching() {

    }

    private static var shared = SwiftRater()

    private init() {

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
