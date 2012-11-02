//
//  CYUser.h
//  Cygnus
//
//  Created by Adam Rothman on 10/28/12.
//  Copyright (c) 2012 Cygnus. All rights reserved.
//

#import "CYObject.h"

typedef enum {
  CYUserStatusBeaconOn,
  CYUserStatusBeaconOff
} CYUserStatus;

typedef enum {
  CYBeaconRangeLocal = 5,
  CYBeaconRangeCity = 10,
  CYBeaconRangeMetro = 50,
} CYBeaconRange;

@class CYUser;

typedef void(^CYBooleanResultBlock)(BOOL succeeded, NSError *error);
typedef void(^CYUserResultBlock)(CYUser *user, NSError *error);

@interface CYUser : CYObject

@property (nonatomic, strong) PFUser *backingUser;

@property (nonatomic, readonly) NSString *username;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *email;

@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) PFGeoPoint *location;
@property (nonatomic) CYUserStatus status;
@property (nonatomic) CYBeaconRange range;
@property (nonatomic, strong) NSString *imageURLString;

// relations
@property (nonatomic, readonly) NSArray *groups;
@property (nonatomic, readonly) NSArray *maps;

+ (CYUser *)userWithUser:(PFUser *)user;
+ (CYUser *)userWithUsername:(NSString *)username password:(NSString *)password;

+ (CYUser *)currentUser;

- (void)signUpInBackgroundWithBlock:(CYBooleanResultBlock)block;

+ (void)logInWithUsernameInBackground:(NSString *)username password:(NSString *)password block:(CYUserResultBlock)block;
+ (void)logOut;

@end
