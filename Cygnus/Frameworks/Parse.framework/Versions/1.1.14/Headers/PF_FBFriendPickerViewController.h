/*
 * Copyright 2012 Facebook
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0

 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import <UIKit/UIKit.h>
#import "PF_FBGraphUser.h"
#import "PF_FBSession.h"
#import "PF_FBCacheDescriptor.h"
#import "PF_FBViewController.h"

@protocol PF_FBFriendPickerDelegate;
@class PF_FBFriendPickerCacheDescriptor;

/*!
 @typedef PF_FBFriendSortOrdering enum

 @abstract Indicates the order in which friends should be listed in the friend picker.

 @discussion
 */
typedef enum {
    /*! Sort friends by first, middle, last names. */
    PF_FBFriendSortByFirstName,
    /*! Sort friends by last, first, middle names. */
    PF_FBFriendSortByLastName
} PF_FBFriendSortOrdering;

/*!
 @typedef PF_FBFriendDisplayOrdering enum

 @abstract Indicates whether friends should be displayed first-name-first or last-name-first.

 @discussion
 */
typedef enum {
    /*! Display friends as First Middle Last. */
    PF_FBFriendDisplayByFirstName,
    /*! Display friends as Last First Middle. */
    PF_FBFriendDisplayByLastName,
} PF_FBFriendDisplayOrdering;


/*!
 @class

 @abstract
 The `PF_FBFriendPickerViewController` class creates a controller object that manages
 the user interface for displaying and selecting Facebook friends.

 @discussion
 When the `PF_FBFriendPickerViewController` view loads it creates a `UITableView` object
 where the friends will be displayed. You can access this view through the `tableView`
 property. The friend display can be sorted by first name or last name. Friends'
 names can be displayed with the first name first or the last name first.

 The friend data can be pre-fetched and cached prior to using the view controller. The
 cache is setup using an <PF_FBCacheDescriptor> object that can trigger the
 data fetch. Any friend data requests will first check the cache and use that data.
 If the friend picker is being displayed cached data will initially be shown before
 a fresh copy is retrieved.

 The `delegate` property may be set to an object that conforms to the <PF_FBFriendPickerDelegate>
 protocol. The `delegate` object will receive updates related to friend selection and
 data changes. The delegate can also be used to filter the friends to display in the
 picker.
 */
@interface PF_FBFriendPickerViewController : PF_FBViewController

/*!
 @abstract
 Returns an outlet for the spinner used in the view controller.
 */
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *spinner;

/*!
 @abstract
 Returns an outlet for the table view managed by the view controller.
 */
@property (nonatomic, retain) IBOutlet UITableView *tableView;

/*!
 @abstract
 A Boolean value that specifies whether multi-select is enabled.
 */
@property (nonatomic) BOOL allowsMultipleSelection;

/*!
 @abstract
 A Boolean value that indicates whether friend profile pictures are displayed.
 */
@property (nonatomic) BOOL itemPicturesEnabled;

/*!
 @abstract
 Addtional fields to fetch when making the Graph API call to get friend data.
 */
@property (nonatomic, copy) NSSet *fieldsForRequest;

/*!
 @abstract
 The session that is used in the request for friend data.
 */
@property (nonatomic, retain) PF_FBSession *session;

/*!
 @abstract
 The profile ID of the user whose friends are being viewed.
 */
@property (nonatomic, copy) NSString *userID;

/*!
 @abstract
 The list of friends that are currently selected in the veiw.
 The items in the array are <PF_FBGraphUser> objects.
 */
@property (nonatomic, retain, readonly) NSArray *selection;

/*!
 @abstract
 The order in which friends are sorted in the display.
 */
@property (nonatomic) PF_FBFriendSortOrdering sortOrdering;

/*!
 @abstract
 The order in which friends' names are displayed.
 */
@property (nonatomic) PF_FBFriendDisplayOrdering displayOrdering;

/*!
 @abstract
 Initializes a friend picker view controller.
 */
- (id)init;

/*!
 @abstract
 Initializes a friend picker view controller.

 @param aDecoder        An unarchiver object.
 */
- (id)initWithCoder:(NSCoder *)aDecoder;

