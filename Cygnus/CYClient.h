//
//  CYClient.h
//  Cygnus
//
//  Created by Adam Rothman on 11/14/12.
//  Copyright (c) 2012 Cygnus. All rights reserved.
//

#import "CYMap+Additions.h"

@interface CYClient : NSObject

+ (void)fetchMaps;

+ (void)fetchPointsForMap:(CYMap *)map;

@end
