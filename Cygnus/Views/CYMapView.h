//
//  CYMapView.h
//  Cygnus
//
//  Created by Juan-Carlos Foust on 11/8/12.
//  Copyright (c) 2012 Cygnus. All rights reserved.
//

#import "MKMapView+ARKit.h"
#import "CYMap.h"
#import "CYPoint.h"

#define ONE_MILE_RADIUS 0.0144927536

@protocol CYMapEditorDelegate <NSObject>
- (void)userDidAddPoint:(CYPoint *)point;
@end

@interface CYMapView : MKMapView

- (void)updatePointsForMap:(CYMap *)map animated:(BOOL)animated;
- (void)removePointsForMap:(CYMap *)map;

@end