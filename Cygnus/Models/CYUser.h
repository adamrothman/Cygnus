//
//  CYUser.h
//  Cygnus
//
//  Created by Adam Rothman on 10/28/12.
//  Copyright (c) 2012 Cygnus. All rights reserved.
//

typedef enum {
  CYUserStatusBeaconOn,
  CYUserStatusBeaconOff
} CYUserStatus;

@interface CYUser : NSObject

@property (nonatomic, strong) PFUser *backingUser;

@property (nonatomic, readonly) NSString *objectID;
@property (nonatomic, readonly) NSDate *createdAt;
@property (nonatomic, readonly) NSDate *updatedAt;

@property (nonatomic, readonly) NSString *username;
@property (nonatomic, strong) NSString *password; // set-only
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

- (id)initWithUser:(PFUser *)user;
- (void)save;

- (void)signUpInBackgroundWithBlock:(PFBooleanResultBlock)block;

@end
