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

@interface CYMapView () <MKMapViewDelegate>

@property (strong, nonatomic) NSMutableDictionary *mapAnnotations;

@end

@implementation CYMapView

- (id)initWithFrame:(CGRect)frame {
  if ((self = [super initWithFrame:frame])) {
    [self setUp];
  }
  return self;
}

- (void)awakeFromNib {
  [super awakeFromNib];
  [self setUp];
}

- (void)setUp {
  self.showsUserLocation = YES;
  self.mapAnnotations = [NSMutableDictionary dictionaryWithCapacity:5];
}

- (void)updatePointsForMap:(CYMap *)map animated:(BOOL)animated {
  [self removeAnnotations:self.mapAnnotations[map.objectID]];
  if (!map.points) return;
  self.mapAnnotations[map.objectID] = map.points.array;
  [self addAnnotations:map.points.array];
}

- (void)removePointsForMap:(CYMap *)map {
  [self removeAnnotations:self.mapAnnotations[map.objectID]];
  [self.mapAnnotations removeObjectForKey:map.objectID];
}



@end
