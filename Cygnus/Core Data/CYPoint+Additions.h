//
//  CYPoint+Additions.h
//  Cygnus
//
//  Created by Adam Rothman on 11/15/12.
//  Copyright (c) 2012 Cygnus. All rights reserved.
//

#import "CYPoint.h"

@interface CYPoint (Additions) <MKAnnotation>

@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly, copy) NSString *title;
@property (nonatomic, readonly, copy) NSString *subtitle;

+ (CYPoint *)pointWithObject:(PFObject *)object inContext:(NSManagedObjectContext *)context save:(BOOL)save;

- (void)saveToParse;

@end
