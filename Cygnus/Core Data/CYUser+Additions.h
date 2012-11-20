//
//  CYUser+Additions.h
//  Cygnus
//
//  Created by Adam Rothman on 11/15/12.
//  Copyright (c) 2012 Cygnus. All rights reserved.
//

#import "CYUser.h"
#import "CYMap+Additions.h"

@interface CYUser (Additions)

+ (CYMap *)activeMap;
+ (void)setActiveMap:(CYMap *)map;

@end
