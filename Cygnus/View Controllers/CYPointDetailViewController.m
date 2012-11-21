//
//  CYPointDetailViewController.m
//  Cygnus
//
//  Created by Juan-Carlos Foust on 11/14/12.
//  Copyright (c) 2012 Cygnus. All rights reserved.
//

#import "CYPointDetailViewController.h"
#import "MKMapView+ARKit.h"

@implementation CYPointDetailViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  [self.imageView cancelImageRequestOperation];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  NSLog(@"imageview in viewwillappear: %@", self.imageView);
  [self.imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_point.imageURLString]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
    [UIView transitionWithView:self.imageView duration:0.22 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
      self.imageView.image = image;
    } completion:nil];
  } failure:nil];

  [self.mapView addAnnotation:_point];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  [CYAnalytics logEvent:CYAnalyticsEventPointDetailVisited withParameters:nil];
  // todo(adam) this zooms too far here
  [self.mapView zoomToFitAnnotationsWithUser:NO animated:NO];
}

#pragma mark - Properties

- (void)setPoint:(CYPoint *)point {
  _point = point;
  if (_point) {
    self.navigationItem.title = _point.name;

    self.summaryTextView.text = _point.summary;
  }
}

@end
