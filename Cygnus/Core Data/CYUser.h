//
//  CYUser.h
//  Cygnus
//
//  Created by Juan-Carlos Foust on 11/15/12.
//  Copyright (c) 2012 Cygnus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CYMap;

@interface CYUser : NSManagedObject

@property (nonatomic, retain) CYMap *activeMap;
@property (nonatomic, retain) NSOrderedSet *maps;
@end

@interface CYUser (CoreDataGeneratedAccessors)

- (void)insertObject:(CYMap *)value inMapsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromMapsAtIndex:(NSUInteger)idx;
- (void)insertMaps:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeMapsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInMapsAtIndex:(NSUInteger)idx withObject:(CYMap *)value;
- (void)replaceMapsAtIndexes:(NSIndexSet *)indexes withMaps:(NSArray *)values;
- (void)addMapsObject:(CYMap *)value;
- (void)removeMapsObject:(CYMap *)value;
- (void)addMaps:(NSOrderedSet *)values;
- (void)removeMaps:(NSOrderedSet *)values;
@end
