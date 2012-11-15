//
//  CYMap.h
//  Cygnus
//
//  Created by Adam Rothman on 11/15/12.
//  Copyright (c) 2012 Cygnus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CYPoint;

@interface CYMap : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * summary;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) NSString * unique;
@property (nonatomic, retain) NSOrderedSet *points;
@end

@interface CYMap (CoreDataGeneratedAccessors)

- (void)insertObject:(CYPoint *)value inPointsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromPointsAtIndex:(NSUInteger)idx;
- (void)insertPoints:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removePointsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInPointsAtIndex:(NSUInteger)idx withObject:(CYPoint *)value;
- (void)replacePointsAtIndexes:(NSIndexSet *)indexes withPoints:(NSArray *)values;
- (void)addPointsObject:(CYPoint *)value;
- (void)removePointsObject:(CYPoint *)value;
- (void)addPoints:(NSOrderedSet *)values;
- (void)removePoints:(NSOrderedSet *)values;
@end
