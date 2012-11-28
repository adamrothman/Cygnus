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

//  self.layer.borderWidth = 1.f;
//  self.layer.shadowOpacity = 0.5f;
//  self.layer.shadowOffset = CGSizeMake(0.f, 2.5f);
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
  self.distanceLabel.text = [NSString stringWithFormat:@"%.0f m", [self.mapView.userLocation.location distanceFromLocation:pointLocation]];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  [CYAnalytics logEvent:CYAnalyticsEventPointDetailVisited withParameters:nil];
  [self.mapView zoomToFitAnnotationsWithUser:YES animated:NO];
}

#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
  if (annotation == mapView.userLocation) return nil;

  static NSString *identifier = @"CYPointDetailViewControllerPin";
  MKPinAnnotationView *view = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
  if (!view) view = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];

  view.animatesDrop = NO;
  view.canShowCallout = NO;

  return view;
}

// prevent displaying current location callout
- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
  if (view.annotation == mapView.userLocation) [mapView deselectAnnotation:view.annotation animated:NO];
}

@end
