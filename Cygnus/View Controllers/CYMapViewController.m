//
//  CYMapViewController.m
//  Cygnus
//
//  Created by Adam Rothman on 10/24/12.
//  Copyright (c) 2012 Cygnus. All rights reserved.
//

#import "CYMapViewController.h"
#import "MKMapView+ARKit.h"

@interface CYMapViewController ()

@end

@implementation CYMapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];

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
  // Pass
}

@end
