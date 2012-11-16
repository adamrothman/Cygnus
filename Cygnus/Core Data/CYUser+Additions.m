//
//  CYUser+Additions.m
//  Cygnus
//
//  Created by Adam Rothman on 11/15/12.
//  Copyright (c) 2012 Cygnus. All rights reserved.
//

#import "CYUser+Additions.h"
#import "NSString+UUID.h"

@implementation CYUser (Additions)

+ (CYUser *)user {
  NSFetchRequest *request = [[NSFetchRequest alloc] init];
  request.entity = [NSEntityDescription entityForName:NSStringFromClass(self.class) inManagedObjectContext:[CYAppDelegate mainContext]];
  request.fetchLimit = 1;

  NSError *error = nil;
  NSArray *fetchedObjects = [[CYAppDelegate mainContext] executeFetchRequest:request error:&error];
  if (error) {
    NSDictionary *userInfo = @{NSUnderlyingErrorKey : error};
    NSString *reason = [NSString stringWithFormat:@"Error fetching user object"];
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:reason userInfo:userInfo];
  }

  CYUser *user = fetchedObjects.lastObject;
  if (!user) {
    user = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass(self.class) inManagedObjectContext:[CYAppDelegate mainContext]];
    [[CYAppDelegate mainContext] saveWithSuccess:nil];
    user.unique = [UIDevice currentDevice].identifierForVendor.UUIDString;
    [CYAnalytics identityUser:user.unique];
  }

  return user;
}

@end
