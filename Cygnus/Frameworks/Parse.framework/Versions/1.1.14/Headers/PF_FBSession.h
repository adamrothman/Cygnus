/*
 * Copyright 2012 Facebook
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import <Foundation/Foundation.h>

// up-front decl's
@class PF_FBSession;
@class PF_FBSessionTokenCachingStrategy;

#define PF_FB_SESSIONSTATETERMINALBIT (1 << 8)

#define PF_FB_SESSIONSTATEOPENBIT (1 << 9)

/*
 * Constants used by NSNotificationCenter for active session notification
 */

/*! NSNotificationCenter name indicating that a new active session was set */
extern NSString *const PF_FBSessionDidSetActiveSessionNotification;

/*! NSNotificationCenter name indicating that an active session was unset */
extern NSString *const PF_FBSessionDidUnsetActiveSessionNotification;

/*! NSNotificationCenter name indicating that the active session is open */
extern NSString *const PF_FBSessionDidBecomeOpenActiveSessionNotification;

/*! NSNotificationCenter name indicating that there is no longer an open active session */
extern NSString *const PF_FBSessionDidBecomeClosedActiveSessionNotification;

/*!
 @typedef PF_FBSessionState enum

 @abstract Passed to handler block each time a session state changes

 @discussion
 */
typedef enum {
    /*! One of two initial states indicating that no valid cached token was found */
    PF_FBSessionStateCreated                   = 0,
    /*! One of two initial session states indicating that a cached token was loaded;
     when a session is in this state, a call to open* will result in an open session,
     without UX or app-switching*/
    PF_FBSessionStateCreatedTokenLoaded        = 1,
    /*! One of three pre-open session states indicating that an attempt to open the session
     is underway*/
    PF_FBSessionStateCreatedOpening            = 2,

    /*! Open session state indicating user has logged in or a cached token is available */
    PF_FBSessionStateOpen                      = 1 | PF_FB_SESSIONSTATEOPENBIT,
    /*! Open session state indicating token has been extended */
    PF_FBSessionStateOpenTokenExtended         = 2 | PF_FB_SESSIONSTATEOPENBIT,

    /*! Closed session state indicating that a login attempt failed */
    PF_FBSessionStateClosedLoginFailed         = 1 | PF_FB_SESSIONSTATETERMINALBIT, // NSError obj w/more info
    /*! Closed session state indicating that the session was closed, but the users token
        remains cached on the device for later use */
    PF_FBSessionStateClosed                    = 2 | PF_FB_SESSIONSTATETERMINALBIT, // "
} PF_FBSessionState;

/*! helper macro to test for states that imply an open session */
#define PF_FB_ISSESSIONOPENWITHSTATE(state) (0 != (state & PF_FB_SESSIONSTATEOPENBIT))

/*! helper macro to test for states that are terminal */
#define PF_FB_ISSESSIONSTATETERMINAL(state) (0 != (state & PF_FB_SESSIONSTATETERMINALBIT))

/*!
 @typedef PF_FBSessionLoginBehavior enum

 @abstract
 Passed to open to indicate whether Facebook Login should allow for fallback to be attempted.

 @discussion
 Facebook Login authorizes the application to act on behalf of the user, using the user's
 Facebook account. Usually a Facebook Login will rely on an account maintained outside of
 the application, by the native Facebook application, the browser, or perhaps the device
 itself. This avoids the need for a user to enter their username and password directly, and
 provides the most secure and lowest friction way for a user to authorize the application to
 interact with Facebook. If a Facebook Login is not possible, a fallback Facebook Login may be
 attempted, where the user is prompted to enter their credentials in a web-view hosted directly
 by the application.

 The `PF_FBSessionLoginBehavior` enum specifies whether to allow fallback, disallow fallback, or
 force fallback login behavior. Most applications will use the default, which attempts a normal
 Facebook Login, and only falls back if needed. In rare cases, it may be preferable to disallow
 fallback Facebook Login completely, or to force a fallback login.
 */
