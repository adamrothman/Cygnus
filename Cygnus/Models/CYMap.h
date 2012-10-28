//
//  CYMap.h
//  Cygnus
//
//  Created by Adam Rothman on 10/28/12.
//  Copyright (c) 2012 Cygnus. All rights reserved.
//

@interface CYMap : PFObject

@property (nonatomic, strong) NSArray *points; // of CYPoints
@property (nonatomic, strong) NSString *description;

@end
