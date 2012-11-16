//
//  CYAnalytics.h
//  Cygnus
//
//  Created by Juan-Carlos Foust on 11/15/12.
//  Copyright (c) 2012 Cygnus. All rights reserved.
//

#import "Mixpanel.h"
#import "Flurry.h"

#define FLURRY_API_KEY_A                                            @"T3854KRVTWBS2QJGT8YJ"
#define MIXPANEL_TOKEN_A                                            @"92d317371b012072c4781e490b64a0d7"
#define FLURRY_API_KEY_B                                            @"554CRWWSDDZ7J3GJDNN6"
#define MIXPANEL_TOKEN_B                                            @"d5298691ab4b8f70de629f4a156f0f1d"

#define MIXPANEL_USER_PROPERTY_EMAIL                                @"$email"
#define MIXPANEL_USER_PROPERTY_FIRST_NAME                           @"$first_name"
#define MIXPANEL_USER_PROPERTY_USERNAME                             @"$username"
#define MIXPANEL_USER_PROPERTY_IOS_DEVICES                          @"$ios_devices"

#define CYANALYTICS_CRASH_EVENT                                     @"CRASH!"
#define CYANALYTICS_EVENT_APP_ACTIVE                                @"Application launch"
#define CYANALYTICS_EVENT_APP_INACTIVE                              @"Application closed"

#define CYANALYTICS_EVENT_CONSOLE_VISIT                             @"Console visit"
#define CYANALYTICS_EVENT_MAP_VISIT                                 @"Map visit"
#define CYANALYTICS_EVENT_MAP_ADD_SELECTED                          @"Map add selected"
#define CYANALYTICS_EVENT_MAP_CREATE_SELECTED                       @"Map create selected"
#define CYANALYTICS_EVENT_MAP_CREATED                               @"Map created"

#define CYANALYTICS_EVENT_MAP_DETAIL_VISIT                          @"Map detail visit"
#define CYANALYTICS_EVENT_POINT_DETAIL_VISIT                        @"Point detail visit"
#define CYANALYTICS_EVENT_CAMERA_VISIT                              @"Camera visit"

#define CYANALYTICS_EVENT_USER_DROPPED_POINT                        @"User dropped point"
#define CYANALYTICS_EVENT_USER_ADDED_POINT                          @"User added point"

#define CYANALYTICS_EVENT_SEARCH_VISIT                              @"Search visit"

@interface CYAnalytics : NSObject

+ (void)startTrackingEvents;
+ (void)logEvent:(NSString* )eventName withParameters:(NSDictionary *)parameters;

+ (void)identityUser:(NSString *)userID;
+ (void)setUserProperties:(NSDictionary *)params;

+ (void)logError:(NSString *)err message:(NSString *)mssg error:(NSError *)errObj;
+ (void)logError:(NSString *)err message:(NSString *)mssg exception:(NSException *)excObj;

+ (void)reset;

@end

