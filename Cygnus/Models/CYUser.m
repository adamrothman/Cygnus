//
//  CYUser.m
//  Cygnus
//
//  Created by Adam Rothman on 10/28/12.
//  Copyright (c) 2012 Cygnus. All rights reserved.
//

#import "CYUser.h"
#import "CYLogInViewController.h"
#import "CYGroup.h"

#define FIRST_NAME_KEY  @"first_name"
#define LAST_NAME_KEY   @"last_name"
#define LOCATION_KEY    @"location"
#define STATUS_KEY      @"status"
#define RANGE_KEY       @"range"
#define IMAGE_URL_KEY   @"image_url"

#define GROUPS_KEY      @"groups"
#define MAPS_KEY        @"maps"

@interface CYUser ()

@property PFQuery *groupsQuery;
@property PFQuery *mapsQuery;

@end

@implementation CYUser

@synthesize backingUser=_backingUser, groups=_groups, maps=_maps;
@synthesize groupsQuery=_groupsQuery, mapsQuery=_mapsQuery;

#pragma mark - Object creation and update

- (id)init {
  if ((self = [super init])) {
    self.backingUser = [PFUser user];
  }
  return self;
}

- (id)initWithUser:(PFUser *)user {
  if ((self = [super init])) {
    self.backingUser = user;
  }
  return self;
}

+ (CYUser *)userWithUser:(PFUser *)user {
  return [[CYUser alloc] initWithUser:user];
}

+ (CYUser *)userWithUsername:(NSString *)username password:(NSString *)password {
  PFUser *user = [PFUser user];
  user.username = username;
  user.password = password;
  return [CYUser userWithUser:user];
}

#pragma mark - Sign up and log in

+ (CYUser *)currentUser {
  if (![PFUser currentUser]) return nil;
  return [CYUser userWithUser:[PFUser currentUser]];
}

- (void)signUpInBackgroundWithBlock:(CYBooleanResultBlock)block {
  [self.backingUser signUpInBackgroundWithBlock:block];
}

+ (void)logInWithUsernameInBackground:(NSString *)username password:(NSString *)password block:(CYUserResultBlock)block {
  [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser *user, NSError *error) {
    block([CYUser userWithUser:user], error);
  }];
}

+ (void)logOut {
  [PFUser logOut];
  [CYLogInViewController present];
  [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:CYNOTIFICATION_LOGOUT object:nil]];
}

#pragma mark - Properties

- (NSString *)username {
  return self.backingUser.username;
}

- (NSString *)password {
  return @"Naughty naughty, password is set-only";
}

- (NSString *)email {
  return self.backingUser.email;
}

- (void)setEmail:(NSString *)email {
  self.backingUser.email = email;
  [self save];
}

- (NSString *)firstName {
  return [self.backingUser objectForKey:FIRST_NAME_KEY];
}

- (void)setFirstName:(NSString *)firstName {
  [self.backingUser setObject:firstName forKey:FIRST_NAME_KEY];
  [self save];
}

- (NSString *)lastName {
  return [self.backingUser objectForKey:LAST_NAME_KEY];
}

- (void)setLastName:(NSString *)lastName {
  [self.backingUser setObject:lastName forKey:LAST_NAME_KEY];
  [self save];
}

- (PFGeoPoint *)location {
  return [self.backingUser objectForKey:LOCATION_KEY];
}

- (void)setLocation:(PFGeoPoint *)location {
  [self.backingUser setObject:location forKey:LOCATION_KEY];
  [self save];
}

- (CYUserStatus)status {
  NSNumber *statusObject = [self.backingUser objectForKey:STATUS_KEY];
  return statusObject.unsignedIntegerValue;
}

- (void)setStatus:(CYUserStatus)status {
  [self.backingUser setObject:[NSNumber numberWithUnsignedInteger:status] forKey:STATUS_KEY];
  [self save];
}

- (NSUInteger)range {
  NSNumber *rangeObject = [self.backingUser objectForKey:RANGE_KEY];
  return rangeObject.unsignedIntegerValue;
}

- (void)setRange:(NSUInteger)range {
  [self.backingUser setObject:[NSNumber numberWithUnsignedInteger:range] forKey:RANGE_KEY];
  [self save];
}

- (NSString *)imageURLString {
  return [self.backingUser objectForKey:IMAGE_URL_KEY];
}

- (void)setImageURLString:(NSString *)imageURLString {
  [self.backingUser setObject:imageURLString forKey:IMAGE_URL_KEY];
  [self save];
}

#pragma mark - Relations

- (void)fetchGroups {
  if (!self.groupsQuery) {
    self.groupsQuery = [[self.backingUser relationforKey:GROUPS_KEY] query];
    self.groupsQuery.cachePolicy = kPFCachePolicyCacheThenNetwork;
  }
  [self.groupsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
    NSMutableArray *groups = [NSMutableArray arrayWithCapacity:objects.count];
    for (PFObject *groupObject in objects) {
      [groups addObject:[CYGroup groupWithObject:groupObject]];
    }
    _groups = groups;
  }];
}

- (NSArray *)groups {
  [self fetchGroups];
  return _groups;
}

- (void)fetchMaps {
  if (!self.mapsQuery) {
    self.mapsQuery = [[self.backingUser relationforKey:MAPS_KEY] query];
    self.mapsQuery.cachePolicy = kPFCachePolicyCacheThenNetwork;
  }
  [self.mapsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
    NSMutableArray *maps = [NSMutableArray arrayWithCapacity:objects.count];
    for (PFObject *mapObject in objects) {
      [maps addObject:[CYMap mapWithObject:mapObject]];
    }
    _maps = maps;
  }];
}

- (NSArray *)maps {
  [self fetchMaps];
  return _maps;
}

@end
