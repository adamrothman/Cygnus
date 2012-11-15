//
//  NSManagedObjectContext+SimpleSave.m
//  Cygnus
//
//  Created by Adam Rothman on 11/14/12.
//  Copyright (c) 2012 Cygnus. All rights reserved.
//

#import "NSManagedObjectContext+SimpleSave.h"

@implementation NSManagedObjectContext (SimpleSave)

- (void)saveWithSuccess:(void(^)())block {
  if (!self.hasChanges) return;

  NSError *error = nil;
  if ([self save:&error]) {
    if (block) block();
  } else {
    NSLog(@"Error saving context %@: %@ %@", self, error, error.userInfo);
    abort();
  }
}

@end
