//
//  CYPoint+Additions.m
//  Cygnus
//
//  Created by Adam Rothman on 11/15/12.
//  Copyright (c) 2012 Cygnus. All rights reserved.
//

#import "CYPoint+Additions.h"
#import "CYAppDelegate.h"

@implementation CYPoint (Additions)

+ (void)fetchPointsForMap:(CYMap *)map {
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
    PFQuery *query = [PFQuery queryWithClassName:PointClassName];
    [query whereKey:@"objectId" equalTo:map.unique];
    NSError *error = nil;
    NSArray *points = [query findObjects:&error];
    if (error) {
      NSLog(@"Error fetching points: %@ %@", error, error.userInfo);
      return;
    }

    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSConfinementConcurrencyType];
    context.persistentStoreCoordinator = [CYAppDelegate appDelegate].persistentStoreCoordinator;
    for (PFObject *point in points) {
      [CYPoint pointWithObject:point inContext:context save:NO];
    }

    [context saveWithSuccess:^{
      // update UI, stop spinner, whatever (probably on the main thread)
    }];
  });
}

+ (CYPoint *)pointWithObject:(PFObject *)object inContext:(NSManagedObjectContext *)context save:(BOOL)save {
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

  CYPoint *point = fetchedObjects.lastObject;
  if (!point) {
    // no CD object for this PFObject yet
    point = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass(self.class) inManagedObjectContext:context];
    point.unique = object.objectId;
    point.createdAt = object.createdAt;
    point.updatedAt = object.updatedAt;
    point.name = [object objectForKey:PointNameKey];
    point.summary = [object objectForKey:PointSummaryKey];
    point.imageURLString = [object objectForKey:PointImageURLStringKey];
    PFGeoPoint *geoPoint = [object objectForKey:PointLocationKey];
    point.latitude = [NSNumber numberWithDouble:geoPoint.latitude];
    point.longitude = [NSNumber numberWithDouble:geoPoint.longitude];
    if (save) [context saveWithSuccess:nil];
  } else if ([point.updatedAt compare:object.updatedAt] == NSOrderedAscending) {
    // we have a matching object, just update appropriate fields fields
    point.updatedAt = object.updatedAt;
    point.name = [object objectForKey:PointNameKey];
    point.summary = [object objectForKey:PointSummaryKey];
    point.imageURLString = [object objectForKey:PointImageURLStringKey];
    PFGeoPoint *geoPoint = [object objectForKey:PointLocationKey];
    point.latitude = [NSNumber numberWithDouble:geoPoint.latitude];
    point.longitude = [NSNumber numberWithDouble:geoPoint.longitude];
    if (save) [context saveWithSuccess:nil];
  }

  return point;
}

+ (CYPoint *)pointInContext:(NSManagedObjectContext *)context save:(BOOL)save {
  CYPoint *point = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass(self.class) inManagedObjectContext:context];
  [point saveToParseWithSuccess:^{
    if (save) [context saveWithSuccess:nil];
  }];
  return point;
}

- (void)saveToParseWithSuccess:(void (^)())block {
  PFObject *point = nil;
  if (self.unique) { // existing
    point = [PFObject objectWithoutDataWithClassName:PointClassName objectId:self.unique];
  } else { // new
    point = [PFObject objectWithClassName:PointClassName];
  }

  [point setObject:self.name forKey:PointNameKey];
  [point setObject:self.summary forKey:PointSummaryKey];
  [point setObject:self.imageURLString forKey:PointImageURLStringKey];
  PFGeoPoint *geoPoint = [PFGeoPoint geoPointWithLatitude:self.latitude.doubleValue longitude:self.longitude.doubleValue];
  [point setObject:geoPoint forKey:PointLocationKey];
  [point saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
    if (succeeded) {
      if (!self.unique) self.unique = point.objectId;
      if (block) block();
    } else {
      NSLog(@"Error saving point %@ to Parse: %@ %@", self.unique, error.localizedDescription, error.userInfo);
    }
  }];
}

- (void)destroyWithSave:(BOOL)save {
  if (self.unique) {
    PFObject *point = [PFObject objectWithoutDataWithClassName:PointClassName objectId:self.unique];
    [point deleteInBackground];
  }
  [self.managedObjectContext deleteObject:self];
  if (save) [self.managedObjectContext saveWithSuccess:nil];
}

#pragma mark - MKAnnotation

- (CLLocationCoordinate2D)coordinate {
  return CLLocationCoordinate2DMake(self.latitude.doubleValue, self.longitude.doubleValue);
}

- (void)setCoordinate:(CLLocationCoordinate2D)coordinate {
  self.latitude = [NSNumber numberWithDouble:coordinate.latitude];
  self.longitude = [NSNumber numberWithDouble:coordinate.longitude];
}

- (NSString *)title {
  return self.name;
}

- (NSString *)subtitle {
  return self.summary;
}

@end
