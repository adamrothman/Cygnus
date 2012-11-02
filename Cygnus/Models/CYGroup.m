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

- (void)fetchOwners {
  if (!self.ownersQuery) {
    self.ownersQuery = [[self.backingObject relationforKey:CYGroupOwnersKey] query];
    self.ownersQuery.cachePolicy = kPFCachePolicyCacheThenNetwork;
  }

  [self.ownersQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
    NSMutableArray *owners = [NSMutableArray arrayWithCapacity:objects.count];
    for (PFUser *ownerObject in objects) {
      [owners addObject:[CYUser userWithUser:ownerObject]];
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

  PFRelation *ownersRelation = [self.backingObject relationforKey:CYGroupOwnersKey];
  [ownersRelation addObject:owner.backingUser];
  [self save];

  // keep local copy up to date
  NSMutableArray *owners = [NSMutableArray arrayWithArray:_owners];
  [owners addObject:owner];
  _owners = owners;
}

- (void)removeOwner:(CYUser *)owner {
  if (![_owners containsObject:owner]) return;

  PFRelation *ownersRelation = [self.backingObject relationforKey:CYGroupOwnersKey];
  [ownersRelation removeObject:owner.backingUser];
  [self save];

  NSMutableArray *owners = [NSMutableArray arrayWithArray:_owners];
  [owners removeObject:owner];
  _owners = owners;
}

- (void)fetchMembers {
  if (!self.membersQuery) {
    self.membersQuery = [[self.backingObject relationforKey:CYGroupMembersKey] query];
    self.membersQuery.cachePolicy = kPFCachePolicyCacheThenNetwork;
  }

  [self.membersQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
    NSMutableArray *members = [NSMutableArray arrayWithCapacity:objects.count];
    for (PFUser *memberObject in objects) {
      [members addObject:[CYUser userWithUser:memberObject]];
    }
    _members = members;
  }];
}

- (NSArray *)members {
  [self fetchMembers];
  return _members;
}

- (void)addMember:(CYUser *)member {
  if ([_members containsObject:member]) return;

  PFRelation *membersRelation = [self.backingObject relationforKey:CYGroupMembersKey];
  [membersRelation addObject:member.backingUser];
  [self save];

  NSMutableArray *members = [NSMutableArray arrayWithArray:_members];
  [members addObject:member];
  _members = members;
}

- (void)removeMember:(CYUser *)member {
  if (![_members containsObject:member]) return;

  PFRelation *membersRelation = [self.backingObject relationforKey:CYGroupMembersKey];
  [membersRelation removeObject:member.backingUser];
  [self save];

  NSMutableArray *members = [NSMutableArray arrayWithArray:_members];
  [members removeObject:member];
  _members = members;
}

- (void)fetchMaps {
  if (!self.mapsQuery) {
    self.mapsQuery = [[self.backingObject relationforKey:CYGroupMapsKey] query];
    self.mapsQuery.cachePolicy = kPFCachePolicyCacheThenNetwork;
  }

  [self.mapsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
    NSMutableArray *maps = [NSMutableArray arrayWithCapacity:objects.count];
    for (PFObject *mapObject in objects) {
      [maps addObject:[CYMap mapWithObject:mapObject]];
    }
   _maps = maps;
  }];
}

- (NSArray *)maps {
  [self fetchMaps];
  return _maps;
}

- (void)addMap:(CYMap *)map {
  if ([_maps containsObject:map]) return;

  PFRelation *mapsRelation = [self.backingObject relationforKey:CYGroupMapsKey];
  [mapsRelation addObject:map.backingObject];
  [self save];

  NSMutableArray *maps = [NSMutableArray arrayWithArray:_maps];
  [maps addObject:map];
  _maps = maps;
}

- (void)removeMap:(CYMap *)map {
  if (![_maps containsObject:map]) return;

  PFRelation *mapsRelation = [self.backingObject relationforKey:CYGroupMapsKey];
  [mapsRelation removeObject:map.backingObject];
  [self save];

  NSMutableArray *maps = [NSMutableArray arrayWithArray:_maps];
  [maps removeObject:map];
  _maps = maps;
}

@end
