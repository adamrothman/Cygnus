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
  if (!self.hasChanges) {
    if (block) block();
    return;
  }

  NSError *error = nil;
  if ([self save:&error]) {
    if (block) block();
  } else {
    NSDictionary *userInfo = @{NSUnderlyingErrorKey : error};
    NSString *reason = [NSString stringWithFormat:@"Error saving context %@", self];
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:reason userInfo:userInfo];
  }
}

@end
