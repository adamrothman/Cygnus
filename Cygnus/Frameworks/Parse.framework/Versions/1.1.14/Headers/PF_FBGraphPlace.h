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

#import <Foundation/Foundation.h>
#import "PF_FBGraphLocation.h"
#import "PF_FBGraphObject.h"

/*!
 @protocol

 @abstract
 The `PF_FBGraphPlace` protocol enables typed access to a place object
 as represented in the Graph API.


 @discussion
 The `PF_FBGraphPlace` protocol represents the most commonly used properties of a
 Facebook place object. It may be used to access an `NSDictionary` object that has
 been wrapped with an <PF_FBGraphObject> facade.
 */
@protocol PF_FBGraphPlace<PF_FBGraphObject>

/*!
 @property
 @abstract Typed access to the place ID.
 */
@property (retain, nonatomic) NSString *id;

/*!
 @property
 @abstract Typed access to the place name.
 */
@property (retain, nonatomic) NSString *name;

/*!
 @property
 @abstract Typed access to the place category.
 */
@property (retain, nonatomic) NSString *category;

/*!
 @property
 @abstract Typed access to the place location.
 */
@property (retain, nonatomic) id<PF_FBGraphLocation> location;

@end
