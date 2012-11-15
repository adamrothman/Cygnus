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
static NSString *const CYMapSizeKey       = @"size";
static NSString *const CYMapVisibilityKey = @"visibility";

static NSString *const CYMapPointsKey     = @"points";
static NSString *const CYMapOwnersKey     = @"owners";
static NSString *const CYMapGroupKey      = @"group";

@interface CYMap ()

@property (nonatomic, strong) NSMutableSet *_points;
@property (nonatomic, strong) NSMutableSet *_owners;

@property (atomic, strong) PFQuery *pointsQuery;
@property (atomic, strong) PFQuery *ownersQuery;

@end

@implementation CYMap

@synthesize group=_group, _points, _owners;
@synthesize pointsQuery=_pointsQuery, ownersQuery=_ownersQuery;

#pragma mark - Object creation and update

- (id)init {
  if ((self = [super init])) {
    self.backingObject = [PFObject objectWithClassName:@"Map"];
  }
  return self;
}

+ (CYMap *)mapWithObject:(PFObject *)object {
  CYMap *map = [[CYMap alloc] initWithObject:object];
  return map;
}

+ (void)fetchAllMaps:(CYMapsResultBlock)block
{
  PFQuery *mapQuery = [PFQuery queryWithClassName:@"Map"];
  [mapQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
    if (error) {
      NSLog(@"%@\n", error);
      if (block) block(nil, error);
    } else {
      NSMutableSet *maps = [NSMutableSet setWithCapacity:[objects count]];
      for (PFObject *mapObject in objects) {
        [maps addObject:[CYMap mapWithObject:mapObject]];
      }
      block(maps, nil);
    }
  }];
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


- (NSNumber *)size {
  return [self.backingObject objectForKey:CYMapSizeKey];
}

- (void)setSize:(NSNumber*)size {
  [self.backingObject setObject:size forKey:CYMapSizeKey];
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

- (NSSet *)points {
  return self._points;
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
      self._points = [NSMutableSet setWithCapacity:objects.count];
      for (PFObject *pointObject in objects) {
        [self._points addObject:[CYPoint pointWithObject:pointObject]];
      }
      if (block) block(self._points, nil);
    }
  }];

  return self._points;
}

- (void)addPoint:(CYPoint *)point {
  if ([self._points containsObject:point]) return;

  [[self.backingObject relationforKey:CYMapPointsKey] addObject:point.backingObject];
  [self save];

  self.size = @([self.size integerValue] + 1);

  point.map = self;

  [self._points addObject:point];
}

- (void)removePoint:(CYPoint *)point {
  if (![self._points containsObject:point]) return;

  [[self.backingObject relationforKey:CYMapPointsKey] removeObject:point.backingObject];
  [self save];

  self.size = @([self.size integerValue] - 1);

  point.map = nil;

  [self._points removeObject:point];
}

- (NSSet *)owners {
  return self._owners;
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
      self._owners = [NSMutableSet setWithCapacity:objects.count];
      for (PFUser *userObject in objects) {
        [self._owners addObject:[CYUser userWithUser:userObject]];
      }
      if (block) block(self._owners, nil);
    }
  }];

  return self._owners;
}

- (void)addOwner:(CYUser *)owner {
  if ([self._owners containsObject:owner]) return;

  [[self.backingObject relationforKey:CYMapOwnersKey] addObject:owner.backingUser];
  [self save];

  [self._owners addObject:owner];
}

- (void)removeOwner:(CYUser *)owner {
  if (![self._owners containsObject:owner]) return;

  [[self.backingObject relationforKey:CYMapOwnersKey] removeObject:owner.backingUser];
  [self save];

  [self._owners removeObject:owner];
}

@end
