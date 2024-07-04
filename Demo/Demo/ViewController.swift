//
//  ViewController.swift
//  Demo
//
//  Created by Fujiki Takeshi on 2017/03/28.
//  Copyright © 2017年 com.takecian. All rights reserved.
//

import UIKit
import SwiftRater

class ViewController: UIViewController {

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        SwiftRater.incrementSignificantUsageCount()
        // If you want to meet the condition for testing purpose, use this.
        //  SwiftRater.debugMode = true
        SwiftRater.check(host: self)

        // If your want to show rating dialog manually, use `rateApp()`.
        // SwiftRater.rateApp(host: self)
    }

}
