//
//  CYMap+Additions.h
//  Cygnus
//
//  Created by Adam Rothman on 11/15/12.
//  Copyright (c) 2012 Cygnus. All rights reserved.
//

#import "CYMap.h"

@interface CYMap (Additions)

+ (CYMap *)mapWithObject:(PFObject *)object inContext:(NSManagedObjectContext *)context save:(BOOL)save;

- (void)saveToParse;

@end
