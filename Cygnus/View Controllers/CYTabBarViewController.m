//
//  CYTabBarViewController.m
//  Cygnus
//
//  Created by Juan-Carlos Foust on 11/2/12.
//  Copyright (c) 2012 Cygnus. All rights reserved.
//

#import "CYTabBarViewController.h"
#import "CYMapViewController.h"
#import "CYUI.h"

CYTabBarViewController *_currentVC = nil;

@interface CYTabBarViewController ()

@end

@implementation CYTabBarViewController


- (void)setSelectedViewController:(UIViewController *)selectedViewController
{
//  if (self.selectedViewController == selectedViewController && self.viewControllers[1] == selectedViewController) //do something cool on double tap on mapVC
  [super setSelectedViewController:selectedViewController];
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex
{
//  if (self.selectedIndex == 1 && selectedIndex == 1) //do something cool on double tap on mapVC
  [super setSelectedIndex:selectedIndex];
}


- (void)viewDidLoad
{
  [super viewDidLoad];
  [self setSelectedIndex:2];
  
  [[UINavigationBar appearance] setBackgroundImage:[UIImage imageFromDiskNamed:@"tab-bar-background.png"] forBarMetrics:UIBarMetricsDefault];
  [[UITabBar appearance] setBackgroundImage:[UIImage imageFromDiskNamed:@"tab-bar-background.png"]];
  [[UITabBar appearance] setSelectionIndicatorImage:[[UIImage alloc] init]];
  [[UITableViewCell appearance] setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.8]];
  
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
