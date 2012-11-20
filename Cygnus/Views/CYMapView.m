//
//  CYMapView.m
//  Cygnus
//
//  Created by Juan-Carlos Foust on 11/8/12.
//  Copyright (c) 2012 Cygnus. All rights reserved.
//

#import "CYMapView.h"
#import "CYUser+Additions.h"
#import "CYPoint.h"

@implementation CYMapView

#pragma mark - Properties

- (void)setMap:(CYMap *)map {
  _map = map;
  [self removeAnnotations:self.annotations];
  [self addAnnotations:_map.points.array];
}

@end
