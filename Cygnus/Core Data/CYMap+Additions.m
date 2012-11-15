//
//  CYMap+Additions.m
//  Cygnus
//
//  Created by Adam Rothman on 11/15/12.
//  Copyright (c) 2012 Cygnus. All rights reserved.
//

#import "CYMap+Additions.h"
#import "CYAppDelegate.h"
#import "CYPoint+Additions.h"

@implementation CYMap (Additions)

+ (void)fetchPointsForMap:(CYMap *)map inContext:(NSManagedObjectContext *)context
{
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
    PFQuery *mapQuery = [PFQuery queryWithClassName:MapClassName];
    [mapQuery whereKey:@"objectId" equalTo:map.unique];
    PFQuery *query = [PFQuery queryWithClassName:PointClassName];
    [query whereKey:@"map" matchesQuery:mapQuery];
    
    NSError *error = nil;
    NSArray *points = [query findObjects:&error];
    if (error) {
      NSLog(@"Error fetching points: %@ %@", error, error.userInfo);
      return;
    }
    for (PFObject *point in points) {
      CYPoint *localPoint = [CYPoint pointWithObject:point inContext:context save:NO];
      localPoint.map = map;
    }
    
    [context saveWithSuccess:^{
      // update UI, stop spinner, whatever (probably on the main thread)
    }];
  });
}


+ (void)fetchMaps {
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
    PFQuery *query = [PFQuery queryWithClassName:MapClassName];
    NSError *error = nil;
    NSArray *maps = [query findObjects:&error];
    if (error) {
      NSLog(@"Error fetching maps: %@ %@", error, error.userInfo);
      return;
    }

    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSConfinementConcurrencyType];
    context.persistentStoreCoordinator = [CYAppDelegate appDelegate].persistentStoreCoordinator;
    for (PFObject *map in maps) {      
      CYMap *localMap = [CYMap mapWithObject:map inContext:context save:NO];
      PFQuery *mapQuery = [PFQuery queryWithClassName:MapClassName];
      [mapQuery whereKey:@"objectId" equalTo:localMap.unique];
      PFQuery *query = [PFQuery queryWithClassName:PointClassName];
      [query whereKey:@"map" matchesQuery:mapQuery];
      
      NSError *error = nil;
      NSArray *points = [query findObjects:&error];
      if (error) {
        NSLog(@"Error fetching points: %@ %@", error, error.userInfo);
        return;
      }
      for (PFObject *point in points) {
        CYPoint *localPoint = [CYPoint pointWithObject:point inContext:context save:NO];
        localPoint.map = localMap;
      }
    }

    [context saveWithSuccess:^{
      NSLog(@"finished fetching maps");
    }];
  });
}

+ (CYMap *)mapWithObject:(PFObject *)object inContext:(NSManagedObjectContext *)context save:(BOOL)save {
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

  CYMap *map = fetchedObjects.lastObject;
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

+ (CYMap *)mapInContext:(NSManagedObjectContext *)context save:(BOOL)save {
  CYMap *map = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass(self.class) inManagedObjectContext:context];
  [map saveToParseWithSuccess:^{
    if (save) [context saveWithSuccess:nil];
  }];
  return map;
}

- (void)saveToParseWithSuccess:(void (^)())block {
  PFObject *map = nil;
  if (self.unique) { // existing
    map = [PFObject objectWithoutDataWithClassName:MapClassName objectId:self.unique];
  } else { // new
    map = [PFObject objectWithClassName:MapClassName];
  }

  if (self.name) [map setObject:self.name forKey:MapNameKey];
  if (self.summary) [map setObject:self.summary forKey:MapSummaryKey];

  [map saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
    if (succeeded) {
      self.unique = map.objectId;
      if (block) block();
    } else {
      NSLog(@"Error saving map %@ to Parse: %@ %@", self.unique, error.localizedDescription, error.userInfo);
    }
  }];
}

- (void)destroyWithSave:(BOOL)save {
  if (self.unique) {
    PFObject *map = [PFObject objectWithoutDataWithClassName:MapClassName objectId:self.unique];
    [map deleteInBackground];
  }
  [self.managedObjectContext deleteObject:self];
  if (save) [self.managedObjectContext saveWithSuccess:nil];
}

- (void)addPointsObject:(CYPoint *)point {
  NSMutableOrderedSet* tempSet = [NSMutableOrderedSet orderedSetWithOrderedSet:self.points];
  [tempSet addObject:point];
  self.points = tempSet;
}

@end
