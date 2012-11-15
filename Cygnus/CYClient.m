//
//  CYClient.m
//  Cygnus
//
//  Created by Adam Rothman on 11/14/12.
//  Copyright (c) 2012 Cygnus. All rights reserved.
//

#import "CYClient.h"
#import "CYAppDelegate.h"
#import "NSManagedObjectContext+SimpleSave.h"
#import "Point+Cygnus.h"

@implementation CYClient

+ (void)fetchMaps {
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
    PFQuery *query = [PFQuery queryWithClassName:@"Map"];
    NSError *error = nil;
    NSArray *maps = [query findObjects:&error];
    if (error) {
      NSLog(@"Error fetching maps: %@ %@", error, error.userInfo);
      return;
    }

    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSConfinementConcurrencyType];
    context.persistentStoreCoordinator = [CYAppDelegate appDelegate].persistentStoreCoordinator;
    for (PFObject *map in maps) {
      [Map mapWithObject:map inContext:context save:NO];
    }

    [context saveWithSuccess:^{
      // update UI, stop spinner, whatever (probably on the main thread)
    }];
  });
}

+ (void)fetchPointsForMap:(Map *)map {
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
    PFQuery *query = [PFQuery queryWithClassName:@"Point"];
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
      [Point pointWithObject:point inContext:context save:NO];
    }

    [context saveWithSuccess:^{
      // update UI, stop spinner, whatever (probably on the main thread)
    }];
  });
}

@end