/*!
 @abstract
 Used to initialize the object

 @param nibNameOrNil            The name of the nib file to associate with the view controller. The nib file name should not contain any leading path information. If you specify nil, the nibName property is set to nil.
 @param nibBundleOrNil          The bundle in which to search for the nib file. This method looks for the nib file in the bundle's language-specific project directories first, followed by the Resources directory. If nil, this method looks for the nib file in the main bundle.
 */
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;

/*!
 @abstract
 Configures the properties used in the caching data queries.

 @discussion
 Cache descriptors are used to fetch and cache the data used by the view controller.
 If the view controller finds a cached copy of the data, it will
 first display the cached content then fetch a fresh copy from the server.

 @param cacheDescriptor     The <PF_FBCacheDescriptor> containing the cache query properties.
 */
- (void)configureUsingCachedDescriptor:(PF_FBCacheDescriptor*)cacheDescriptor;

/*!
 @abstract
 Initiates a query to get friend data.

 @discussion
 A cached copy will be returned if available. The cached view is temporary until a fresh copy is
 retrieved from the server. It is legal to call this more than once.
 */
- (void)loadData;

/*!
 @abstract
 Updates the view locally without fetching data from the server or from cache.

 @discussion
 Use this if the filter or sort properties change. This may affect the order or
 display of friend information but should not need require new data.
 */
- (void)updateView;

/*!
 @abstract
 Clears the current selection, so the picker is ready for a fresh use.
 */
- (void)clearSelection;

/*!
 @method

 @abstract
 Creates a cache descriptor based on default settings of the `PF_FBFriendPickerViewController` object.

 @discussion
 An `PF_FBCacheDescriptor` object may be used to pre-fetch data before it is used by
 the view controller. It may also be used to configure the `PF_FBFriendPickerViewController`
 object.
 */
+ (PF_FBCacheDescriptor*)cacheDescriptor;

/*!
 @method

 @abstract
 Creates a cache descriptor with additional fields and a profile ID for use with the `PF_FBFriendPickerViewController` object.

 @discussion
 An `PF_FBCacheDescriptor` object may be used to pre-fetch data before it is used by
 the view controller. It may also be used to configure the `PF_FBFriendPickerViewController`
 object.

 @param userID              The profile ID of the user whose friends will be displayed. A nil value implies a "me" alias.
 @param fieldsForRequest    The set of additional fields to include in the request for friend data.
 */
+ (PF_FBCacheDescriptor*)cacheDescriptorWithUserID:(NSString*)userID fieldsForRequest:(NSSet*)fieldsForRequest;

@end

/*!
 @protocol

 @abstract
 The `PF_FBFriendPickerDelegate` protocol defines the methods used to receive event
 notifications and allow for deeper control of the <PF_FBFriendPickerViewController>
 view.
 */
@protocol PF_FBFriendPickerDelegate <PF_FBViewControllerDelegate>
@optional

/*!
 @abstract
 Tells the delegate that data has been loaded.

 @discussion
 The <PF_FBFriendPickerViewController> object's `tableView` property is automatically
 reloaded when this happens. However, if another table view, for example the
 `UISearchBar` is showing data, then it may also need to be reloaded.

 @param friendPicker        The friend picker view controller whose data changed.
 */
- (void)friendPickerViewControllerDataDidChange:(PF_FBFriendPickerViewController *)friendPicker;

/*!
 @abstract
 Tells the delegate that the selection has changed.

 @param friendPicker        The friend picker view controller whose selection changed.
 */
- (void)friendPickerViewControllerSelectionDidChange:(PF_FBFriendPickerViewController *)friendPicker;

/*!
 @abstract
 Asks the delegate whether to include a friend in the list.

 @discussion
 This can be used to implement a search bar that filters the friend list.

 @param friendPicker        The friend picker view controller that is requesting this information.
 @param user                An <PF_FBGraphUser> object representing the friend.
 */
- (BOOL)friendPickerViewController:(PF_FBFriendPickerViewController *)friendPicker
                 shouldIncludeUser:(id <PF_FBGraphUser>)user;

/*!
 @abstract
 Tells the delegate that there is a communication error.

 @param friendPicker        The friend picker view controller that encountered the error.
 @param error               An error object containing details of the error.
 */
- (void)friendPickerViewController:(PF_FBFriendPickerViewController *)friendPicker
                       handleError:(NSError *)error;

@end
