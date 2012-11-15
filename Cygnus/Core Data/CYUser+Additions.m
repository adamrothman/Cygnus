//
//  CYUser+Additions.m
//  Cygnus
//
//  Created by Adam Rothman on 11/15/12.
//  Copyright (c) 2012 Cygnus. All rights reserved.
//

#import "CYUser+Additions.h"
#import "CYAppDelegate.h"

@implementation CYUser (Additions)

+ (CYUser *)user {
  NSManagedObjectContext *mainContext = [CYAppDelegate appDelegate].managedObjectContext;

  NSFetchRequest *request = [[NSFetchRequest alloc] init];
  request.entity = [NSEntityDescription entityForName:NSStringFromClass(self.class) inManagedObjectContext:mainContext];
  request.fetchLimit = 1;

  NSError *error = nil;
  NSArray *fetchedObjects = [mainContext executeFetchRequest:request error:&error];
  if (error) {
    NSLog(@"Error: %@ %@", error.localizedDescription, error.userInfo);
    abort();
  }

  CYUser *user = fetchedObjects.lastObject;
  if (!user) {
    user = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass(self.class) inManagedObjectContext:mainContext];
    [mainContext saveWithSuccess:nil];
  }

  return user;
}

@end
