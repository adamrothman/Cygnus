//
//  CYPoint.m
//  Cygnus
//
//  Created by Adam Rothman on 10/28/12.
//  Copyright (c) 2012 Cygnus. All rights reserved.
//

#import "CYPoint.h"

static NSString *const CYPointLocationKey = @"location";
static NSString *const CYPointNameKey = @"name";
static NSString *const CYPointSummaryKey = @"summary";
static NSString *const CYPointImageURLKey = @"image_url";

static NSString *const CYPointMapKey = @"map";

@implementation CYPoint

@synthesize map=_map, location = _location;

#pragma mark - Object creation and update

- (id)init {
  if ((self = [super init])) {
    self.backingObject = [PFObject objectWithClassName:@"Point"];
    PFGeoPoint *geoPoint = [self.backingObject objectForKey:CYPointLocationKey];
    self.location = [[CLLocation alloc] initWithLatitude:geoPoint.latitude longitude:geoPoint.longitude];
  }
  return self;
}

+ (CYPoint *)pointWithObject:(PFObject *)object {
  CYPoint *point = [[CYPoint alloc] initWithObject:object];
  PFGeoPoint *geoPoint = [object objectForKey:CYPointLocationKey];
  point.location = [[CLLocation alloc] initWithLatitude:geoPoint.latitude longitude:geoPoint.longitude];
  return point;
}

- (void)refreshWithBlock:(CYPointResultBlock)block {
  [self.backingObject refreshInBackgroundWithBlock:^(PFObject *object, NSError *error) {
    if (error) {
      NSLog(@"%@\n", error);
      if (block) block(nil, error);
    } else {
      if (block) block([CYPoint pointWithObject:object], nil);
    }
  }];
}

#pragma mark - Properties

- (CLLocation *)location {
  return _location;
}

- (void)setLocation:(CLLocation *)location {
  [self.backingObject setObject:[PFGeoPoint geoPointWithLocation:location] forKey:CYPointLocationKey];
  [self save];
  _location = location;
}

- (NSString *)name {
  return [self.backingObject objectForKey:CYPointNameKey];
}

- (void)setName:(NSString *)name {
  [self.backingObject setObject:name forKey:CYPointNameKey];
  [self save];
}

- (NSString *)summary {
  return [self.backingObject objectForKey:CYPointSummaryKey];
}

- (void)setSummary:(NSString *)summary {
  [self.backingObject setObject:summary forKey:CYPointSummaryKey];
  [self save];
}

- (NSString *)imageURLString {
  return [self.backingObject objectForKey:CYPointImageURLKey];
}

- (void)setImageURLString:(NSString *)imageURLString {
  [self.backingObject setObject:imageURLString forKey:CYPointImageURLKey];
  [self save];
}

#pragma mark - MKAnnotation

- (CLLocationCoordinate2D)coordinate {
  return self.location.coordinate;
}

- (NSString *)title {
  return self.name;
}

- (NSString *)subtitle {
  return self.summary;
}

#pragma mark - Relations

- (CYMap *)map {
  if (!_map) _map = [CYMap mapWithObject:[self.backingObject objectForKey:CYPointMapKey]];
  [_map.backingObject fetchIfNeeded];
  return _map;
}

- (void)setMap:(CYMap *)map {
  _map = map;
  [self.backingObject setObject:_map.backingObject forKey:CYPointMapKey];
  [self save];
}

@end
