//
//  CYPoint.m
//  Cygnus
//
//  Created by Adam Rothman on 10/28/12.
//  Copyright (c) 2012 Cygnus. All rights reserved.
//

#import "CYPoint.h"

#define LOCATION_KEY  @"location"
#define NAME_KEY      @"name"
#define SUMMARY_KEY   @"summary"
#define IMAGE_URL_KEY @"image_url"

#define MAP_KEY       @"map"

@implementation CYPoint

@synthesize backingObject=_backingObject;

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

#pragma mark - Properties

- (PFGeoPoint *)location {
  return [self.backingObject objectForKey:LOCATION_KEY];
}

- (void)setLocation:(PFGeoPoint *)location {
  [self.backingObject setObject:location forKey:LOCATION_KEY];
  [self save];
}

- (NSString *)name {
  return [self.backingObject objectForKey:NAME_KEY];
}

- (void)setName:(NSString *)name {
  [self.backingObject setObject:name forKey:NAME_KEY];
  [self save];
}

- (NSString *)summary {
  return [self.backingObject objectForKey:SUMMARY_KEY];
}

- (void)setSummary:(NSString *)summary {
  [self.backingObject setObject:summary forKey:SUMMARY_KEY];
  [self save];
}

- (NSString *)imageURLString {
  return [self.backingObject objectForKey:IMAGE_URL_KEY];
}

- (void)setImageURLString:(NSString *)imageURLString {
  [self.backingObject setObject:imageURLString forKey:IMAGE_URL_KEY];
  [self save];
}

#pragma mark - Relations

- (CYMap *)map {
  return [CYMap mapWithObject:[[self.backingObject objectForKey:MAP_KEY] fetchIfNeeded]];
}

@end
