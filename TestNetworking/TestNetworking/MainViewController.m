//
//  MainViewController.m
//  TestNetworking
//
//  Created by 杜宇 on 2018/12/18.
//  Copyright © 2018 杜宇. All rights reserved.
//

#import "MainViewController.h"
#import "ViewController.h"
#import "DKNetworkingTool.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.navigationController pushViewController:[[ViewController alloc] init] animated:YES];
}

@end
