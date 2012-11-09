//
//  CYUser.h
//  Cygnus
//
//  Created by Adam Rothman on 10/28/12.
//  Copyright (c) 2012 Cygnus. All rights reserved.
//

#import "CYObject.h"
#import "CYGroup.h"
#import "CYMap.h"

typedef enum {
  CYBeaconStatusManual = 0,
  CYBeaconStatusActive = 1
} CYBeaconStatus;

typedef enum {
  CYBeaconRangeOff = 0,
  CYBeaconRangeLocal = 5,
  CYBeaconRangeCity = 10,
  CYBeaconRangeMetro = 50,
} CYBeaconRange;

static NSString *const CYUserGroupsKey    = @"groups";
static NSString *const CYUserMapsKey      = @"maps";

@interface CYUser : CYObject

@property (nonatomic, strong) PFUser *backingUser;

@property (nonatomic, readonly) NSString *username;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *email;

@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSString *imageURLString;

// beacon
@property (nonatomic, strong) CLLocation *location;
@property (nonatomic) CYBeaconRange range;
@property (nonatomic) CYBeaconStatus status;

+ (CYUser *)userWithUser:(PFUser *)user;

+ (CYUser *)currentUser;
+ (CYUser *)newUserWithUsername:(NSString *)username password:(NSString *)password;
+ (void)logInWithUsernameInBackground:(NSString *)username password:(NSString *)password block:(CYUserResultBlock)block;
+ (void)logOut;

- (void)refreshWithBlock:(CYUserResultBlock)block;

// relations
- (NSSet *)groups;
- (NSSet *)groupsWithUpdateBlock:(CYGroupsResultBlock)block;
- (void)fetchGroups;

- (NSSet *)maps;
- (NSSet *)mapsWithUpdateBlock:(CYMapsResultBlock)block;
- (void)fetchMaps;

- (void)addMap:(CYMap *)map;
- (void)removeMap:(CYMap *)map;

@end
