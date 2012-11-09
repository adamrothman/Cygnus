//
//  CYGroup.h
//  Cygnus
//
//  Created by Adam Rothman on 10/28/12.
//  Copyright (c) 2012 Cygnus. All rights reserved.
//

#import "CYObject.h"
#import "CYUser.h"
#import "CYMap.h"

@class CYMap, CYUser;

typedef enum {
  CYGroupVisibilityPublic,
  CYGroupVisibilityPrivate
} CYGroupVisibility;

@interface CYGroup : CYObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *summary;
@property (nonatomic) CYGroupVisibility visibility;

+ (CYGroup *)groupWithObject:(PFObject *)object;

- (void)refreshWithBlock:(CYGroupResultBlock)block;

// relations
- (NSSet *)ownersWithUpdateBlock:(CYUsersResultBlock)block;
- (void)addOwner:(CYUser *)owner;
- (void)removeOwner:(CYUser *)owner;

- (NSSet *)membersWithUpdateBlock:(CYUsersResultBlock)block;
- (void)addMember:(CYUser *)member;
- (void)removeMember:(CYUser *)member;


- (NSSet *)mapsWithUpdateBlock:(CYMapsResultBlock)block;
- (void)addMap:(CYMap *)map;
- (void)removeMap:(CYMap *)map;

@end
