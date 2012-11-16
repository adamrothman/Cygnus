//
//  CYAnalytics.m
//  Cygnus
//
//  Created by Juan-Carlos Foust on 11/15/12.
//  Copyright (c) 2012 Cygnus. All rights reserved.
//

#import "CYAnalytics.h"

void uncaughtExceptionHandler(NSException *exception) {
  [CYAnalytics logError:CYANALYTICS_CRASH_EVENT message:nil exception:exception];
}

@implementation CYAnalytics

+(void)startTrackingEvents
{
  Mixpanel *sharedInstance = [Mixpanel sharedInstanceWithToken:MIXPANEL_TOKEN_A];
  sharedInstance.flushOnBackground = YES;
  sharedInstance.showNetworkActivityIndicator = NO;
  NSSetUncaughtExceptionHandler(uncaughtExceptionHandler);
  [Flurry startSession:FLURRY_API_KEY_A];
  [Flurry setSessionReportsOnPauseEnabled:YES];
}

+ (void)logEvent:(NSString* )eventName withParameters:(NSDictionary *)parameters
{
  [[Mixpanel sharedInstance] track:eventName properties:parameters];
  [Flurry logEvent:eventName withParameters:parameters];
}

+ (void)identityUser:(NSString *)userID
{
  [[Mixpanel sharedInstance] identify:userID];
  [[[Mixpanel sharedInstance] people] identify:userID];
}

+ (void)setUserProperties:(NSDictionary *)params
{
  [[[Mixpanel sharedInstance] people] set:params];
  [[Mixpanel sharedInstance] registerSuperProperties:params];
}

+(void)logError:(NSString *)err message:(NSString *)message error:(NSError *)errObj
{
  NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
  if (errObj) params[@"NSError"] = [errObj description];
  if (message) params[@"Message"] = message;
  [Flurry logEvent:err withParameters:params];
  NSLog(@"CYANALYTICS ERROR LOG\n\n %@ \n\n MESSAGE\n\n %@ \n\n DESCRIPTION \n\n %@", err, message, [errObj description]);
}

+(void)logError:(NSString *)err message:(NSString *)message exception:(NSException *)excObj
{
  NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
  if (excObj) params[@"NSException"] = [excObj description];
  if (message) params[@"Message"] = message;
  NSLog(@"CYANALYTICS EXCEPTION LOG\n\n %@ \n\n MESSAGE\n\n %@ \n\n DESCRIPTION \n\n %@", err, message, [excObj description]);
  [Flurry logEvent:err withParameters:params];
}

+ (void)reset
{
  [[Mixpanel sharedInstance] flush];
  [[Mixpanel sharedInstance] reset];
}

@end
