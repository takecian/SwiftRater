//
//  SwiftRaterBundleExtension.swift
//  SwiftRater
//
//  Created by FUJIKI TAKESHI on 2017/03/29.
//  Copyright © 2017 com.takecian. All rights reserved.
//

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

internal extension Bundle {

    class func bundleID() -> String? {
        return Bundle.main.bundleIdentifier
    }

}
