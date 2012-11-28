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

  self.navigationItem.title = self.point.name;

  self.imageView.layer.cornerRadius = 4.f;
  self.imageView.clipsToBounds = YES;
  [self.imageView cancelImageRequestOperation];

  self.mapView.layer.cornerRadius = 4.f;

  self.distanceLabel.layer.cornerRadius = 4.f;
  self.distanceLabel.layer.borderColor = [UIColor blackColor].CGColor;
  self.distanceLabel.layer.borderWidth = 1.f;

  self.summaryTextView.layer.cornerRadius = 4.f;
  self.summaryTextView.layer.borderColor = [UIColor blackColor].CGColor;
  self.summaryTextView.layer.borderWidth = 1.f;
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  [self.imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_point.imageURLString]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
    [UIView transitionWithView:self.imageView duration:0.22 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
      self.imageView.image = image;
    } completion:nil];
  } failure:nil];

  [self.mapView addAnnotation:self.point];

  CLLocation *pointLocation = [[CLLocation alloc] initWithLatitude:self.point.coordinate.latitude longitude:self.point.coordinate.longitude];
  self.distanceLabel.text = [NSString stringWithFormat:@"%.0f m from you", [self.mapView.userLocation.location distanceFromLocation:pointLocation]];

  self.summaryTextView.text = self.point.summary;
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  [CYAnalytics logEvent:CYAnalyticsEventPointDetailVisited withParameters:nil];
  [self.mapView zoomToFitAnnotationsWithUser:NO animated:NO];
}

@end
