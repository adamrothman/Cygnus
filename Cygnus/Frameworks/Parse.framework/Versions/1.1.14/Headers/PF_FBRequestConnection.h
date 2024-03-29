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
#import <CoreLocation/CoreLocation.h>
#import "PF_FBGraphObject.h"

// up-front decl's
@class PF_FBRequest;
@class PF_FBRequestConnection;
@class UIImage;

/*!
 Normally requests return JSON data that is parsed into a set of `NSDictionary`
 and `NSArray` objects.

 When a request returns a non-JSON response, that response is packaged in
 a `NSDictionary` using PF_FBNonJSONResponseProperty as the key and the literal
 response as the value.
*/
extern NSString *const PF_FBNonJSONResponseProperty;

/*!
 @typedef PF_FBRequestHandler

 @abstract
 A block that is passed to addRequest to register for a callback with the results of that
 request once the connection completes.

 @discussion
 Pass a block of this type when calling addRequest.  This will be called once
 the request completes.  The call occurs on the UI thread.

 @param connection      The `PF_FBRequestConnection` that sent the request.

 @param result          The result of the request.  This is a translation of
                        JSON data to `NSDictionary` and `NSArray` objects.  This
                        is nil if there was an error.

 @param error           The `NSError` representing any error that occurred.

*/
typedef void (^PF_FBRequestHandler)(PF_FBRequestConnection *connection,
                                 id result,
                                 NSError *error);

/*!
 @class PF_FBRequestConnection

 @abstract
 The `PF_FBRequestConnection` represents a single connection to Facebook to service a request.

 @discussion
 The request settings are encapsulated in a reusable <PF_FBRequest> object. The
 `PF_FBRequestConnection` object encapsulates the concerns of a single communication
 e.g. starting a connection, canceling a connection, or batching requests.

*/
@interface PF_FBRequestConnection : NSObject

/*!
 @methodgroup Creating a request
*/

/*!
 @method

 Calls <initWithTimeout:> with a default timeout of 180 seconds.
*/
- (id)init;

/*!
 @method

 @abstract
 `PF_FBRequestConnection` objects are used to issue one or more requests as a single
 request/response connection with Facebook.

 @discussion
 For a single request, the usual method for creating an `PF_FBRequestConnection`
 object is to call one of the **start* ** methods on <PF_FBRequest>. However, it is
 allowable to init an `PF_FBRequestConnection` object directly, and call
 <addRequest:completionHandler:> to add one or more request objects to the
 connection, before calling start.

 Note that if requests are part of a batch, they must have an open
 PF_FBSession that has an access token associated with it. Alternatively a default App ID
 must be set either in the plist or through an explicit call to <[PF_FBSession defaultAppID]>.

 @param timeout         The `NSTimeInterval` (seconds) to wait for a response before giving up.
*/

- (id)initWithTimeout:(NSTimeInterval)timeout;

// properties

/*!
 @abstract
 The request that will be sent to the server.

 @discussion
 This property can be used to create a `NSURLRequest` without using
 `PF_FBRequestConnection` to send that request.  It is legal to set this property
 in which case the provided `NSMutableURLRequest` will be used instead.  However,
 the `NSMutableURLRequest` must result in an appropriate response.  Furthermore, once
 this property has been set, no more <PF_FBRequest> objects can be added to this
 `PF_FBRequestConnection`.
*/
@property(nonatomic, retain, readwrite) NSMutableURLRequest *urlRequest;

/*!
 @abstract
 The raw response that was returned from the server.  (readonly)

 @discussion
 This property can be used to inspect HTTP headers that were returned from
 the server.

 The property is nil until the request completes.  If there was a response
 then this property will be non-nil during the PF_FBRequestHandler callback.
*/
@property(nonatomic, retain, readonly) NSHTTPURLResponse *urlResponse;

/*!
 @methodgroup Adding requests
*/

/*!
 @method

 @abstract
 This method adds an <PF_FBRequest> object to this connection and then calls
 <start> on the connection.

 @discussion
 The completion handler is retained until the block is called upon the
 completion or cancellation of the connection.

 @param request       A request to be included in the round-trip when start is called.
 @param handler       A handler to call back when the round-trip completes or times out.
*/
- (void)addRequest:(PF_FBRequest*)request
 completionHandler:(PF_FBRequestHandler)handler;

