//
//  CYUser.m
//  Cygnus
//
//  Created by Adam Rothman on 10/28/12.
//  Copyright (c) 2012 Cygnus. All rights reserved.
//

#import "CYUser.h"

#define FIRST_NAME_KEY  @"first_name"
#define LAST_NAME_KEY   @"last_name"
#define LOCATION_KEY    @"location"
#define STATUS_KEY      @"status"

@interface CYUser ()
@property (nonatomic, strong) PFUser *backingUser;
@end

@implementation CYUser

@synthesize backingUser=_backingUser;

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

- (void)save {
  [self.backingUser saveInBackground];
}

#pragma mark - Properties

- (NSString *)objectID {
  return self.backingUser.objectId;
}

- (NSDate *)createdAt {
  return self.backingUser.createdAt;
}

- (NSDate *)updatedAt {
  return self.backingUser.updatedAt;
}

- (NSString *)username {
  return self.backingUser.username;
}

- (NSString *)password {
  return @"Naughty naughty";
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

#pragma mark - Relationships

// TODO(adam): these

- (NSArray *)groups {
  return nil;
}

- (NSArray *)maps {
  return nil;
}

@end
