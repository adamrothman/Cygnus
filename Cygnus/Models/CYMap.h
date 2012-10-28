//
//  CYMap.h
//  Cygnus
//
//  Created by Adam Rothman on 10/28/12.
//  Copyright (c) 2012 Cygnus. All rights reserved.
//

typedef enum {
  CYMapVisibilityPublic,
  CYMapVisibilityPrivate
} CYMapVisibility;

@interface CYMap : NSObject

@property (nonatomic, strong) PFObject *backingObject;

@property (nonatomic, readonly) NSString *objectID;
@property (nonatomic, readonly) NSDate *createdAt;
@property (nonatomic, readonly) NSDate *updatedAt;

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *summary;
@property (nonatomic) CYMapVisibility visibility;

// relations
@property (nonatomic, strong) NSArray *points;

+ (CYMap *)mapWithObject:(PFObject *)object;
- (void)save;

@end
