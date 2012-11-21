//
//  CYAnalytics.h
//  Cygnus
//
//  Created by Juan-Carlos Foust on 11/15/12.
//  Copyright (c) 2012 Cygnus. All rights reserved.
//

#import "Mixpanel.h"
#import "Flurry.h"

extern NSString *const FlurryAPIKeyA;
extern NSString *const FlurryAPIKeyB;

extern NSString *const MixpanelTokenA;
extern NSString *const MixpanelTokenB;

extern NSString *const MixpanelUserPropertyEmail;
extern NSString *const MixpanelUserPropertyFirstName;
extern NSString *const MixpanelUserPropertyUsername;
extern NSString *const MixpanelUserPropertyiOSDevices;

extern NSString *const CYAnalyticsEventCrash;
extern NSString *const CYAnalyticsEventAppActive;
extern NSString *const CYAnalyticsEventAppInactive;

extern NSString *const CYAnalyticsEventMapVisited;
extern NSString *const CYAnalyticsEventPointDropped;
extern NSString *const CYAnalyticsEventPointCreated;

extern NSString *const CYAnalyticsEventMapsVisited;
extern NSString *const CYAnalyticsEventMapCreateSelected;
extern NSString *const CYAnalyticsEventMapCreated;

extern NSString *const CYAnalyticsEventMapDetailVisited;
extern NSString *const CYAnalyticsEventPointDetailVisited;

extern NSString *const CYAnalyticsEventCameraVisited;

#define CYANALYTICS_EVENT_SEARCH_VISIT

@interface CYAnalytics : NSObject

+ (void)startTrackingEvents;
+ (void)logEvent:(NSString* )eventName withParameters:(NSDictionary *)parameters;

+ (void)identityUser:(NSString *)userID;
+ (void)setUserProperties:(NSDictionary *)params;

+ (void)logError:(NSString *)err message:(NSString *)mssg error:(NSError *)errObj;
+ (void)logError:(NSString *)err message:(NSString *)mssg exception:(NSException *)excObj;

+ (void)reset;

@end

