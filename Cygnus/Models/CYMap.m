//
//  CYMap.m
//  Cygnus
//
//  Created by Adam Rothman on 10/28/12.
//  Copyright (c) 2012 Cygnus. All rights reserved.
//

#import "CYMap.h"
#import "CYPoint.h"

#define SAVE_DELAY  4.0

#define NAME_KEY        @"name"
#define SUMMARY_KEY     @"summary"
#define VISIBILITY_KEY  @"visibility"

#define POINTS_KEY      @"points"

@implementation CYMap

@synthesize backingObject=_backingObject;

#pragma mark - Object creation and update

- (id)init {
  if ((self = [super init])) {
    self.backingObject = [PFObject objectWithClassName:@"Map"];
  }
  return self;
}

- (id)initWithObject:(PFObject *)object {
  if ((self = [super init])) {
    self.backingObject = object;
  }
  return self;
}

+ (CYMap *)mapWithObject:(PFObject *)object {
  return [[CYMap alloc] initWithObject:object];
}

- (void)save {
  // accumulate changes to save together, instead of saving every change all the time
  // to cut down on API requests
  [NSObject cancelPreviousPerformRequestsWithTarget:self.backingObject selector:@selector(saveInBackground) object:nil];
  [self.backingObject performSelector:@selector(saveInBackground) withObject:nil afterDelay:SAVE_DELAY];
}

#pragma mark - Properties

- (NSString *)objectID {
  return self.backingObject.objectId;
}

- (NSDate *)createdAt {
  return self.backingObject.createdAt;
}

- (NSDate *)updatedAt {
  return self.backingObject.updatedAt;
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

- (CYMapVisibility)visibility {
  NSNumber *visibilityObject = [self.backingObject objectForKey:VISIBILITY_KEY];
  return visibilityObject.unsignedIntegerValue;
}

- (void)setVisibility:(CYMapVisibility)visibility {
  [self.backingObject setObject:[NSNumber numberWithUnsignedInteger:visibility] forKey:VISIBILITY_KEY];
  [self save];
}

#pragma mark - Relations

- (NSArray *)points {
  PFRelation *pointsRelation = [self.backingObject relationforKey:POINTS_KEY];
  return nil;
}

- (void)addPoint:(CYPoint *)point {
  PFRelation *pointsRelation = [self.backingObject relationforKey:POINTS_KEY];
  [pointsRelation addObject:point.backingObject];
}

@end
