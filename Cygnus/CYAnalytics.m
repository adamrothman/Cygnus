//
//  CYAnalytics.m
//  Cygnus
//
//  Created by Juan-Carlos Foust on 11/15/12.
//  Copyright (c) 2012 Cygnus. All rights reserved.
//

#import "CYAnalytics.h"

NSString *const FlurryAPIKeyA = @"T3854KRVTWBS2QJGT8YJ";
NSString *const FlurryAPIKeyB = @"554CRWWSDDZ7J3GJDNN6";

NSString *const MixpanelTokenA = @"92d317371b012072c4781e490b64a0d7";
NSString *const MixpanelTokenB = @"d5298691ab4b8f70de629f4a156f0f1d";

NSString *const MixpanelUserPropertyEmail = @"$email";
NSString *const MixpanelUserPropertyFirstName = @"$first_name";
NSString *const MixpanelUserPropertyUsername = @"$username";
NSString *const MixpanelUserPropertyiOSDevices = @"$ios_devices";

NSString *const CYAnalyticsEventCrash = @"CRASH!";
NSString *const CYAnalyticsEventAppActive = @"Application launch";
NSString *const CYAnalyticsEventAppInactive = @"Application closed";

NSString *const CYAnalyticsEventMapVisited = @"Map visit";
NSString *const CYAnalyticsEventPointDropped = @"User dropped point";
NSString *const CYAnalyticsEventPointCreated = @"User added point";

NSString *const CYAnalyticsEventMapsVisited = @"Search visit";
NSString *const CYAnalyticsEventMapCreateSelected = @"Map create selected";
NSString *const CYAnalyticsEventMapCreated = @"Map created";

NSString *const CYAnalyticsEventMapDetailVisited = @"Map detail visit";
NSString *const CYAnalyticsEventPointDetailVisited = @"Point detail visit";

NSString *const CYAnalyticsEventCameraVisited = @"Camera visit";
NSString *const CYAnalyticsEventPhotoUploaded = @"Photo uploaded";

void uncaughtExceptionHandler(NSException *exception) {
  [CYAnalytics logError:CYAnalyticsEventCrash message:nil exception:exception];
}

@implementation CYAnalytics

+ (void)startTrackingEvents {
  Mixpanel *sharedInstance = [Mixpanel sharedInstanceWithToken:MixpanelTokenB];
  sharedInstance.flushOnBackground = YES;
  sharedInstance.showNetworkActivityIndicator = NO;
  NSSetUncaughtExceptionHandler(uncaughtExceptionHandler);
  [Flurry startSession:FlurryAPIKeyB];
  [Flurry setSessionReportsOnPauseEnabled:YES];
}

+ (void)logEvent:(NSString* )eventName withParameters:(NSDictionary *)parameters {
  [[Mixpanel sharedInstance] track:eventName properties:parameters];
  [Flurry logEvent:eventName withParameters:parameters];
}

+ (void)identityUser:(NSString *)userID {
  [[Mixpanel sharedInstance] identify:userID];
  [[[Mixpanel sharedInstance] people] identify:userID];
}

+ (void)setUserProperties:(NSDictionary *)params {
  [[[Mixpanel sharedInstance] people] set:params];
  [[Mixpanel sharedInstance] registerSuperProperties:params];
}

+ (void)logError:(NSString *)err message:(NSString *)message error:(NSError *)errObj {
  NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
  if (errObj) params[@"NSError"] = [errObj description];
  if (message) params[@"Message"] = message;
  [Flurry logEvent:err withParameters:params];
  NSLog(@"CYANALYTICS ERROR LOG\n\n %@ \n\n MESSAGE\n\n %@ \n\n DESCRIPTION \n\n %@", err, message, [errObj description]);
}

+(void)logError:(NSString *)err message:(NSString *)message exception:(NSException *)excObj {
  NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
  if (excObj) params[@"NSException"] = [excObj description];
  if (message) params[@"Message"] = message;
  NSLog(@"CYANALYTICS EXCEPTION LOG\n\n %@ \n\n MESSAGE\n\n %@ \n\n DESCRIPTION \n\n %@", err, message, [excObj description]);
  [Flurry logEvent:err withParameters:params];
}

+ (void)reset {
  [[Mixpanel sharedInstance] flush];
  [[Mixpanel sharedInstance] reset];
}

@end
