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

#pragma mark - Retrieval

+ (void)fetchMapsWithSuccess:(void(^)())block {
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
    NSDate *start = [NSDate date];

    PFQuery *query = [PFQuery queryWithClassName:MapClassName];
    NSError *error = nil;
    NSArray *maps = [query findObjects:&error];
    if (error) {
      NSLog(@"Error fetching maps: %@ %@", error.localizedDescription, error.userInfo);
      return;
    }

    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSConfinementConcurrencyType];
    context.persistentStoreCoordinator = [CYAppDelegate appDelegate].persistentStoreCoordinator;
    for (PFObject *map in maps) {
      [CYMap mapWithObject:map context:context save:NO];
    }

    [context saveWithSuccess:^{
      NSLog(@"Finished fetching maps and their points (%g s)", -start.timeIntervalSinceNow);
      if (block) block();
    }];
  });
}

- (void)loadPointsInContext:(NSManagedObjectContext *)context {
  PFQuery *mapQuery = [PFQuery queryWithClassName:MapClassName];
  [mapQuery whereKey:@"objectId" equalTo:self.unique];
  PFQuery *query = [PFQuery queryWithClassName:PointClassName];
  [query whereKey:PointMapKey matchesQuery:mapQuery];
  NSError *error = nil;
  NSArray *points = [query findObjects:&error];
  if (error) {
    NSLog(@"Error fetching points: %@ %@", error, error.userInfo);
    return;
  }

  for (PFObject *point in points) {
    [CYPoint pointWithObject:point context:context save:NO].map = self;
  }
}

#pragma mark - Creation

+ (CYMap *)mapWithObject:(PFObject *)object context:(NSManagedObjectContext *)context save:(BOOL)save {
  NSFetchRequest *request = [[NSFetchRequest alloc] init];
  request.entity = [NSEntityDescription entityForName:NSStringFromClass(self.class) inManagedObjectContext:context];
  request.predicate = [NSPredicate predicateWithFormat:@"unique = %@ OR name = %@", object.objectId, [object valueForKey:@"name"]];
  request.fetchLimit = 1;

  NSError *error = nil;
  NSArray *fetchedObjects = [context executeFetchRequest:request error:&error];
  if (error) {
    NSDictionary *userInfo = @{NSUnderlyingErrorKey : error};
    NSString *reason = [NSString stringWithFormat:@"Error fetching maps to check against %@", object.objectId];
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:reason userInfo:userInfo];
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
    // creating this map for the first time locally (from a server object) so fetch its points
    [map loadPointsInContext:context];
  } else if ([map.updatedAt compare:object.updatedAt] == NSOrderedAscending) {
    // we have a matching object, just update appropriate fields fields
    map.updatedAt = object.updatedAt;
    map.name = [object objectForKey:MapNameKey];
    map.summary = [object objectForKey:MapSummaryKey];
  }
  if (save) [context saveWithSuccess:nil];

  return map;
}

+ (CYMap *)mapWithName:(NSString *)name summary:(NSString *)summary context:(NSManagedObjectContext *)context save:(BOOL)save {
  PFObject *object = [PFObject objectWithClassName:MapClassName];
  [object setObject:name forKey:MapNameKey];
  [object setObject:summary forKey:MapSummaryKey];
  NSError *error = nil;
  if (![object save:&error]) {
    NSLog(@"Error getting unique ID for map from Parse: %@ %@", error.localizedDescription, error.userInfo);
    return nil;
  }

  return [CYMap mapWithObject:object context:context save:save];
}

- (void)saveToParseWithSuccess:(void (^)())block {
  PFObject *map = [PFObject objectWithoutDataWithClassName:MapClassName objectId:self.unique];
  [map setObject:self.name forKey:MapNameKey];
  [map setObject:self.summary forKey:MapSummaryKey];
  [map saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
    if (succeeded) {
      if (block) block();
    } else {
      NSLog(@"Error saving map %@ to Parse: %@ %@", self.unique, error.localizedDescription, error.userInfo);
    }
  }];
}

- (void)destroyWithSave:(BOOL)save {
  [[PFObject objectWithoutDataWithClassName:MapClassName objectId:self.unique] deleteEventually];
  [self.managedObjectContext deleteObject:self];
  if (save) [self.managedObjectContext saveWithSuccess:nil];
}

// workaround for http://stackoverflow.com/questions/7385439/exception-thrown-in-nsorderedset-generated-accessors
- (void)addPointsObject:(CYPoint *)point {
  NSMutableOrderedSet* tmp = [NSMutableOrderedSet orderedSetWithOrderedSet:self.points];
  [tmp addObject:point];
  self.points = tmp;
}

@end
