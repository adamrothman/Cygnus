//
//  CYMap+Additions.m
//  Cygnus
//
//  Created by Adam Rothman on 11/15/12.
//  Copyright (c) 2012 Cygnus. All rights reserved.
//

#import "CYMap+Additions.h"

@implementation CYMap (Additions)

+ (CYMap *)mapWithObject:(PFObject *)object inContext:(NSManagedObjectContext *)context save:(BOOL)save {
  CYMap *map = nil;

  NSFetchRequest *request = [[NSFetchRequest alloc] init];
  request.entity = [NSEntityDescription entityForName:NSStringFromClass(self.class) inManagedObjectContext:context];
  request.predicate = [NSPredicate predicateWithFormat:@"unique = %@", object.objectId];
  request.fetchLimit = 1;

  NSError *error = nil;
  NSArray *fetchedObjects = [context executeFetchRequest:request error:&error];
  if (error) {
    NSLog(@"Error: %@ %@", error.localizedDescription, error.userInfo);
    abort();
  }

  map = fetchedObjects.lastObject;
  if (!map) {
    // no CD object for this PFObject yet
    map = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass(self.class) inManagedObjectContext:context];
    map.unique = object.objectId;
    map.createdAt = object.createdAt;
    map.updatedAt = object.updatedAt;
    map.name = [object objectForKey:MapNameKey];
    map.summary = [object objectForKey:MapSummaryKey];
    if (save) [context saveWithSuccess:nil];
  } else if ([map.updatedAt compare:object.updatedAt] == NSOrderedAscending) {
    // we have a matching object, just update appropriate fields fields
    map.updatedAt = object.updatedAt;
    map.name = [object objectForKey:MapNameKey];
    map.summary = [object objectForKey:MapSummaryKey];
    if (save) [context saveWithSuccess:nil];
  }

  return map;
}

- (void)saveToParse {
  PFObject *map = [PFObject objectWithoutDataWithClassName:MapClassName objectId:self.unique];
  [map setObject:self.name forKey:MapNameKey];
  [map setObject:self.summary forKey:MapSummaryKey];
  [map saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
    if (!succeeded) {
      NSLog(@"Error saving map %@ to Parse: %@ %@", self.unique, error.localizedDescription, error.userInfo);
    }
  }];
}

@end
