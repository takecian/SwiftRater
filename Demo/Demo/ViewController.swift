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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        SwiftRater.daysUntilPrompt = 1
        SwiftRater.didFinishLaunching()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

