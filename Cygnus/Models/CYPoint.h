//
//  CYPoint.h
//  Cygnus
//
//  Created by Adam Rothman on 10/28/12.
//  Copyright (c) 2012 Cygnus. All rights reserved.
//

#import "CYObject.h"
#import "CYMap.h"

@interface CYPoint : CYObject

@property (nonatomic, strong) PFGeoPoint *location;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *summary;
@property (nonatomic, strong) NSString *imageURLString;

// relations
@property (nonatomic, strong) CYMap *map;

+ (CYPoint *)pointWithObject:(PFObject *)object;

@end
