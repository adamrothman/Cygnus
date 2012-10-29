//
//  CYGroup.m
//  Cygnus
//
//  Created by Adam Rothman on 10/28/12.
//  Copyright (c) 2012 Cygnus. All rights reserved.
//

#import "CYGroup.h"

#define NAME_KEY        @"name"
#define SUMMARY_KEY     @"summary"
#define VISIBILITY_KEY  @"visibility"

#define OWNERS_KEY      @"owners"
#define MEMBERS_KEY     @"members"
#define MAPS_KEY        @"maps"

@implementation CYGroup

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

- (CYGroupVisibility)visibility {
  NSNumber *visibilityObject = [self.backingObject objectForKey:VISIBILITY_KEY];
  return visibilityObject.unsignedIntegerValue;
}

- (void)setVisibility:(CYGroupVisibility)visibility {
  [self.backingObject setObject:[NSNumber numberWithUnsignedInteger:visibility] forKey:VISIBILITY_KEY];
  [self save];
}

#pragma mark - Relations

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

- (NSArray *)members {
  PFRelation *membersRelation = [self.backingObject relationforKey:MEMBERS_KEY];
  return nil;
}

- (void)addMember:(CYUser *)member {
  PFRelation *membersRelation = [self.backingObject relationforKey:MEMBERS_KEY];
  [membersRelation addObject:member.backingUser];
  [self save];
}

- (void)removeMember:(CYUser *)member {
  PFRelation *membersRelation = [self.backingObject relationforKey:MEMBERS_KEY];
  [membersRelation removeObject:member.backingUser];
  [self save];
}

- (NSArray *)maps {
  PFRelation *mapsRelation = [self.backingObject relationforKey:MAPS_KEY];
  return nil;
}

- (void)addMap:(CYMap *)map {
  PFRelation *mapsRelation = [self.backingObject relationforKey:MAPS_KEY];
  [mapsRelation addObject:map.backingObject];
  [self save];
}

- (void)removeMap:(CYMap *)map {
  PFRelation *mapsRelation = [self.backingObject relationforKey:MAPS_KEY];
  [mapsRelation removeObject:map.backingObject];
  [self save];
}

@end