typedef enum {
    /*! Attempt Facebook Login, ask user for credentials if necessary */
    PF_FBSessionLoginBehaviorWithFallbackToWebView      = 0,
    /*! Attempt Facebook Login, no direct request for credentials will be made */
    PF_FBSessionLoginBehaviorWithNoFallbackToWebView    = 1,
    /*! Only attempt WebView Login; ask user for credentials */
    PF_FBSessionLoginBehaviorForcingWebView             = 2,
    /*! Attempt Facebook Login, prefering system acount and falling back to fast app switch if necessary */
    PF_FBSessionLoginBehaviorUseSystemAccountIfPresent  = 3,
} PF_FBSessionLoginBehavior;

/*!
 @typedef FBSessionDefaultAudience enum

 @abstract
 Passed to open to indicate which default audience to use for sessions that post data to Facebook.

 @discussion
 Certain operations such as publishing a status or publishing a photo require an audience. When the user
 grants an application permission to perform a publish operation, a default audience is selected as the
 publication ceiling for the application. This enumerated value allows the application to select which
 audience to ask the user to grant publish permission for.
 */
typedef enum {
    /*! No audience needed; this value is useful for cases where data will only be read from Facebook */
    PF_FBSessionDefaultAudienceNone                = 0,
    /*! Indicates that only the user is able to see posts made by the application */
    PF_FBSessionDefaultAudienceOnlyMe              = 10,
    /*! Indicates that the user's friends are able to see posts made by the application */
    PF_FBSessionDefaultAudienceFriends             = 20,
    /*! Indicates that all Facebook users are able to see posts made by the application */
    PF_FBSessionDefaultAudienceEveryone            = 30,
} PF_FBSessionDefaultAudience;

/*!
 @typedef PF_FBSessionLoginType enum

 @abstract
 Used as the type of the loginType property in order to specify what underlying technology was used to
 login the user.

 @discussion
 The PF_FBSession object is an abstraction over five distinct mechanisms. This enum allows an application
 to test for the mechanism used by a particular instance of PF_FBSession. Usually the mechanism used for a
 given login does not matter, however for certain capabilities, the type of login can impact the behavior
 of other Facebook functionality.
 */
typedef enum {
    /*! A login type has not yet been established */
    PF_FBSessionLoginTypeNone                      = 0,
    /*! A system integrated account was used to log the user into the application */
    PF_FBSessionLoginTypeSystemAccount             = 1,
    /*! The Facebook native application was used to log the user into the application */
    PF_FBSessionLoginTypeFacebookApplication       = 2,
    /*! Safari was used to log the user into the application */
    PF_FBSessionLoginTypeFacebookViaSafari         = 3,
    /*! A web view was used to log the user into the application */
    PF_FBSessionLoginTypeWebView                   = 4,
    /*! A test user was used to create an open session */
    PF_FBSessionLoginTypeTestUser                  = 5,
} PF_FBSessionLoginType;

/*!
 @typedef

 @abstract Block type used to define blocks called by <PF_FBSession> for state updates
 @discussion
 */
typedef void (^PF_FBSessionStateHandler)(PF_FBSession *session,
                                       PF_FBSessionState status,
                                       NSError *error);

/*!
 @typedef

 @abstract Block type used to define blocks called by <[PF_FBSession reauthorizeWithPermissions]>/.

 @discussion
 */
typedef void (^PF_FBSessionReauthorizeResultHandler)(PF_FBSession *session,
                                                  NSError *error);

/*!
 @class PF_FBSession

 @abstract
 The `PF_FBSession` object is used to authenticate a user and manage the user's session. After
 initializing a `PF_FBSession` object the Facebook App ID and desired permissions are stored.
 Opening the session will initiate the authentication flow after which a valid user session
 should be available and subsequently cached. Closing the session can optionally clear the
 cache.

 If an  <PF_FBRequest> request requires user authorization then an `PF_FBSession` object should be used.


 @discussion
 Instances of the `PF_FBSession` class provide notification of state changes in the following ways:

 1. Callers of certain `PF_FBSession` methods may provide a block that will be called
 back in the course of state transitions for the session (e.g. login or session closed).

 2. The object supports Key-Value Observing (KVO) for property changes.
 */
@interface PF_FBSession : NSObject

/*!
 @methodgroup Creating a session
 */

/*!
 @method

 @abstract
 Returns a newly initialized Facebook session with default values for the parameters
 to <initWithAppID:permissions:urlSchemeSuffix:tokenCacheStrategy:>.
 */
- (id)init;

