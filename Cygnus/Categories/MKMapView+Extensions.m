//
//  MKMapView+Extensions.m
//  Cygnus
//
//  Created by Adam Rothman on 10/24/12.
//  Copyright (c) 2012 Cygnus. All rights reserved.
//

#import "MKMapView+Extensions.h"

@implementation MKMapView (Extensions)

- (NSArray *)annotationsWithoutUserLocation {
  if (!self.userLocation) return self.annotations;

  NSMutableArray *annotations = [NSMutableArray arrayWithArray:self.annotations];
  [annotations removeObject:self.userLocation];
  return annotations;
}

- (void)zoomToFitAnnotation:(id<MKAnnotation>)annotation
                   animated:(BOOL)animated {
  MKCoordinateRegion region = MKCoordinateRegionMake(annotation.coordinate,
                                                     MKCoordinateSpanMake(LATITUDE_PADDING, LONGITUDE_PADDING));

  [self setRegion:[self regionThatFits:region] animated:animated];
}

- (void)zoomToFitAnnotationsAnimated:(BOOL)animated {
  if ([self.annotations count]) {
    CLLocationCoordinate2D topLeft = CLLocationCoordinate2DMake(-90, 180);
    CLLocationCoordinate2D bottomRight = CLLocationCoordinate2DMake(90, -180);

    for (id<MKAnnotation> annotation in self.annotations) {
      topLeft.latitude = fmax(topLeft.latitude, annotation.coordinate.latitude);
      topLeft.longitude = fmin(topLeft.longitude, annotation.coordinate.longitude);

      bottomRight.latitude = fmin(bottomRight.latitude, annotation.coordinate.latitude);
      bottomRight.longitude = fmax(bottomRight.longitude, annotation.coordinate.longitude);
    }

    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(topLeft.latitude - (topLeft.latitude - bottomRight.latitude) / 2,
                                                               topLeft.longitude + (bottomRight.longitude - topLeft.longitude) / 2);
    MKCoordinateSpan span = MKCoordinateSpanMake(fabs(topLeft.latitude - bottomRight.latitude) * PADDING_MULTIPLIER,
                                                 fabs(bottomRight.longitude - topLeft.longitude) * PADDING_MULTIPLIER);
    MKCoordinateRegion region = MKCoordinateRegionMake(center, span);

    [self setRegion:[self regionThatFits:region] animated:animated];
  }
}

- (void)zoomToFitUserAnimated:(BOOL)animated {
  if (self.showsUserLocation) {
    MKCoordinateRegion region = MKCoordinateRegionMake(self.userLocation.location.coordinate,
                                                       MKCoordinateSpanMake(LATITUDE_PADDING, LONGITUDE_PADDING));

    [self setRegion:[self regionThatFits:region] animated:animated];
  }
}

@end
