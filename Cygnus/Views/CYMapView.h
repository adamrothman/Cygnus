//
//  CYMapView.h
//  Cygnus
//
//  Created by Juan-Carlos Foust on 11/8/12.
//  Copyright (c) 2012 Cygnus. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "MKMapView+ARKit.h"
#import "CYMap.h"
#import "CYPoint.h"

#define ONE_MILE_RADIUS 0.0144927536

@interface CYMapView : MKMapView

@property (nonatomic)   BOOL userDidInteract;
@property (nonatomic)   BOOL canEdit;

- (void)updateBeacon:(CLLocationCoordinate2D)beaconCoordinate;
- (void)updatePointsForMap:(CYMap *)map animated:(BOOL)animated;
- (void)removePointsForMap:(CYMap *)map;

@end