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
        SwiftRater.check(host: self)

        // If want to navigate app review page, use `rateApp()`.
        // SwiftRater.rateApp()
    }

}
