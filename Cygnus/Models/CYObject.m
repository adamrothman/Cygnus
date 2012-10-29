//
//  CYObject.m
//  Cygnus
//
//  Created by Adam Rothman on 10/28/12.
//  Copyright (c) 2012 Cygnus. All rights reserved.
//

#import "CYObject.h"

#define SAVE_DELAY  4.0

@implementation CYObject

@synthesize backingObject=_backingObject;

#pragma mark - Object creation and update

- (id)initWithObject:(PFObject *)object {
  if ((self = [super init])) {
    self.backingObject = object;
  }
  return self;
}

- (void)save {
  // accumulate changes to save together, instead of saving every
  // change as it's made, to cut down on API requests
  [NSObject cancelPreviousPerformRequestsWithTarget:self.backingObject selector:@selector(saveInBackground) object:nil];
  [self.backingObject performSelector:@selector(saveInBackground) withObject:nil afterDelay:SAVE_DELAY];
}

#pragma mark - Properties

- (NSString *)objectID {
  return self.backingObject.objectId;
}

- (NSDate *)createdAt {
  return self.backingObject.createdAt;
}

- (NSDate *)updatedAt {
  return self.backingObject.updatedAt;
}

@end
