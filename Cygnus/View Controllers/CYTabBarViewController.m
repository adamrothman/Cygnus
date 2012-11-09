//
//  CYTabBarViewController.m
//  Cygnus
//
//  Created by Juan-Carlos Foust on 11/2/12.
//  Copyright (c) 2012 Cygnus. All rights reserved.
//

#import "CYTabBarViewController.h"
#import "CYMapViewController.h"

@interface CYTabBarViewController ()

@end

@implementation CYTabBarViewController


- (void)setSelectedViewController:(UIViewController *)selectedViewController
{
  if (self.selectedViewController == selectedViewController && selectedViewController == [CYMapViewController currentVC]) {
    [[CYMapViewController currentVC] toggleBeaconHUD];
  }
  [super setSelectedViewController:selectedViewController];
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex
{
  if (self.selectedIndex == 1 && selectedIndex == 1) [[CYMapViewController currentVC] toggleBeaconHUD];
  [super setSelectedIndex:selectedIndex];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setSelectedIndex:1];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