/*!
 @method

 @abstract
 Returns a newly initialized Facebook session with the specified permissions and other
 default values for parameters to <initWithAppID:permissions:urlSchemeSuffix:tokenCacheStrategy:>.

 @param permissions  An array of strings representing the permissions to request during the
 authentication flow. A value of nil indicates basic permissions. The default is nil.

 @discussion
 It is required that any single permission request request (including initial log in) represent read-only permissions
 or publish permissions only; not both. The permissions passed here should reflect this requirement.

 */
- (id)initWithPermissions:(NSArray*)permissions;

/*!
 @method

 @abstract
 Following are the descriptions of the arguments along with their
 defaults when ommitted.

 @param permissions  An array of strings representing the permissions to request during the
 authentication flow. A value of nil indicates basic permissions. The default is nil.
 @param appID  The Facebook App ID for the session. If nil is passed in the default App ID will be obtained from a call to <[FBSession defaultAppID]>. The default is nil.
 @param urlSchemeSuffix  The URL Scheme Suffix to be used in scenarious where multiple iOS apps use one Facebook App ID. A value of nil indicates that this information should be pulled from the plist. The default is nil.
 @param tokenCachingStrategy Specifies a key name to use for cached token information in NSUserDefaults, nil
 indicates a default value of @"FBAccessTokenInformationKey".

 @discussion
 It is required that any single permission request request (including initial log in) represent read-only permissions
 or publish permissions only; not both. The permissions passed here should reflect this requirement.
 */
- (id)initWithAppID:(NSString*)appID
        permissions:(NSArray*)permissions
    urlSchemeSuffix:(NSString*)urlSchemeSuffix
 tokenCacheStrategy:(PF_FBSessionTokenCachingStrategy*)tokenCachingStrategy;

/*!
 @method

 @abstract
 Following are the descriptions of the arguments along with their
 defaults when ommitted.

 @param permissions  An array of strings representing the permissions to request during the
 authentication flow. A value of nil indicates basic permissions. The default is nil.
 @param defaultAdience Most applications use PF_FBSessionDefaultAudienceNone here, Only specifying the audience when using reauthorize to request publish permissions.
 @param appID  The Facebook App ID for the session. If nil is passed in the default App ID will be obtained from a call to <[PF_FBSession defaultAppID]>. The default is nil.
 @param urlSchemeSuffix  The URL Scheme Suffix to be used in scenarious where multiple iOS apps use one Facebook App ID. A value of nil indicates that this information should be pulled from the plist. The default is nil.
 @param tokenCachingStrategy Specifies a key name to use for cached token information in NSUserDefaults, nil
 indicates a default value of @"PF_FBAccessTokenInformationKey".

 @discussion
 It is required that any single permission request request (including initial log in) represent read-only permissions
 or publish permissions only; not both. The permissions passed here should reflect this requirement. If publish permissions
 are used, then the audience must also be specified.
 */
- (id)initWithAppID:(NSString*)appID
        permissions:(NSArray*)permissions
    defaultAudience:(PF_FBSessionDefaultAudience)defaultAudience
    urlSchemeSuffix:(NSString*)urlSchemeSuffix
 tokenCacheStrategy:(PF_FBSessionTokenCachingStrategy*)tokenCachingStrategy;

// instance readonly properties

/*! @abstract Indicates whether the session is open and ready for use. */
@property(readonly) BOOL isOpen;

/*! @abstract Detailed session state */
@property(readonly) PF_FBSessionState state;

/*! @abstract Identifies the Facebook app which the session object represents. */
@property(readonly, copy) NSString *appID;

/*! @abstract Identifies the URL Scheme Suffix used by the session. This is used when multiple iOS apps share a single Facebook app ID. */
@property(readonly, copy) NSString *urlSchemeSuffix;

/*! @abstract The access token for the session object. */
@property(readonly, copy) NSString *accessToken;

/*! @abstract The expiration date of the access token for the session object. */
@property(readonly, copy) NSDate *expirationDate;

/*! @abstract The permissions granted to the access token during the authentication flow. */
@property(readonly, copy) NSArray *permissions;

/*! @abstract Specifies the login type used to authenticate the user. */
@property(readonly) PF_FBSessionLoginType loginType;
/*!
 @methodgroup Instance methods
 */

