//
//  CYPoint.h
//  Cygnus
//
//  Created by Adam Rothman on 11/15/12.
//  Copyright (c) 2012 Cygnus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CYMap;

@interface CYPoint : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * summary;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) NSString * unique;
@property (nonatomic, retain) NSString * imageURLString;
@property (nonatomic, retain) CYMap *map;

@end
