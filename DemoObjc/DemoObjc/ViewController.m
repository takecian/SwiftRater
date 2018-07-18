//
//  ViewController.m
//  DemoObjc
//
//  Created by Fujiki Takeshi on 2018/07/18.
//  Copyright © 2018 takecian. All rights reserved.
//

#import "ViewController.h"
@import SwiftRater;

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [SwiftRater rateApp];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