/*!
 @method

 @abstract Opens a session for the Facebook.

 @discussion
 A session may not be used with <PF_FBRequest> and other classes in the SDK until it is open. If, prior
 to calling open, the session is in the <PF_FBSessionStateCreatedTokenLoaded> state, then no UX occurs, and
 the session becomes available for use. If the session is in the <PF_FBSessionStateCreated> state, prior
 to calling open, then a call to open causes login UX to occur, either via the Facebook application
 or via mobile Safari.

 Open may be called at most once and must be called after the `PF_FBSession` is initialized. Open must
 be called before the session is closed. Calling an open method at an invalid time will result in
 an exception. The open session methods may be passed a block that will be called back when the session
 state changes. The block will be released when the session is closed.

 @param handler A block to call with the state changes. The default is nil.
*/
- (void)openWithCompletionHandler:(PF_FBSessionStateHandler)handler;

/*!
 @method

 @abstract Logs a user on to Facebook.

 @discussion
 A session may not be used with <PF_FBRequest> and other classes in the SDK until it is open. If, prior
 to calling open, the session is in the <PF_FBSessionStateCreatedTokenLoaded> state, then no UX occurs, and
 the session becomes available for use. If the session is in the <PF_FBSessionStateCreated> state, prior
 to calling open, then a call to open causes login UX to occur, either via the Facebook application
 or via mobile Safari.

 The method may be called at most once and must be called after the `PF_FBSession` is initialized. It must
 be called before the session is closed. Calling the method at an invalid time will result in
 an exception. The open session methods may be passed a block that will be called back when the session
 state changes. The block will be released when the session is closed.

 @param behavior Controls whether to allow, force, or prohibit Facebook Login or Inline Facebook Login. The default
 is to allow Facebook Login, with fallback to Inline Facebook Login.
 @param handler A block to call with session state changes. The default is nil.
 */
- (void)openWithBehavior:(PF_FBSessionLoginBehavior)behavior
       completionHandler:(PF_FBSessionStateHandler)handler;

/*!
 @abstract
 Closes the local in-memory session object, but does not clear the persisted token cache.
 */
- (void)close;

/*!
 @abstract
 Closes the in-memory session, and clears any persisted cache related to the session.
*/
- (void)closeAndClearTokenInformation;

/*!
 @abstract
 Reauthorizes the session, with additional permissions.

 @param permissions An array of strings representing the permissions to request during the
 authentication flow. A value of nil indicates basic permissions. The default is nil.
 @param behavior Controls whether to allow, force, or prohibit Facebook Login. The default
 is to allow Facebook Login and fall back to Inline Facebook Login if needed.
 @param handler A block to call with session state changes. The default is nil.

 @discussion Methods and properties that specify permissions without a read or publish
 qualification are deprecated; use of a read-qualified or publish-qualified alternative is preferred
 (e.g. reauthorizeWithReadPermissions or reauthorizeWithPublishPermissions)
 */
- (void)reauthorizeWithPermissions:(NSArray*)permissions
                          behavior:(PF_FBSessionLoginBehavior)behavior
                 completionHandler:(PF_FBSessionReauthorizeResultHandler)handler
__attribute__((deprecated));

/*!
 @abstract
 Reauthorizes the session, with additional permissions.

 @param readPermissions An array of strings representing the permissions to request during the
 authentication flow. A value of nil indicates basic permissions.

 @param handler A block to call with session state changes. The default is nil.
 */
- (void)reauthorizeWithReadPermissions:(NSArray*)readPermissions
                     completionHandler:(PF_FBSessionReauthorizeResultHandler)handler;

/*!
 @abstract
 Reauthorizes the session, with additional permissions.

 @param writePermissions An array of strings representing the permissions to request during the
 authentication flow.

 @param defaultAudience Specifies the audience for posts.

 @param handler A block to call with session state changes. The default is nil.
 */
- (void)reauthorizeWithPublishPermissions:(NSArray*)writePermissions
                          defaultAudience:(PF_FBSessionDefaultAudience)defaultAudience
                        completionHandler:(PF_FBSessionReauthorizeResultHandler)handler;

/*!
 @abstract
 A helper method that is used to provide an implementation for
 [UIApplicationDelegate application:openURL:sourceApplication:annotation:]. It should be invoked during
 the Facebook Login flow and will update the session information based on the incoming URL.

 @param url The URL as passed to [UIApplicationDelegate application:openURL:sourceApplication:annotation:].
*/
- (BOOL)handleOpenURL:(NSURL*)url;

