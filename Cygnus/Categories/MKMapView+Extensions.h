//
//  MKMapView+Extensions.h
//  Cygnus
//
//  Created by Adam Rothman on 10/24/12.
//  Copyright (c) 2012 Cygnus. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface MKMapView (Extensions)

#define PADDING_MULTIPLIER  1.05
#define LATITUDE_PADDING    0.1
#define LONGITUDE_PADDING   0.1

// Returns map's annotations without the user's location
- (NSArray *)annotationsWithoutUserLocation;

// Zoom and center the map so that it displays the given annotation
- (void)zoomToFitAnnotation:(id<MKAnnotation>)annotation
                   animated:(BOOL)animated;

// Zoom and center the map so that it displays all of its annotations
- (void)zoomToFitAnnotationsAnimated:(BOOL)animated;

// Zoom and center the map so that it displays the user's location
- (void)zoomToFitUserAnimated:(BOOL)animated;

@end
