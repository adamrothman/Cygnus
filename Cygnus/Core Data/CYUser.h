//
//  CYUser.h
//  Cygnus
//
//  Created by Adam Rothman on 11/17/12.
//  Copyright (c) 2012 Cygnus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CYMap;

@interface CYUser : NSManagedObject

@property (nonatomic, retain) NSString * unique;
@property (nonatomic, retain) CYMap *activeMap;

@end
