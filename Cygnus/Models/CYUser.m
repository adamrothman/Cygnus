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

static NSString *const CYUserFirstNameKey = @"first_name";
static NSString *const CYUserLastNameKey  = @"last_name";
static NSString *const CYUserLocationKey  = @"location";
static NSString *const CYUserStatusKey    = @"status";
static NSString *const CYUserRangeKey     = @"range";
static NSString *const CYUserImageURLKey  = @"image_url";

static CYUser *_currentUser = nil;

@interface CYUser ()

@property (nonatomic, retain) NSMutableSet *_groups;
@property (nonatomic, retain) NSMutableSet *_maps;

@property (nonatomic, retain) PFQuery *groupsQuery;
@property (nonatomic, retain) PFQuery *mapsQuery;

@end

@implementation CYUser

@synthesize backingUser=_backingUser, _groups, _maps;
@synthesize groupsQuery=_groupsQuery, mapsQuery=_mapsQuery, location = _location;

#pragma mark - Object creation and update

- (void)setup
{
  self.range = CYBeaconRangeLocal;
  self.status = CYBeaconStatusActive;
  PFGeoPoint *geoPoint = [self.backingUser objectForKey:CYUserLocationKey];
  self.location = [[CLLocation alloc] initWithLatitude:geoPoint.latitude longitude:geoPoint.longitude];
}

- (id)init {
  if ((self = [super init])) {
    self.backingUser = [PFUser user];
    [self setup];
  }
  return self;
}

- (id)initWithUser:(PFUser *)user {
  if ((self = [super init])) {
    self.backingUser = user;
    [self setup];
  }
  return self;
}

+ (CYUser *)userWithUser:(PFUser *)user {
  return [[CYUser alloc] initWithUser:user];
}

+ (CYUser *)newUserWithUsername:(NSString *)username password:(NSString *)password
{
  PFUser *user = [PFUser user];
  user.username = username;
  user.password = password;
  NSError *error;
  [user signUp:&error];
  if (error) return nil;
  user = [PFUser logInWithUsername:username password:password error:&error];
  if (error) return nil;
  CYUser *newUser = [CYUser currentUser];
  PFQuery *groupQuery = [PFQuery queryWithClassName:@"Group"];
  CYGroup *publicGroup = [CYGroup groupWithObject:[groupQuery getObjectWithId:@"RKXicgkfyG"]];
  PFQuery *mapQuery = [PFQuery queryWithClassName:@"Map"];
  CYMap *publicMap = [CYMap mapWithObject:[mapQuery getObjectWithId:@"ngcIS3azVV"]];
  [publicGroup addMember:newUser];
  [newUser addMap:publicMap];
  newUser._groups = [NSMutableSet setWithObject:publicGroup];
  newUser._maps = [NSMutableSet setWithObject:publicMap];
  return newUser;
}


+ (CYUser *)currentUser {
  if ([PFUser currentUser]) {
    if (!_currentUser) {
      _currentUser = [CYUser userWithUser:[PFUser currentUser]];
    }
    return _currentUser;
  } else {
    return nil;
  }
}

- (void)refreshWithBlock:(CYUserResultBlock)block {
  [self.backingUser refreshInBackgroundWithBlock:^(PFObject *object, NSError *error) {
    if (error) {
      NSLog(@"%@\n", error);
      if (block) block(nil, error);
    } else {
      if (block) block([CYUser userWithUser:(PFUser *)object], nil);
    }
  }];
}

#pragma mark - Sign up and log in

+ (void)logInWithUsernameInBackground:(NSString *)username password:(NSString *)password block:(CYUserResultBlock)block {
  [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser *pfUser, NSError *error) {
    CYUser *user = (pfUser) ? [CYUser userWithUser:pfUser] : nil;
    [user fetchGroups];
    [user fetchMaps];
    block(user, error);
  }];
}

+ (void)logOut {
  [PFUser logOut];
  [CYLogInViewController present];
  [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:CYNotificationUserDidLogOut object:nil]];
}

#pragma mark - Properties

// make inherited CYObject methods work
- (PFObject *)backingObject {
  return self.backingUser;
}

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
  return [self.backingUser objectForKey:CYUserFirstNameKey];
}

