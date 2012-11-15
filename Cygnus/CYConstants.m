//
//  CYConstants.m
//  Cygnus
//
//  Created by Adam Rothman on 11/14/12.
//  Copyright (c) 2012 Cygnus. All rights reserved.
//

#import "CYConstants.h"

// Map
NSString *const MapClassName = @"Map";
NSString *const MapNameKey = @"name";
NSString *const MapSummaryKey = @"summary";

// Point
NSString *const PointClassName = @"Point";
NSString *const PointNameKey = @"name";
NSString *const PointSummaryKey = @"summary";
NSString *const PointImageURLStringKey = @"image_url";
NSString *const PointLocationKey = @"location";

// Notifications
NSString *const CYUserDidLogOutNotification = @"cy_user_did_log_out";
NSString *const CYUserUnfollowedMapNotification = @"cy_user_unfollowed_map";
NSString *const CYSignificantLocationChangeNotification = @"cy_significant_location_change";