/*!
 @method

 @abstract
 This method adds an <PF_FBRequest> object to this connection and then calls
 <start> on the connection.

 @discussion
 The completion handler is retained until the block is called upon the
 completion or cancellation of the connection. This request can be named
 to allow for using the request's response in a subsequent request.

 @param request         A request to be included in the round-trip when start is called.

 @param handler         A handler to call back when the round-trip completes or times out.

 @param name            An optional name for this request.  This can be used to feed
 the results of one request to the input of another <PF_FBRequest> in the same
 `PF_FBRequestConnection` as described in
 [Graph API Batch Requests]( https://developers.facebook.com/docs/reference/api/batch/ ).
*/
- (void)addRequest:(PF_FBRequest*)request
 completionHandler:(PF_FBRequestHandler)handler
    batchEntryName:(NSString*)name;

/*!
 @methodgroup Instance methods
*/

/*!
 @method

 @abstract
 This method starts a connection with the server and is capable of handling all of the
 requests that were added to the connection.

 @discussion
 Errors are reported via the handler callback, even in cases where no
 communication is attempted by the implementation of `PF_FBRequestConnection`. In
 such cases multiple error conditions may apply, and if so the following
 priority (highest to lowest) is used:

 - `PF_FBRequestConnectionInvalidRequestKey` -- this error is reported when an
 <PF_FBRequest> cannot be encoded for transmission.

 - `PF_FBRequestConnectionInvalidBatchKey`   -- this error is reported when any
 request in the connection cannot be encoded for transmission with the batch.
 In this scenario all requests fail.

 This method cannot be called twice for an `PF_FBRequestConnection` instance.
*/
- (void)start;

/*!
 @method

 @abstract
 Signals that a connection should be logically terminated as the
 application is no longer interested in a response.

 @discussion
 Synchronously calls any handlers indicating the request was cancelled. Cancel
 does not guarantee that the request-related processing will cease. It
 does promise that  all handlers will complete before the cancel returns. A call to
 cancel prior to a start implies a cancellation of all requests associated
 with the connection.
*/
- (void)cancel;

/*!
 @method

 @abstract
 Simple method to make a graph API request for user info (/me), creates an <PF_FBRequest>
 then uses an <PF_FBRequestConnection> object to start the connection with Facebook. The
 request uses the active session represented by `[PF_FBSession activeSession]`.

 See <connectionWithSession:graphPath:parameters:HTTPMethod:completionHandler:>

 @param handler          The handler block to call when the request completes with a success, error, or cancel action.
 */
+ (PF_FBRequestConnection*)startForMeWithCompletionHandler:(PF_FBRequestHandler)handler;

/*!
 @method

 @abstract
 Simple method to make a graph API request for user friends (/me/friends), creates an <PF_FBRequest>
 then uses an <PF_FBRequestConnection> object to start the connection with Facebook. The
 request uses the active session represented by `[PF_FBSession activeSession]`.

 See <connectionWithSession:graphPath:parameters:HTTPMethod:completionHandler:>

 @param handler          The handler block to call when the request completes with a success, error, or cancel action.
 */
+ (PF_FBRequestConnection*)startForMyFriendsWithCompletionHandler:(PF_FBRequestHandler)handler;

/*!
 @method

 @abstract
 Simple method to make a graph API post of a photo. The request
 uses the active session represented by `[PF_FBSession activeSession]`.

 @param photo            A `UIImage` for the photo to upload.
 @param handler          The handler block to call when the request completes with a success, error, or cancel action.
 */
+ (PF_FBRequestConnection*)startForUploadPhoto:(UIImage *)photo
                          completionHandler:(PF_FBRequestHandler)handler;

/*!
 @method

 @abstract
 Simple method to make a graph API post of a status update. The request
 uses the active session represented by `[PF_FBSession activeSession]`.

 @param message         The message to post.
 @param handler          The handler block to call when the request completes with a success, error, or cancel action.
 */
+ (PF_FBRequestConnection *)startForPostStatusUpdate:(NSString *)message
                                completionHandler:(PF_FBRequestHandler)handler;

