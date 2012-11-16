//
//  CYPoint+Additions.m
//  Cygnus
//
//  Created by Adam Rothman on 11/15/12.
//  Copyright (c) 2012 Cygnus. All rights reserved.
//

#import "CYPoint+Additions.h"

@implementation CYPoint (Additions)

#pragma mark - Creation

+ (CYPoint *)pointWithObject:(PFObject *)object context:(NSManagedObjectContext *)context save:(BOOL)save {
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
    point.latitude = @(geoPoint.latitude);
    point.longitude = @(geoPoint.longitude);
  } else if ([point.updatedAt compare:object.updatedAt] == NSOrderedAscending) {
    // we have a matching object, just update appropriate fields fields
    point.updatedAt = object.updatedAt;
    point.name = [object objectForKey:PointNameKey];
    point.summary = [object objectForKey:PointSummaryKey];
    point.imageURLString = [object objectForKey:PointImageURLStringKey];
    PFGeoPoint *geoPoint = [object objectForKey:PointLocationKey];
    point.latitude = @(geoPoint.latitude);
    point.longitude = @(geoPoint.longitude);
  }
  if (save) [context saveWithSuccess:nil];

  return point;
}

+ (CYPoint *)pointWithName:(NSString *)name summary:(NSString *)summary imageURLString:(NSString *)imageURLString location:(CLLocationCoordinate2D)location map:(CYMap *)map context:(NSManagedObjectContext *)context save:(BOOL)save {
  PFObject *object = [PFObject objectWithClassName:PointClassName];
  [object setObject:name forKey:PointNameKey];
  [object setObject:summary forKey:PointSummaryKey];
  [object setObject:imageURLString forKey:PointImageURLStringKey];
  [object setObject:[PFGeoPoint geoPointWithLatitude:location.latitude longitude:location.longitude] forKey:PointLocationKey];
  [object setObject:[PFObject objectWithoutDataWithClassName:MapClassName objectId:map.unique] forKey:PointMapKey];
  NSError *error = nil;
  if (![object save:&error]) {
    NSLog(@"Error getting unique ID for point from Parse: %@ %@", error.localizedDescription, error.userInfo);
    return nil;
  }

  CYPoint *point = [CYPoint pointWithObject:object context:context save:NO];
  [map addPointsObject:point];
  if (save) [context saveWithSuccess:nil];

  return point;
}

- (void)saveToParseWithSuccess:(void (^)())block {
  PFObject *point = [PFObject objectWithoutDataWithClassName:PointClassName objectId:self.unique];
  [point setObject:self.name forKey:PointNameKey];
  [point setObject:self.summary forKey:PointSummaryKey];
  [point setObject:self.imageURLString forKey:PointImageURLStringKey];
  [point setObject:[PFGeoPoint geoPointWithLatitude:self.latitude.doubleValue longitude:self.longitude.doubleValue] forKey:PointLocationKey];
  [point setObject:[PFObject objectWithoutDataWithClassName:MapClassName objectId:self.map.unique] forKey:PointMapKey];
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
