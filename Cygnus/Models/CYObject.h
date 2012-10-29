//
//  CYObject.h
//  Cygnus
//
//  Created by Adam Rothman on 10/28/12.
//  Copyright (c) 2012 Cygnus. All rights reserved.
//

@interface CYObject : NSObject

@property (nonatomic, strong) PFObject *backingObject;

@property (nonatomic, readonly) NSString *objectID;
@property (nonatomic, readonly) NSDate *createdAt;
@property (nonatomic, readonly) NSDate *updatedAt;

- (id)initWithObject:(PFObject *)object;

- (void)save;

@end
