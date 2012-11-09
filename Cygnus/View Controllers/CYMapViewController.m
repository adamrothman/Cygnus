//
//  CYMapViewController.m
//  Cygnus
//
//  Created by Adam Rothman on 10/24/12.
//  Copyright (c) 2012 Cygnus. All rights reserved.
//

#import "CYMapViewController.h"
#import "CYMap.h"

#import "CYUI.h"
#import "CYBeaconHUD.h"
#import "CYMapView.h"
#import "AwesomeMenuItem.h"

CYMapViewController *_currentVC;


@interface CYMapViewController ()

@property (strong, nonatomic)   CYBeaconHUD *beaconHUD;

@end

@implementation CYMapViewController

@synthesize mapView;//, menu;


#pragma mark - VC Lifecycle

- (void)viewDidLoad {
  [super viewDidLoad];
  _currentVC = self;
  self.beaconHUD = [[CYBeaconHUD alloc] init];
  [self.view addSubview:self.beaconHUD];
  
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  [self.beaconHUD hide];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
    
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
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
      [self.mapView zoomToFitUserAnimated:YES];
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

//CYGroup __block *defaultGroup = [[CYGroup alloc] init];
//defaultGroup.name = @"Stanford Public";
//defaultGroup.summary = @"Public group for Stanford area: students, faculty, staff.";
//defaultGroup.visibility = CYGroupVisibilityPublic;
//[defaultGroup addOwner:[CYUser currentUser]];
//[defaultGroup addMember:[CYUser currentUser]];
//
//PFQuery *query = [PFQuery queryWithClassName:@"Map"];
//[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//  if (!error) {
//    PFObject *libMap = [objects lastObject];
//    [defaultGroup addMap:[CYMap mapWithObject:libMap]];
//    [defaultGroup save];
//  } else {
//    // Log details of the failure
//    NSLog(@"Error: %@ %@", error, [error userInfo]);
//  }
//}];


//  UIImage *background = [UIImage imageNamed:@"bg-menuitem.png"];
//	UIImage *backgroundHighlighted = [UIImage imageNamed:@"bg-menuitem-highlighted.png"];
//  UIImage *eye = [UIImage imageNamed:@"04-eye-white.png"];
//  UIImage *pin = [UIImage imageNamed:@"08-pin-white.png"];
//  UIImage *star = [UIImage imageNamed:@"icon-star.png"];

//  NSArray *menus = @[
//    [[AwesomeMenuItem alloc] initWithImage:background highlightedImage:backgroundHighlighted contentImage:eye highlightedContentImage:nil],
//    [[AwesomeMenuItem alloc] initWithImage:background highlightedImage:backgroundHighlighted contentImage:pin highlightedContentImage:nil],
//    [[AwesomeMenuItem alloc] initWithImage:background highlightedImage:backgroundHighlighted contentImage:star highlightedContentImage:nil],
//    [[AwesomeMenuItem alloc] initWithImage:background highlightedImage:backgroundHighlighted contentImage:star highlightedContentImage:nil]
//  ];
//  self.menu = [[AwesomeMenu alloc] initWithFrame:self.map.bounds menus:menus];
//  self.menu.delegate = self;
//  self.menu.menuWholeAngle = M_PI_2;
//  self.menu.rotateAngle = -M_PI_2;
//  [self.map addSubview:self.menu];

//  self.menu.startPoint = CGPointMake(self.map.bounds.size.width - 32, self.map.bounds.size.height - 32);
// this isn't useful until the user has actually been located, so
// do it after a second (this is highly scientific)
