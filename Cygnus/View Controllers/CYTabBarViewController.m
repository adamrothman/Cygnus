//
//  CYTabBarViewController.m
//  Cygnus
//
//  Created by Juan-Carlos Foust on 11/2/12.
//  Copyright (c) 2012 Cygnus. All rights reserved.
//

#import "CYTabBarViewController.h"
#import "CYMapViewController.h"

CYTabBarViewController *_currentVC = nil;

@interface CYTabBarViewController ()

@end

@implementation CYTabBarViewController


- (void)setSelectedViewController:(UIViewController *)selectedViewController
{
  if (self.selectedViewController == selectedViewController && self.viewControllers[1] == selectedViewController) {
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
  _currentVC = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
  [super viewDidUnload];
  _currentVC = nil;
}

+ (CYTabBarViewController *)currentVC
{
  return _currentVC;
}
@end
