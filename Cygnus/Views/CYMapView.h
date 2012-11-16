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
- (void)userDidDropPin:(id<MKAnnotation>)newPointAnnotation;
- (void)userDidAddPoint:(CYPoint *)point;
@end

@interface CYMapView : MKMapView

@property (weak, nonatomic) id<CYMapEditorDelegate>editorDelegate;
@property (strong, nonatomic) id<MKAnnotation> userPointAnnotation;
@property (nonatomic) BOOL userDidInteract;
@property (nonatomic) BOOL canEdit;

- (void)updateBeacon:(CLLocationCoordinate2D)beaconCoordinate;
- (void)updatePointsForMap:(CYMap *)map animated:(BOOL)animated;
- (void)removePointsForMap:(CYMap *)map;

@end