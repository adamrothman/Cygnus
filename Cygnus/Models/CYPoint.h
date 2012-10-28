//
//  CYPoint.h
//  Cygnus
//
//  Created by Adam Rothman on 10/28/12.
//  Copyright (c) 2012 Cygnus. All rights reserved.
//

#import "CYMap.h"

@interface CYPoint : NSObject

@property (nonatomic, strong) PFObject *backingObject;

@property (nonatomic, readonly) NSString *objectID;
@property (nonatomic, readonly) NSDate *createdAt;
@property (nonatomic, readonly) NSDate *updatedAt;

@property (nonatomic, strong) PFGeoPoint *location;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *summary;
@property (nonatomic, strong) NSString *imageURLString;

// relations
@property (nonatomic, strong) CYMap *map;

+ (CYPoint *)pointWithObject:(PFObject *)object;
- (void)save;

@end
