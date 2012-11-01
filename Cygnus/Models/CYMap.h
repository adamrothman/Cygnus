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

typedef enum {
  CYMapVisibilityPublic,
  CYMapVisibilityPrivate
} CYMapVisibility;

@class CYPoint, CYGroup;

@interface CYMap : CYObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *summary;
@property (nonatomic) CYMapVisibility visibility;

// relations
@property (nonatomic, strong) CYGroup *group;
@property (nonatomic, strong) NSArray *points;
@property (nonatomic, strong) NSArray *owners;

+ (CYMap *)mapWithObject:(PFObject *)object;

- (void)addPoint:(CYPoint *)point;
- (void)removePoint:(CYPoint *)point;

- (void)addOwner:(CYUser *)owner;
- (void)removeOwner:(CYUser *)owner;

@end
