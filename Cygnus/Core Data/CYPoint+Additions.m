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

#pragma mark - Creation

+ (CYPoint *)pointWithObject:(PFObject *)object inContext:(NSManagedObjectContext *)context save:(BOOL)save {
  NSFetchRequest *request = [[NSFetchRequest alloc] init];
  request.entity = [NSEntityDescription entityForName:NSStringFromClass(self.class) inManagedObjectContext:context];
  request.predicate = [NSPredicate predicateWithFormat:@"unique = %@", object.objectId];
  request.fetchLimit = 1;

  NSError *error = nil;
  NSArray *fetchedObjects = [context executeFetchRequest:request error:&error];
  if (error) {
    NSDictionary *userInfo = @{NSUnderlyingErrorKey : error};
    NSString *reason = [NSString stringWithFormat:@"Error fetching points to check against %@", object.objectId];
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:reason userInfo:userInfo];
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
  } else if ([point.updatedAt compare:object.updatedAt] == NSOrderedAscending) {
    // we have a matching object, just update appropriate fields fields
    point.updatedAt = object.updatedAt;
    point.name = [object objectForKey:PointNameKey];
    point.summary = [object objectForKey:PointSummaryKey];
    point.imageURLString = [object objectForKey:PointImageURLStringKey];
    PFGeoPoint *geoPoint = [object objectForKey:PointLocationKey];
    point.latitude = [NSNumber numberWithDouble:geoPoint.latitude];
    point.longitude = [NSNumber numberWithDouble:geoPoint.longitude];
  }
  if (save) [context saveWithSuccess:nil];

  return point;
}

+ (CYPoint *)pointInContext:(NSManagedObjectContext *)context save:(BOOL)save {
  PFObject *parsePoint = [PFObject objectWithClassName:PointClassName];
  NSError *error = nil;
  if (![parsePoint save:&error]) {
    NSLog(@"Error getting unique ID for point from Parse: %@ %@", error.localizedDescription, error.userInfo);
    return nil;
  }

  CYPoint *point = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass(self.class) inManagedObjectContext:context];
  point.unique = parsePoint.objectId;
  if (save) [context saveWithSuccess:nil];

  return point;
}

- (void)saveToParseWithSuccess:(void (^)())block {
  PFObject *point = [PFObject objectWithoutDataWithClassName:PointClassName objectId:self.unique];

  if (self.name) [point setObject:self.name forKey:PointNameKey];
  if (self.summary) [point setObject:self.summary forKey:PointSummaryKey];
  if (self.imageURLString) [point setObject:self.imageURLString forKey:PointImageURLStringKey];
  if (self.latitude && self.longitude) {
    PFGeoPoint *geoPoint = [PFGeoPoint geoPointWithLatitude:self.latitude.doubleValue longitude:self.longitude.doubleValue];
    [point setObject:geoPoint forKey:PointLocationKey];
  }

  [point saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
    if (succeeded) {
      if (block) block();
    } else {
      NSLog(@"Error saving point %@ to Parse: %@ %@", self.unique, error.localizedDescription, error.userInfo);
    }
  }];
}

- (void)destroyWithSave:(BOOL)save {
  [[PFObject objectWithoutDataWithClassName:PointClassName objectId:self.unique] deleteEventually];
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
