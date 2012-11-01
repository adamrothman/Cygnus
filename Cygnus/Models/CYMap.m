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

- (void)fetchPoints {
  if (!self.pointsQuery) {
    self.pointsQuery = [[self.backingObject relationforKey:CYMapPointsKey] query];
    self.pointsQuery.cachePolicy = kPFCachePolicyCacheThenNetwork;
  }

  [self.pointsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
    NSMutableArray *points = [NSMutableArray arrayWithCapacity:objects.count];
    for (PFObject *pointObject in objects) {
      [points addObject:[CYPoint pointWithObject:pointObject]];
    }
    _points = points;
  }];
}

- (NSArray *)points {
  [self fetchPoints];
  return _points;
}

- (void)addPoint:(CYPoint *)point {
  if ([_points containsObject:point]) return;

  PFRelation *pointsRelation = [self.backingObject relationforKey:CYMapPointsKey];
  [pointsRelation addObject:point.backingObject];
  [self save];

  NSMutableArray *points = [NSMutableArray arrayWithArray:_points];
  [points addObject:point];
  _points = points;
}

- (void)removePoint:(CYPoint *)point {
  if (![_points containsObject:point]) return;

  PFRelation *pointsRelation = [self.backingObject relationforKey:CYMapPointsKey];
  [pointsRelation removeObject:point.backingObject];
  [self save];

  NSMutableArray *points = [NSMutableArray arrayWithArray:_points];
  [points removeObject:point];
  _points = points;
}

- (void)fetchOwners {
  if (!self.ownersQuery) {
    self.ownersQuery = [[self.backingObject relationforKey:CYMapOwnersKey] query];
    self.ownersQuery.cachePolicy = kPFCachePolicyCacheThenNetwork;
  }

  [self.ownersQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
    NSMutableArray *owners = [NSMutableArray arrayWithCapacity:objects.count];
    for (PFUser *userObject in objects) {
      [owners addObject:[CYUser userWithUser:userObject]];
    }
    _owners = owners;
  }];
}

- (NSArray *)owners {
  [self fetchOwners];
  return _owners;
}

- (void)addOwner:(CYUser *)owner {
  if ([_owners containsObject:owner]) return;

  PFRelation *ownersRelation = [self.backingObject relationforKey:CYMapOwnersKey];
  [ownersRelation addObject:owner.backingUser];
  [self save];

  NSMutableArray *owners = [NSMutableArray arrayWithArray:_owners];
  [owners addObject:owner];
  _owners = owners;
}

- (void)removeOwner:(CYUser *)owner {
  if (![_owners containsObject:owner]) return;

  PFRelation *ownersRelation = [self.backingObject relationforKey:CYMapOwnersKey];
  [ownersRelation removeObject:owner.backingUser];
  [self save];

  NSMutableArray *owners = [NSMutableArray arrayWithArray:_owners];
  [owners removeObject:owner];
  _owners = owners;
}

@end
