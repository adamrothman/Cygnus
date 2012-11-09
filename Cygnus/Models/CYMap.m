//
//  CYMap.m
//  Cygnus
//
//  Created by Adam Rothman on 10/28/12.
//  Copyright (c) 2012 Cygnus. All rights reserved.
//

#import "CYMap.h"
#import "CYPoint.h"

static NSString *const CYMapNameKey       = @"name";
static NSString *const CYMapSummaryKey    = @"summary";
static NSString *const CYMapVisibilityKey = @"visibility";

static NSString *const CYMapPointsKey     = @"points";
static NSString *const CYMapOwnersKey     = @"owners";
static NSString *const CYMapGroupKey      = @"group";

@interface CYMap ()

@property (nonatomic, strong) NSMutableSet *points;
@property (nonatomic, strong) NSMutableSet *owners;

@property (nonatomic, strong) PFQuery *pointsQuery;
@property (nonatomic, strong) PFQuery *ownersQuery;

@end

@implementation CYMap

@synthesize group=_group, points=_points, owners=_owners;
@synthesize pointsQuery=_pointsQuery, ownersQuery=_ownersQuery;

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

- (void)refreshWithBlock:(CYMapResultBlock)block {
  [self.backingObject refreshInBackgroundWithBlock:^(PFObject *object, NSError *error) {
    if (error) {
      NSLog(@"%@\n", error);
      if (block) block(nil, error);
    } else {
      if (block) block([CYMap mapWithObject:object], nil);
    }
  }];
}

#pragma mark - Properties

- (NSString *)name {
  return [self.backingObject objectForKey:CYMapNameKey];
}

- (void)setName:(NSString *)name {
  [self.backingObject setObject:name forKey:CYMapNameKey];
  [self save];
}

- (NSString *)summary {
  return [self.backingObject objectForKey:CYMapSummaryKey];
}

- (void)setSummary:(NSString *)summary {
  [self.backingObject setObject:summary forKey:CYMapSummaryKey];
  [self save];
}

- (CYMapVisibility)visibility {
  NSNumber *visibilityObject = [self.backingObject objectForKey:CYMapVisibilityKey];
  return visibilityObject.unsignedIntegerValue;
}

- (void)setVisibility:(CYMapVisibility)visibility {
  [self.backingObject setObject:[NSNumber numberWithUnsignedInteger:visibility] forKey:CYMapVisibilityKey];
  [self save];
}

#pragma mark - Relations

- (CYGroup *)group {
  if (!_group) _group = [CYGroup groupWithObject:[self.backingObject objectForKey:CYMapGroupKey]];
  [_group.backingObject fetchIfNeeded];
  return _group;
}

- (void)setGroup:(CYGroup *)group {
  _group = group;
  [self.backingObject setObject:_group.backingObject forKey:CYMapGroupKey];
  [self save];
}

- (NSSet *)pointsWithUpdateBlock:(CYPointsResultBlock)block {
  if (!self.pointsQuery) {
    self.pointsQuery = [[self.backingObject relationforKey:CYMapPointsKey] query];
  }

  [self.pointsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
    if (error) {
      NSLog(@"%@\n", error);
      if (block) block(nil, error);
    } else {
      self.points = [NSMutableSet setWithCapacity:objects.count];
      for (PFObject *pointObject in objects) {
        [self.points addObject:[CYPoint pointWithObject:pointObject]];
      }
      if (block) block(self.points, nil);
    }
  }];

  return self.points;
}

- (void)addPoint:(CYPoint *)point {
  if ([_points containsObject:point]) return;

  PFRelation *pointsRelation = [self.backingObject relationforKey:CYMapPointsKey];
  [pointsRelation addObject:point.backingObject];
  [self save];

  point.map = self;
  [self.points addObject:point];
}

- (void)removePoint:(CYPoint *)point {
  if (![_points containsObject:point]) return;

  PFRelation *pointsRelation = [self.backingObject relationforKey:CYMapPointsKey];
  [pointsRelation removeObject:point.backingObject];
  [self save];

  point.map = nil;
  [self.points removeObject:point];
}

- (NSSet *)ownersWithUpdateBlock:(CYUsersResultBlock)block {
  if (!self.ownersQuery) {
    self.ownersQuery = [[self.backingObject relationforKey:CYMapOwnersKey] query];
    self.ownersQuery.cachePolicy = kPFCachePolicyCacheThenNetwork;
  }

  [self.ownersQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
    if (error) {
      NSLog(@"%@\n", error);
      if (block) block(nil, error);
    } else {
      self.owners = [NSMutableSet setWithCapacity:objects.count];
      for (PFUser *userObject in objects) {
        [self.owners addObject:[CYUser userWithUser:userObject]];
      }
      if (block) block(self.owners, nil);
    }
  }];

  return self.owners;
}

- (void)addOwner:(CYUser *)owner {
  if ([_owners containsObject:owner]) return;

  PFRelation *ownersRelation = [self.backingObject relationforKey:CYMapOwnersKey];
  [ownersRelation addObject:owner.backingUser];
  [self save];

  [self.owners addObject:owner];
}

- (void)removeOwner:(CYUser *)owner {
  if (![_owners containsObject:owner]) return;

  PFRelation *ownersRelation = [self.backingObject relationforKey:CYMapOwnersKey];
  [ownersRelation removeObject:owner.backingUser];
  [self save];

  [self.owners removeObject:owner];
}

@end
