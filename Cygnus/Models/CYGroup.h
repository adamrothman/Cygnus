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

typedef enum {
  CYGroupVisibilityPublic,
  CYGroupVisibilityPrivate
} CYGroupVisibility;

@interface CYGroup : CYObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *summary;
@property (nonatomic) CYGroupVisibility visibility;

// relations
@property (nonatomic, strong) NSArray *owners;
@property (nonatomic, strong) NSArray *members;
@property (nonatomic, strong) NSArray *maps;

+ (CYGroup *)groupWithObject:(PFObject *)object;

- (void)addOwner:(CYUser *)owner;
- (void)removeOwner:(CYUser *)owner;

- (void)addMember:(CYUser *)member;
- (void)removeMember:(CYUser *)member;

- (void)addMap:(CYMap *)map;
- (void)removeMap:(CYMap *)map;

@end