/*!
 @abstract
 A helper method that is used to provide an implementation for
 [UIApplicationDelegate applicationDidBecomeActive:] to properly resolve session state for
 the Facebook Login flow, specifically to support app-switch login.
 */
- (void)handleDidBecomeActive;

/*!
 @methodgroup Class methods
 */

/*!
 @abstract
 This is the simplest method for opening a session with Facebook. Using sessionOpen logs on a user,
 and sets the static activeSession which becomes the default session object for any Facebook UI widgets
 used by the application. This session becomes the active session, whether open succeeds or fails.

 Note, if there is not a cached token available, this method will present UI to the user in order to
 open the session via explicit login by the user.

 @param allowLoginUI    Sometimes it is useful to attempt to open a session, but only if
 no login UI will be required to accomplish the operation. For example, at application startup it may not
 be disirable to transition to login UI for the user, and yet an open session is desired so long as a cached
 token can be used to open the session. Passing NO to this argument, assures the method will not present UI
 to the user in order to open the session.

 @discussion
 Returns YES if the session was opened synchronously without presenting UI to the user. This occurs
 when there is a cached token available from a previous run of the application. If NO is returned, this indicates
 that the session was not immediately opened, via cache. However, if YES was passed as allowLoginUI, then it is
 possible that the user will login, and the session will become open asynchronously. The primary use for
 this return value is to switch-on facebook capabilities in your UX upon startup, in the case were the session
 is opened via cache.
 */
+ (BOOL)openActiveSessionWithAllowLoginUI:(BOOL)allowLoginUI;

/*!
 @abstract
 This is a simple method for opening a session with Facebook. Using sessionOpen logs on a user,
 and sets the static activeSession which becomes the default session object for any Facebook UI widgets
 used by the application. This session becomes the active session, whether open succeeds or fails.

 @param permissions     An array of strings representing the permissions to request during the
 authentication flow. A value of nil indicates basic permissions. A nil value specifies
 default permissions.

 @param allowLoginUI    Sometimes it is useful to attempt to open a session, but only if
 no login UI will be required to accomplish the operation. For example, at application startup it may not
 be desirable to transition to login UI for the user, and yet an open session is desired so long as a cached
 token can be used to open the session. Passing NO to this argument, assures the method will not present UI
 to the user in order to open the session.

 @param handler                 Many applications will benefit from notification when a session becomes invalid
 or undergoes other state transitions. If a block is provided, the PF_FBSession
 object will call the block each time the session changes state.

 @discussion
 Returns true if the session was opened synchronously without presenting UI to the user. This occurs
 when there is a cached token available from a previous run of the application. If NO is returned, this indicates
 that the session was not immediately opened, via cache. However, if YES was passed as allowLoginUI, then it is
 possible that the user will login, and the session will become open asynchronously. The primary use for
 this return value is to switch-on facebook capabilities in your UX upon startup, in the case were the session
 is opened via cache.

 It is required that initial permissions requests represent read-only permissions only. If publish
 permissions are needed, you may use reauthorizeWithPermissions to specify additional permissions as
 well as an audience. Use of this method will result in a legacy fast-app-switch Facebook Login due to
 the requirement to seperate read and publish permissions for newer applications. Methods and properties
 that specify permissions without a read or publish qualification are deprecated; use of a read-qualified
 or publish-qualified alternative is preferred.
 */
+ (BOOL)openActiveSessionWithPermissions:(NSArray*)permissions
                            allowLoginUI:(BOOL)allowLoginUI
                       completionHandler:(PF_FBSessionStateHandler)handler
__attribute__((deprecated));

