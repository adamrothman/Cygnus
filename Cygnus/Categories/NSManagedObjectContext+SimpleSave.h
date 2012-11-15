//
//  NSManagedObjectContext+SimpleSave.h
//  Cygnus
//
//  Created by Adam Rothman on 11/14/12.
//  Copyright (c) 2012 Cygnus. All rights reserved.
//

@interface NSManagedObjectContext (SimpleSave)

- (void)saveWithSuccess:(void(^)())success;

@end
