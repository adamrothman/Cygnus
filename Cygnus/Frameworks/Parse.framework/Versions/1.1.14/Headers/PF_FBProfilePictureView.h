/*
 * Copyright 2010 Facebook
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

/*!
 @typedef PF_FBProfilePictureCropping enum

 @abstract
 Type used to specify the cropping treatment of the profile picture.

 @discussion
 */
typedef enum {

    /*! Square (default) - the square version that the Facebook user defined. */
    PF_FBProfilePictureCroppingSquare      = 0,

    /*! Original - the original profile picture, as uploaded. */
    PF_FBProfilePictureCroppingOriginal    = 1

} PF_FBProfilePictureCropping;

/*!
 @class
 @abstract
 An instance of `PF_FBProfilePictureView` is used to display a profile picture.

 The default behavior of this control is to center the profile picture
 in the view and shrinks it, if necessary, to the view's bounds, preserving the aspect ratio. The smallest
 possible image is downloaded to ensure that scaling up never happens.  Resizing the view may result in
 a different size of the image being loaded.  Canonical image sizes are documented in the "Pictures" section
 of https://developers.facebook.com/docs/reference/api.
 */
@interface PF_FBProfilePictureView : UIView

/*!
 @abstract
 The Facebook ID of the user, place or object for which a picture should be fetched and displayed.
 */
@property (copy, nonatomic) NSString* profileID;

/*!
 @abstract
 The cropping to use for the profile picture.
 */
@property (nonatomic) PF_FBProfilePictureCropping pictureCropping;

/*!
 @abstract
 Initializes and returns a profile view object.
 */
- (id)init;


/*!
 @abstract
 Initializes and returns a profile view object for the given Facebook ID and cropping.

 @param profileID       The Facebook ID of the user, place or object for which a picture should be fetched and displayed.
 @param pictureCropping The cropping to use for the profile picture.
 */
- (id)initWithProfileID:(NSString*)profileID
     pictureCropping:(PF_FBProfilePictureCropping)pictureCropping;


@end