- (void)setFirstName:(NSString *)firstName {
  [self.backingUser setObject:firstName forKey:CYUserFirstNameKey];
  [self save];
}

- (NSString *)lastName {
  return [self.backingUser objectForKey:CYUserLastNameKey];
}

- (void)setLastName:(NSString *)lastName {
  [self.backingUser setObject:lastName forKey:CYUserLastNameKey];
  [self save];
}

- (CLLocation *)location {
  return _location;
}

- (void)setLocation:(CLLocation *)location {
  [self.backingObject setObject:[PFGeoPoint geoPointWithLocation:location] forKey:CYUserLocationKey];
  [self save];
  _location = location;
}

- (CYBeaconRange)range {
  NSNumber *rangeObject = [self.backingUser objectForKey:CYUserRangeKey];
  return rangeObject.unsignedIntegerValue;
}

- (void)setRange:(CYBeaconRange)range {
  [self.backingUser setObject:[NSNumber numberWithUnsignedInteger:range] forKey:CYUserRangeKey];
  [self save];
}

- (NSString *)imageURLString {
  return [self.backingUser objectForKey:CYUserImageURLKey];
}

- (void)setImageURLString:(NSString *)imageURLString {
  [self.backingUser setObject:imageURLString forKey:CYUserImageURLKey];
  [self save];
}

#pragma mark - Relations

- (NSSet *)groups {
  return self._groups;
}

// return cached groups data right away, then call block if provided on network results
- (NSSet *)groupsWithUpdateBlock:(CYGroupsResultBlock)block {
  if (!self.groupsQuery) {
    self.groupsQuery = [[self.backingUser relationforKey:CYUserGroupsKey] query];
  }

  [self.groupsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
    if (error) {
      NSLog(@"%@\n", error);
      if (block) block(nil, error);
    } else {
      self._groups = [NSMutableSet setWithCapacity:objects.count];
      for (PFObject *groupObject in objects) {
        [self._groups addObject:[CYGroup groupWithObject:groupObject]];
      }
      if (block) block(self._groups, nil);
    }
  }];

  return self._groups;
}

- (void)fetchGroups
{
  if (!self.groupsQuery) {
    self.groupsQuery = [[self.backingUser relationforKey:CYUserGroupsKey] query];
  }
  NSArray *fetchResult = [self.groupsQuery findObjects];
  self._groups = [NSMutableSet setWithCapacity:fetchResult.count];
  for (PFObject *groupObject in fetchResult) {
    [self._groups addObject:[CYGroup groupWithObject:groupObject]];
  }  
}

- (NSSet *)maps { 
  return self._maps;
}

- (NSSet *)mapsWithUpdateBlock:(CYMapsResultBlock)block {
  if (!self.mapsQuery) {
    self.mapsQuery = [[self.backingUser relationforKey:CYUserMapsKey] query];
  }

  [self.mapsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
    if (error) {
      NSLog(@"%@\n", error);
      if (block) block(nil, error);
    } else {
      self._maps = [NSMutableSet setWithCapacity:objects.count];
      for (PFObject *mapObject in objects) {
        [self._maps addObject:[CYMap mapWithObject:mapObject]];
      }
      if (block) block(self._maps, nil);
    }
  }];

  return self._maps;
}

- (void)fetchMaps
{
  if (!self.mapsQuery) {
    self.mapsQuery = [[self.backingUser relationforKey:CYUserMapsKey] query];
  }
  NSArray *fetchResult = [self.mapsQuery findObjects];
  self._maps = [NSMutableSet setWithCapacity:fetchResult.count];
  for (PFObject *groupObject in fetchResult) {
    [self._maps addObject:[CYMap mapWithObject:groupObject]];
  }
}


- (void)addMap:(CYMap *)map {
  if ([self._maps containsObject:map]) return;
  [[self.backingObject relationforKey:CYUserMapsKey] addObject:map.backingObject];
  [self save];
  [self._maps addObject:map];
}

- (void)removeMap:(CYMap *)map {
  if (![self._maps containsObject:map]) return;
  [[self.backingObject relationforKey:CYUserMapsKey] removeObject:map.backingObject];
  [self save];
  [self._maps removeObject:map];
  [[NSNotificationCenter defaultCenter] postNotificationName:CYNotificationUserUnfollowedMap object:self userInfo:@{@"map": map}];
}


@end