/*!
 @method

 @abstract
 Simple method to make a graph API post of a status update. The request
 uses the active session represented by `[PF_FBSession activeSession]`.

 @param message         The message to post.
 @param place           The place to checkin with, or nil. Place may be an fbid or a
 graph object representing a place.
 @param tags            Array of friends to tag in the status update, each element
 may be an fbid or a graph object representing a user.
 @param handler          The handler block to call when the request completes with a success, error, or cancel action.
 */
+ (PF_FBRequestConnection *)startForPostStatusUpdate:(NSString *)message
                                            place:(id)place
                                             tags:(id<NSFastEnumeration>)tags
                                completionHandler:(PF_FBRequestHandler)handler;

/*!
 @method

 @abstract
 Starts a request representing a Graph API call to the "search" endpoint
 for a given location using the active session.

 @discussion
 Simplifies starting a request to search for places near a coordinate.

 This method creates the necessary <PF_FBRequest> object and initializes and
 starts an <PF_FBRequestConnection> object. A successful Graph API call will
 return an array of <PF_FBGraphPlace> objects representing the nearby locations.

 @param coordinate      The search coordinates.

 @param radius          The search radius in meters.

 @param limit           The maxiumum number of results to return.  It is
                        possible to receive fewer than this because of the
                        radius and because of server limits.

 @param searchText      The text to use in the query to narrow the set of places
                        returned.
 @param handler          The handler block to call when the request completes with a success, error, or cancel action.
 */
+ (PF_FBRequestConnection*)startForPlacesSearchAtCoordinate:(CLLocationCoordinate2D)coordinate
                                          radiusInMeters:(NSInteger)radius
                                            resultsLimit:(NSInteger)limit
                                              searchText:(NSString*)searchText
                                       completionHandler:(PF_FBRequestHandler)handler;

/*!
 @method

 @abstract
 Simple method to make a graph API request, creates an <PF_FBRequest> object for then
 uses an <PF_FBRequestConnection> object to start the connection with Facebook. The
 request uses the active session represented by `[PF_FBSession activeSession]`.

 See <connectionWithSession:graphPath:parameters:HTTPMethod:completionHandler:>

 @param graphPath        The Graph API endpoint to use for the request, for example "me".
 @param handler          The handler block to call when the request completes with a success, error, or cancel action.
 */
+ (PF_FBRequestConnection*)startWithGraphPath:(NSString*)graphPath
                         completionHandler:(PF_FBRequestHandler)handler;

/*!
 @method

 @abstract
 Simple method to make post an object using the graph API, creates an <PF_FBRequest> object for
 HTTP POST, then uses <PF_FBRequestConnection> to start a connection with Facebook. The request uses
 the active session represented by `[PF_FBSession activeSession]`.

 @param graphPath        The Graph API endpoint to use for the request, for example "me".

 @param graphObject      An object or open graph action to post.

 @param handler          The handler block to call when the request completes with a success, error, or cancel action.
 */
+ (PF_FBRequestConnection*)startForPostWithGraphPath:(NSString*)graphPath
                                      graphObject:(id<PF_FBGraphObject>)graphObject
                                completionHandler:(PF_FBRequestHandler)handler;

/*!
 @method

 @abstract
 Creates an `PF_FBRequest` object for a Graph API call, instantiate an
 <PF_FBRequestConnection> object, add the request to the newly created
 connection and finally start the connection. Use this method for
 specifying the request parameters and HTTP Method. The request uses
 the active session represented by `[PF_FBSession activeSession]`.

 @param graphPath        The Graph API endpoint to use for the request, for example "me".

 @param parameters       The parameters for the request. A value of nil sends only the automatically handled parameters, for example, the access token. The default is nil.

 @param HTTPMethod       The HTTP method to use for the request. A nil value implies a GET.

 @param handler          The handler block to call when the request completes with a success, error, or cancel action.
 */
+ (PF_FBRequestConnection*)startWithGraphPath:(NSString*)graphPath
                                parameters:(NSDictionary*)parameters
                                HTTPMethod:(NSString*)HTTPMethod
                         completionHandler:(PF_FBRequestHandler)handler;

@end
