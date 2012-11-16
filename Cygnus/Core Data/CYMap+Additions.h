//
//  CYMap+Additions.h
//  Cygnus
//
//  Created by Adam Rothman on 11/15/12.
//  Copyright (c) 2012 Cygnus. All rights reserved.
//

#import "CYMap.h"

@interface CYMap (Additions)

+ (void)fetchMapsWithSuccess:(void(^)())block;

+ (CYMap *)mapWithObject:(PFObject *)object inContext:(NSManagedObjectContext *)context save:(BOOL)save;
+ (CYMap *)mapInContext:(NSManagedObjectContext *)context save:(BOOL)save;

- (void)saveToParseWithSuccess:(void(^)())block;
- (void)destroyWithSave:(BOOL)save;

@end
