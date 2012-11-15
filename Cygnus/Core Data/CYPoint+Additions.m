//
//  CYPoint+Additions.m
//  Cygnus
//
//  Created by Adam Rothman on 11/15/12.
//  Copyright (c) 2012 Cygnus. All rights reserved.
//

#import "CYPoint+Additions.h"

@implementation CYPoint (Additions)

+ (CYPoint *)pointWithObject:(PFObject *)object inContext:(NSManagedObjectContext *)context save:(BOOL)save {
  CYPoint *point = nil;

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

  point = fetchedObjects.lastObject;
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

- (void)saveToParse {
  PFObject *point = [PFObject objectWithoutDataWithClassName:PointClassName objectId:self.unique];
  [point setObject:self.name forKey:PointNameKey];
  [point setObject:self.summary forKey:PointSummaryKey];
  [point setObject:self.imageURLString forKey:PointImageURLStringKey];
  PFGeoPoint *geoPoint = [PFGeoPoint geoPointWithLatitude:self.latitude.doubleValue longitude:self.longitude.doubleValue];
  [point setObject:geoPoint forKey:PointLocationKey];
  [point saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
    if (!succeeded) {
      NSLog(@"Error saving point %@ to Parse: %@ %@", self.unique, error.localizedDescription, error.userInfo);
    }
  }];
}

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
