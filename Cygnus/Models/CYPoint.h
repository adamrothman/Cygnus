//
//  CYPoint.h
//  Cygnus
//
//  Created by Adam Rothman on 10/28/12.
//  Copyright (c) 2012 Cygnus. All rights reserved.
//

@interface CYPoint : NSObject

@property (nonatomic, readonly) NSString *objectID;
@property (nonatomic, readonly) NSDate *createdAt;
@property (nonatomic, readonly) NSDate *updatedAt;

@property (nonatomic, strong) PFGeoPoint *location;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *summary;
@property (nonatomic, strong) NSString *imageURLString;

+ (CYPoint *)pointWithObject:(PFObject *)object;

@end
