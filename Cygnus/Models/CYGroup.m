//
//  CYGroup.m
//  Cygnus
//
//  Created by Adam Rothman on 10/28/12.
//  Copyright (c) 2012 Cygnus. All rights reserved.
//

#import "CYGroup.h"

static NSString *const CYGroupNameKey       = @"name";
static NSString *const CYGroupSummaryKey    = @"summary";
static NSString *const CYGroupVisibilityKey = @"visibility";

static NSString *const CYGroupOwnersKey     = @"owners";
static NSString *const CYGroupMembersKey    = @"members";
static NSString *const CYGroupMapsKey       = @"maps";

@interface CYGroup ()

@property (nonatomic, strong) NSMutableSet *_owners;
@property (nonatomic, strong) NSMutableSet *_members;
@property (nonatomic, strong) NSMutableSet *_maps;

@property (nonatomic, strong) PFQuery *ownersQuery;
@property (nonatomic, strong) PFQuery *membersQuery;
@property (nonatomic, strong) PFQuery *mapsQuery;

@end

@implementation CYGroup

@synthesize _owners, _members, _maps;
@synthesize ownersQuery, membersQuery, mapsQuery;

#pragma mark - Object creation and update

- (id)init {
  if ((self = [super init])) {
    self.backingObject = [PFObject objectWithClassName:@"Group"];
  }
  return self;
}

+ (CYGroup *)groupWithObject:(PFObject *)object {
  return [[CYGroup alloc] initWithObject:object];
}

- (void)refreshWithBlock:(CYGroupResultBlock)block {
  [self.backingObject refreshInBackgroundWithBlock:^(PFObject *object, NSError *error) {
    if (error) {
      NSLog(@"%@\n", error);
      if (block) block(nil, error);
    } else {
      if (block) block([CYGroup groupWithObject:object], nil);
    }
  }];
}

#pragma mark - Properties

- (NSString *)name {
  return [self.backingObject objectForKey:CYGroupNameKey];
}

- (void)setName:(NSString *)name {
  [self.backingObject setObject:name forKey:CYGroupNameKey];
  [self save];
}

- (NSString *)summary {
  return [self.backingObject objectForKey:CYGroupSummaryKey];
}

- (void)setSummary:(NSString *)summary {
  [self.backingObject setObject:summary forKey:CYGroupSummaryKey];
  [self save];
}

- (CYGroupVisibility)visibility {
  NSNumber *visibilityObject = [self.backingObject objectForKey:CYGroupVisibilityKey];
  return visibilityObject.unsignedIntegerValue;
}

- (void)setVisibility:(CYGroupVisibility)visibility {
  [self.backingObject setObject:[NSNumber numberWithUnsignedInteger:visibility] forKey:CYGroupVisibilityKey];
  [self save];
}

#pragma mark - Relations

- (NSSet *)owners {
  return self._owners;
}

- (NSSet *)ownersWithUpdateBlock:(CYUsersResultBlock)block {
  if (!self.ownersQuery) {
    self.ownersQuery = [[self.backingObject relationforKey:CYGroupOwnersKey] query];
  }

  [self.ownersQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
    if (error) {
      NSLog(@"%@\n", error);
      if (block) block(nil, error);
    } else {
      self._owners = [NSMutableSet setWithCapacity:objects.count];
      for (PFUser *ownerObject in objects) {
        [self._owners addObject:[CYUser userWithUser:ownerObject]];
      }
      if (block) block(self._owners, nil);
    }
  }];

  return self._owners;
}

- (void)addOwner:(CYUser *)owner {
  if ([self._owners containsObject:owner]) return;

  [[self.backingObject relationforKey:CYGroupOwnersKey] addObject:owner.backingUser];
  [self save];

  [self._owners addObject:owner];
}

- (void)removeOwner:(CYUser *)owner {
  if (![self._owners containsObject:owner]) return;

  [[self.backingObject relationforKey:CYGroupOwnersKey] removeObject:owner.backingUser];
  [self save];

  [self._owners removeObject:owner];
}

- (NSSet *)membersWithUpdateBlock:(CYUsersResultBlock)block {
  if (!self.membersQuery) {
    self.membersQuery = [[self.backingObject relationforKey:CYGroupMembersKey] query];
  }

  [self.membersQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
    if (error) {
      NSLog(@"%@\n", error);
      if (block) block(nil, error);
    } else {
      self._members = [NSMutableSet setWithCapacity:objects.count];
      for (PFUser *memberObject in objects) {
        [self._members addObject:[CYUser userWithUser:memberObject]];
      }
      if (block) block(self._members, nil);
    }
  }];

  return self._members;
}

- (void)addMember:(CYUser *)member {
  if ([self._members containsObject:member]) return;

  [[self.backingObject relationforKey:CYGroupMembersKey] addObject:member.backingUser];
  [self save];

  [[member.backingUser relationforKey:CYUserGroupsKey] addObject:self.backingObject];
  [member save];

  [self._members addObject:member];
}

- (void)removeMember:(CYUser *)member {
  if (![self._members containsObject:member]) return;

  [[self.backingObject relationforKey:CYGroupMembersKey] removeObject:member.backingUser];
  [self save];

  [[member.backingUser relationforKey:CYUserGroupsKey] removeObject:self.backingObject];
  [member save];

  [self._members removeObject:member];
}

- (NSSet *)mapsWithUpdateBlock:(CYMapsResultBlock)block {
  if (!self.mapsQuery) {
    self.mapsQuery = [[self.backingObject relationforKey:CYGroupMapsKey] query];
  }

  [self.mapsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
    if (error) {
      NSLog(@"%@\n", error);
      if (block) block(nil, error);
    } else {
      self._maps = [NSMutableSet setWithCapacity:objects.count];
      for (PFObject *mapObject in objects) {
        [self._maps addObject:[CYMap mapWithObject:mapObject]];
      }
      if (block) block(self._maps, nil);
    }
  }];

  return self._maps;
}

- (void)addMap:(CYMap *)map {
  if ([self._maps containsObject:map]) return;

  [[self.backingObject relationforKey:CYGroupMapsKey] addObject:map.backingObject];
  [self save];

  map.group = self;

  [self._maps addObject:map];
}

- (void)removeMap:(CYMap *)map {
  if (![self._maps containsObject:map]) return;

  [[self.backingObject relationforKey:CYGroupMapsKey] removeObject:map.backingObject];
  [self save];

  map.group = nil;

  [self._maps removeObject:map];
}

@end
