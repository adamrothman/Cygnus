//
//  CYBlocks.h
//  Cygnus
//
//  Created by Adam Rothman on 11/8/12.
//  Copyright (c) 2012 Cygnus. All rights reserved.
//

@class CYGroup, CYMap, CYPoint, CYUser;

typedef void(^CYBooleanResultBlock)(BOOL succeeded, NSError *error);

typedef void(^CYGroupResultBlock)(CYGroup *group, NSError *error);
typedef void(^CYGroupsResultBlock)(NSSet *groups, NSError *error);

typedef void(^CYMapResultBlock)(CYMap *map, NSError *error);
typedef void(^CYMapsResultBlock)(NSSet *maps, NSError *error);

typedef void(^CYPointResultBlock)(CYPoint *point, NSError *error);
typedef void(^CYPointsResultBlock)(NSSet *points, NSError *error);

typedef void(^CYUserResultBlock)(CYUser *user, NSError *error);
typedef void(^CYUsersResultBlock)(NSSet *users, NSError *error);
