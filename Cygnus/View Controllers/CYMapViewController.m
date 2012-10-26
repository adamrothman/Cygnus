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

@interface CYMapViewController ()

@end

@implementation CYMapViewController

@synthesize map, menu;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  UIImage *background = [UIImage imageNamed:@"bg-menuitem.png"];
	UIImage *backgroundHighlighted = [UIImage imageNamed:@"bg-menuitem-highlighted.png"];
	UIImage *star = [UIImage imageNamed:@"icon-star.png"];

  NSArray *menus = @[
    [[AwesomeMenuItem alloc] initWithImage:background highlightedImage:backgroundHighlighted contentImage:star highlightedContentImage:nil],
    [[AwesomeMenuItem alloc] initWithImage:background highlightedImage:backgroundHighlighted contentImage:star highlightedContentImage:nil],
    [[AwesomeMenuItem alloc] initWithImage:background highlightedImage:backgroundHighlighted contentImage:star highlightedContentImage:nil],
    [[AwesomeMenuItem alloc] initWithImage:background highlightedImage:backgroundHighlighted contentImage:star highlightedContentImage:nil]
  ];

  self.menu = [[AwesomeMenu alloc] initWithFrame:self.map.bounds menus:menus];
  self.menu.delegate = self;
  self.menu.menuWholeAngle = M_PI_2;
  self.menu.rotateAngle = -M_PI_2;
  [self.map addSubview:self.menu];
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
  // Dispose of any resources that can be recreated.
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
  NSLog(@"Selected index %d", idx);
  switch (idx) {
    case 0:
      [self.map zoomToFitUserAnimated:YES];
      break;
    case 1:
      NSLog(@"This one will add a new item to the map?");
      break;
    case 2:
      break;
    case 3:
      break;
  }
}

@end
