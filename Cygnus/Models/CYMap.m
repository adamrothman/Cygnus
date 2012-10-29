//
//  CYMap.m
//  Cygnus
//
//  Created by Adam Rothman on 10/28/12.
//  Copyright (c) 2012 Cygnus. All rights reserved.
//

#import "CYMap.h"
#import "CYPoint.h"

#define NAME_KEY        @"name"
#define SUMMARY_KEY     @"summary"
#define VISIBILITY_KEY  @"visibility"

#define POINTS_KEY      @"points"
#define OWNERS_KEY      @"owners"
#define GROUP_KEY       @"group"

@implementation CYMap

@synthesize backingObject=_backingObject;

#pragma mark - Object creation and update

- (id)init {
  if ((self = [super init])) {
    self.backingObject = [PFObject objectWithClassName:@"Map"];
  }
  return self;
}

+ (CYMap *)mapWithObject:(PFObject *)object {
  return [[CYMap alloc] initWithObject:object];
}

#pragma mark - Properties

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
  [self save];
}

- (void)removePoint:(CYPoint *)point {
  PFRelation *pointsRelation = [self.backingObject relationforKey:POINTS_KEY];
  [pointsRelation removeObject:point.backingObject];
  [self save];
}

- (NSArray *)owners {
  PFRelation *ownersRelation = [self.backingObject relationforKey:OWNERS_KEY];
  return nil;
}

- (void)addOwner:(CYUser *)owner {
  PFRelation *ownersRelation = [self.backingObject relationforKey:OWNERS_KEY];
  [ownersRelation addObject:owner.backingUser];
  [self save];
}

- (void)removeOwner:(CYUser *)owner {
  PFRelation *ownersRelation = [self.backingObject relationforKey:OWNERS_KEY];
  [ownersRelation removeObject:owner.backingUser];
  [self save];
}

- (CYGroup *)group {
  return [CYGroup groupWithObject:[[self.backingObject objectForKey:GROUP_KEY] fetchIfNeeded]];
}

@end
