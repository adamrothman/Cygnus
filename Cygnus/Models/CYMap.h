//
//  CYMap.h
//  Cygnus
//
//  Created by Adam Rothman on 10/28/12.
//  Copyright (c) 2012 Cygnus. All rights reserved.
//

#import "CYObject.h"
#import "CYGroup.h"
#import "CYPoint.h"
#import "CYUser.h"

@class CYPoint, CYGroup;

typedef enum {
  CYMapVisibilityPublic,
  CYMapVisibilityPrivate
} CYMapVisibility;

@interface CYMap : CYObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *summary;
@property (nonatomic) CYMapVisibility visibility;

@property (nonatomic, strong) CYGroup *group;

+ (CYMap *)mapWithObject:(PFObject *)object;

- (void)refreshWithBlock:(CYMapResultBlock)block;

// relations
- (NSSet *)points;
- (NSSet *)pointsWithUpdateBlock:(CYPointsResultBlock)block;
- (void)addPoint:(CYPoint *)point;
- (void)removePoint:(CYPoint *)point;

- (NSSet *)owners;
- (NSSet *)ownersWithUpdateBlock:(CYUsersResultBlock)block;
- (void)addOwner:(CYUser *)owner;
- (void)removeOwner:(CYUser *)owner;

@end
