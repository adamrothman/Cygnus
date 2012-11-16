//
//  CYAppDelegate.h
//  Cygnus
//
//  Created by Adam Rothman on 10/21/12.
//  Copyright (c) 2012 Cygnus. All rights reserved.
//

@interface CYAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (CYAppDelegate *)appDelegate;
+ (NSManagedObjectContext *)mainContext;

@end