/*!
 @abstract
 This is a simple method for opening a session with Facebook. Using sessionOpen logs on a user,
 and sets the static activeSession which becomes the default session object for any Facebook UI widgets
 used by the application. This session becomes the active session, whether open succeeds or fails.

 @param readPermissions     An array of strings representing the read permissions to request during the
 authentication flow. A value of nil indicates basic permissions. It is not allowed to pass publish
 permissions to this method.

 @param allowLoginUI    Sometimes it is useful to attempt to open a session, but only if
 no login UI will be required to accomplish the operation. For example, at application startup it may not
 be desirable to transition to login UI for the user, and yet an open session is desired so long as a cached
 token can be used to open the session. Passing NO to this argument, assures the method will not present UI
 to the user in order to open the session.

 @param handler                 Many applications will benefit from notification when a session becomes invalid
 or undergoes other state transitions. If a block is provided, the FBSession
 object will call the block each time the session changes state.

 @discussion
 Returns true if the session was opened synchronously without presenting UI to the user. This occurs
 when there is a cached token available from a previous run of the application. If NO is returned, this indicates
 that the session was not immediately opened, via cache. However, if YES was passed as allowLoginUI, then it is
 possible that the user will login, and the session will become open asynchronously. The primary use for
 this return value is to switch-on facebook capabilities in your UX upon startup, in the case were the session
 is opened via cache.

 */
+ (BOOL)openActiveSessionWithReadPermissions:(NSArray*)permissions
                                allowLoginUI:(BOOL)allowLoginUI
                           completionHandler:(PF_FBSessionStateHandler)handler;

/*!
 @abstract
 This is a simple method for opening a session with Facebook. Using sessionOpen logs on a user,
 and sets the static activeSession which becomes the default session object for any Facebook UI widgets
 used by the application. This session becomes the active session, whether open succeeds or fails.

 @param publishPermissions     An array of strings representing the publish permissions to request during the
 authentication flow.

 @param defaultAudience     Anytime an app publishes on behalf of a user, the post must have an audience (e.g. me, my friends, etc.)
 The default audience is used to notify the user of the cieling that the user agrees to grant to the app for the provided permissions.

 @param allowLoginUI    Sometimes it is useful to attempt to open a session, but only if
 no login UI will be required to accomplish the operation. For example, at application startup it may not
 be desirable to transition to login UI for the user, and yet an open session is desired so long as a cached
 token can be used to open the session. Passing NO to this argument, assures the method will not present UI
 to the user in order to open the session.

 @param handler                 Many applications will benefit from notification when a session becomes invalid
 or undergoes other state transitions. If a block is provided, the FBSession
 object will call the block each time the session changes state.

 @discussion
 Returns true if the session was opened synchronously without presenting UI to the user. This occurs
 when there is a cached token available from a previous run of the application. If NO is returned, this indicates
 that the session was not immediately opened, via cache. However, if YES was passed as allowLoginUI, then it is
 possible that the user will login, and the session will become open asynchronously. The primary use for
 this return value is to switch-on facebook capabilities in your UX upon startup, in the case were the session
 is opened via cache.

 */
+ (BOOL)openActiveSessionWithPublishPermissions:(NSArray*)publishPermissions
                                defaultAudience:(PF_FBSessionDefaultAudience)defaultAudience
                                   allowLoginUI:(BOOL)allowLoginUI
                              completionHandler:(PF_FBSessionStateHandler)handler;

/*!
 @abstract
 An appication may get or set the current active session. Certain high-level components in the SDK
 will use the activeSession to set default session (e.g. `PF_FBLoginView`, `PF_FBFriendPickerViewController`)

 @discussion
 If sessionOpen* is called, the resulting `PF_FBSession` object also becomes the activeSession. If another
 session was active at the time, it is closed automatically. If activeSession is called when no session
 is active, a session object is instatiated and returned; in this case open must be called on the session
 in order for it to be useable for communication with Facebook.
 */
+ (PF_FBSession*)activeSession;

/*!
 @abstract
 An appication may get or set the current active session. Certain high-level components in the SDK
 will use the activeSession to set default session (e.g. `PF_FBLoginView`, `PF_FBFriendPickerViewController`)

 @param session         The PF_FBSession object to become the active session

 @discussion
 If an application prefers the flexibilility of directly instantiating a session object, an active
 session can be set directly.
 */
+ (PF_FBSession*)setActiveSession:(PF_FBSession*)session;

/*!
 @method

 @abstract Set the default Facebook App ID to use for sessions. The app ID may be
 overridden on a per session basis.

 @param appID The default Facebook App ID to use for <PF_FBSession> methods.
 */
+ (void)setDefaultAppID:(NSString*)appID;

/*!
 @method

 @abstract Get the default Facebook App ID to use for sessions. If not explicitly
 set, the default will be read from the application's plist. The app ID may be
 overridden on a per session basis.
 */
+ (NSString*)defaultAppID;

@end
