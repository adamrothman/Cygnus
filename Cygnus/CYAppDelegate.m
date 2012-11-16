//
//  CYAppDelegate.m
//  Cygnus
//
//  Created by Adam Rothman on 10/21/12.
//  Copyright (c) 2012 Cygnus. All rights reserved.
//

#import "CYAppDelegate.h"
#import "CYMap+Additions.h"

@implementation CYAppDelegate

@synthesize managedObjectContext=_managedObjectContext;
@synthesize managedObjectModel=_managedObjectModel;
@synthesize persistentStoreCoordinator=_persistentStoreCoordinator;

+ (CYAppDelegate *)appDelegate {
  return [UIApplication sharedApplication].delegate;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contextDidSave:) name:NSManagedObjectContextDidSaveNotification object:nil];

  // load Core Data if it isn't already
  [self managedObjectContext];
  [CYMap fetchMaps];
  [Parse setApplicationId:@"eZV1a910JvXmP1UrTsMy4cH4QZhLpjLoElLL1GIz"
                clientKey:@"e3fP5YlVRNIqev4CoH53d22JAeXEqiCWJBSpygJk"];
  
  [CYAnalytics startTrackingEvents];
  return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
  // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
  // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
  [CYAnalytics logEvent:CYANALYTICS_EVENT_APP_INACTIVE withParameters:nil];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
  // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
  // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
  // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
  // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  [CYAnalytics logEvent:CYANALYTICS_EVENT_APP_ACTIVE withParameters:nil];
}

- (void)applicationWillTerminate:(UIApplication *)application {
  // Saves changes in the application's managed object context before the application terminates.
  [self.managedObjectContext saveWithSuccess:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)contextDidSave:(NSNotification *)notification {
  dispatch_async(dispatch_get_main_queue(), ^{
    [self.managedObjectContext mergeChangesFromContextDidSaveNotification:notification];
  });
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext {
  if (_managedObjectContext) {
    return _managedObjectContext;
  }
  if (self.persistentStoreCoordinator) {
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    _managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator;
  }
  return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel {
  if (_managedObjectModel) {
    return _managedObjectModel;
  }
  NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Cygnus" withExtension:@"momd"];
  _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
  return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
  if (_persistentStoreCoordinator) {
    return _persistentStoreCoordinator;
  }

  NSURL *storeURL = [self.applicationDocumentsDirectory URLByAppendingPathComponent:@"Cygnus.sqlite"];

  NSError *error = nil;
  _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
  // perform automatic lightweight migration
  // only works for limited set of schema changes
  //consult "Core Data Model Versioning and Data Migration Programming Guide" for details
  NSDictionary *options = @{
    NSMigratePersistentStoresAutomaticallyOption : @YES,
    NSInferMappingModelAutomaticallyOption : @YES
  };
  if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
    NSDictionary *userInfo = @{NSUnderlyingErrorKey : error};
    NSString *reason = @"Could not create persistent store.";
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:reason userInfo:userInfo];
  }

  return _persistentStoreCoordinator;
}

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory {
  return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
