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

@interface CYUser : CYObject

// use this, not backingObject
@property (nonatomic, strong) PFUser *backingUser;

@property (nonatomic, readonly) NSString *username;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *email;

@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) PFGeoPoint *location;
@property (nonatomic) CYUserStatus status;
@property (nonatomic) NSUInteger range;
@property (nonatomic, strong) NSString *imageURLString;

// relations
@property (nonatomic, strong) NSArray *groups;
@property (nonatomic, strong) NSArray *maps;

+ (CYUser *)currentUser;

- (id)initWithUser:(PFUser *)user;
+ (CYUser *)userWithUser:(PFUser *)user;

- (void)signUpInBackgroundWithBlock:(PFBooleanResultBlock)block;
+ (void)logInWithUsernameInBackground:(NSString *)username password:(NSString *)password block:(PFUserResultBlock)block;

@end
