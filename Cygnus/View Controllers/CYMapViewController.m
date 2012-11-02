//
//  CYMapViewController.m
//  Cygnus
//
//  Created by Adam Rothman on 10/24/12.
//  Copyright (c) 2012 Cygnus. All rights reserved.
//

#import "CYMapViewController.h"
#import "MKMapView+ARKit.h"
#import "AwesomeMenuItem.h"
#import "CYBeaconHUD.h"
#import "CYMap.h"
#import "CYUI.h"

CYMapViewController *_currentVC;


@interface CYMapViewController ()

@property (strong, nonatomic)   CYBeaconHUD *beaconHUD;

@end

@implementation CYMapViewController

@synthesize map, menu;




#pragma mark - VC Lifecycle

- (void)viewDidLoad {
  [super viewDidLoad];
  _currentVC = self;
  
  UIImage *background = [UIImage imageNamed:@"bg-menuitem.png"];
	UIImage *backgroundHighlighted = [UIImage imageNamed:@"bg-menuitem-highlighted.png"];
  UIImage *eye = [UIImage imageNamed:@"04-eye-white.png"];
  UIImage *pin = [UIImage imageNamed:@"08-pin-white.png"];
  UIImage *star = [UIImage imageNamed:@"icon-star.png"];

  NSArray *menus = @[
    [[AwesomeMenuItem alloc] initWithImage:background highlightedImage:backgroundHighlighted contentImage:eye highlightedContentImage:nil],
    [[AwesomeMenuItem alloc] initWithImage:background highlightedImage:backgroundHighlighted contentImage:pin highlightedContentImage:nil],
    [[AwesomeMenuItem alloc] initWithImage:background highlightedImage:backgroundHighlighted contentImage:star highlightedContentImage:nil],
    [[AwesomeMenuItem alloc] initWithImage:background highlightedImage:backgroundHighlighted contentImage:star highlightedContentImage:nil]
  ];

  self.menu = [[AwesomeMenu alloc] initWithFrame:self.map.bounds menus:menus];
  self.menu.delegate = self;
  self.menu.menuWholeAngle = M_PI_2;
  self.menu.rotateAngle = -M_PI_2;
  [self.map addSubview:self.menu];
  
  self.beaconHUD = [[CYBeaconHUD alloc] init];
  [self.view addSubview:self.beaconHUD];
  
//  CYMap *libMap = [[CYMap alloc] init];
//  libMap.name = @"Campus Libraries";
//  libMap.name = @"Collection of libraries big and small accross the Farm.";
//  libMap.visibility = CYMapVisibilityPublic;
  
  PFQuery *query = [PFQuery queryWithClassName:@"Point"];
  [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
    if (!error) {
      NSLog(@"Successfully retrieved points - %@", objects);
    } else {
      // Log details of the failure
      NSLog(@"Error: %@ %@", error, [error userInfo]);
    }
  }];
  

}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];

  self.menu.startPoint = CGPointMake(self.map.bounds.size.width - 32, self.map.bounds.size.height - 32);

  // this isn't useful until the user has actually been located, so
  // do it after a second (this is highly scientific)
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
    [self.map zoomToFitUserAnimated:animated];
  });
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated
}

- (void)viewDidUnload
{
  [super viewDidUnload];
  _currentVC = nil;
}

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView didChangeUserTrackingMode:(MKUserTrackingMode)mode animated:(BOOL)animated {
  switch (mode) {
    case MKUserTrackingModeNone:
      NSLog(@"Map view changed userTrackingMode to MKUserTrackingModeNone");
      break;
    case MKUserTrackingModeFollow:
      NSLog(@"Map view changed userTrackingMode to MKUserTrackingModeFollow");
      break;
    case MKUserTrackingModeFollowWithHeading:
      NSLog(@"Map view changed userTrackingMode to MKUserTrackingModeFollowWithHeading");
      break;
  }
}

#pragma mark - AwesomeMenuDelegate

- (void)menu:(AwesomeMenu *)menu didSelectIndex:(NSInteger)idx {
//  NSLog(@"Selected index %d", idx);
  switch (idx) {
    case 0:
      [self.map zoomToFitUserAnimated:YES];
      break;
    case 1:
      NSLog(@"Option2");
      break;
    case 2:
      NSLog(@"Option3");

      break;
    case 3:
      break;
  }
}

#pragma mark - CYTabBar

- (void)toggleBeaconHUD {
  if (self.beaconHUD.yOrigin < self.view.height) {
    [self.beaconHUD hide];
  } else {
    [self.beaconHUD showPartial];
  }
}

+ (CYMapViewController *)currentVC
{
  return _currentVC;
}

@end
