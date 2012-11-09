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

@property (nonatomic, strong) NSMutableSet *owners;
@property (nonatomic, strong) NSMutableSet *members;
@property (nonatomic, strong) NSMutableSet *maps;

@property (nonatomic, strong) PFQuery *ownersQuery;
@property (nonatomic, strong) PFQuery *membersQuery;
@property (nonatomic, strong) PFQuery *mapsQuery;

@end

@implementation CYGroup

@synthesize owners=_owners, members=_members, maps=_maps;
@synthesize ownersQuery=_ownersQuery, membersQuery=_membersQuery, mapsQuery=_mapsQuery;

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

- (NSSet *)ownersWithUpdateBlock:(CYUsersResultBlock)block {
  if (!self.ownersQuery) {
    self.ownersQuery = [[self.backingObject relationforKey:CYGroupOwnersKey] query];
  }

  [self.ownersQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
    if (error) {
      NSLog(@"%@\n", error);
      if (block) block(nil, error);
    } else {
      self.owners = [NSMutableSet setWithCapacity:objects.count];
      for (PFUser *ownerObject in objects) {
        [self.owners addObject:[CYUser userWithUser:ownerObject]];
      }
      if (block) block(self.owners, nil);
    }
  }];

  return self.owners;
}

- (void)addOwner:(CYUser *)owner {
  if ([_owners containsObject:owner]) return;

  PFRelation *ownersRelation = [self.backingObject relationforKey:CYGroupOwnersKey];
  [ownersRelation addObject:owner.backingUser];
  [self save];

  // keep local copy up to date
  [self.owners addObject:owner];
}

- (void)removeOwner:(CYUser *)owner {
  if (![_owners containsObject:owner]) return;

  PFRelation *ownersRelation = [self.backingObject relationforKey:CYGroupOwnersKey];
  [ownersRelation removeObject:owner.backingUser];
  [self save];

  [self.owners removeObject:owner];
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
      self.members = [NSMutableSet setWithCapacity:objects.count];
      for (PFUser *memberObject in objects) {
        [self.members addObject:[CYUser userWithUser:memberObject]];
      }
      if (block) block(self.members, nil);
    }
  }];

  return self.members;
}

- (void)addMember:(CYUser *)member {
  if ([_members containsObject:member]) return;

  PFRelation *membersRelation = [self.backingObject relationforKey:CYGroupMembersKey];
  [membersRelation addObject:member.backingUser];
  [self save];

  [self.members addObject:member];
}

- (void)removeMember:(CYUser *)member {
  if (![_members containsObject:member]) return;

  PFRelation *membersRelation = [self.backingObject relationforKey:CYGroupMembersKey];
  [membersRelation removeObject:member.backingUser];
  [self save];

  [self.members removeObject:member];
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
      self.maps = [NSMutableSet setWithCapacity:objects.count];
      for (PFObject *mapObject in objects) {
        [self.maps addObject:[CYMap mapWithObject:mapObject]];
      }
      if (block) block(self.maps, nil);
    }
  }];

  return self.maps;
}

- (void)addMap:(CYMap *)map {
  if ([_maps containsObject:map]) return;

  PFRelation *mapsRelation = [self.backingObject relationforKey:CYGroupMapsKey];
  [mapsRelation addObject:map.backingObject];
  [self save];

  map.group = self;
  [self.maps addObject:map];
}

- (void)removeMap:(CYMap *)map {
  if (![_maps containsObject:map]) return;

  PFRelation *mapsRelation = [self.backingObject relationforKey:CYGroupMapsKey];
  [mapsRelation removeObject:map.backingObject];
  [self save];

  map.group = nil;
  [self.maps removeObject:map];
}

@end
