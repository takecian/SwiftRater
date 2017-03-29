//
//  SwiftRaterErrorCode.swift
//  SwiftRater
//
//  Created by Fujiki Takeshi on 2017/03/29.
//  Copyright © 2017年 com.takecian. All rights reserved.
//

import UIKit

enum SwiftRaterErrorCode: Int {
    case malformedURL = 1000
    case appStoreDataRetrievalFailure
    case appStoreJSONParsingFailure
    case appStoreAppIDFailure
}
