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

@synthesize map=_map;

#pragma mark - Object creation and update

- (id)init {
  if ((self = [super init])) {
    self.backingObject = [PFObject objectWithClassName:@"Point"];
  }
  return self;
}

+ (CYPoint *)pointWithObject:(PFObject *)object {
  return [[CYPoint alloc] initWithObject:object];
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

- (PFGeoPoint *)location {
  return [self.backingObject objectForKey:CYPointLocationKey];
}

- (void)setLocation:(PFGeoPoint *)location {
  [self.backingObject setObject:location forKey:CYPointLocationKey];
  [self save];
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
