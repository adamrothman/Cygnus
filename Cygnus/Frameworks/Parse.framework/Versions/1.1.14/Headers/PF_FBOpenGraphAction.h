/*
 * Copyright 2012 Facebook
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/xlicenses/LICENSE-2.0

 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import <Foundation/Foundation.h>
#import "PF_FBGraphObject.h"

@protocol PF_FBGraphPlace;
@protocol PF_FBGraphUser;

/*!
 @protocol

 @abstract
 The `PF_FBOpenGraphAction` protocol is the base protocol for use in posting and retrieving Open Graph actions.
 It inherits from the `PF_FBGraphObject` protocol; you may derive custome protocols from `PF_FBOpenGraphAction` in order
 implement typed access to your application's custom actions.

 @discussion
 Represents an Open Graph custom action, to be used directly, or from which to
 derive custom action protocols with custom properties.
 */
@protocol PF_FBOpenGraphAction<PF_FBGraphObject>

/*!
 @property
 @abstract Typed access to action's id
 */
@property (retain, nonatomic) NSString              *id;

/*!
 @property
 @abstract Typed access to action's start time
 */
@property (retain, nonatomic) NSString              *start_time;

/*!
 @property
 @abstract Typed access to action's end time
 */
@property (retain, nonatomic) NSString              *end_time;

/*!
 @property
 @abstract Typed access to action's publication time
 */
@property (retain, nonatomic) NSString              *publish_time;

/*!
 @property
 @abstract Typed access to action's creation time
 */
@property (retain, nonatomic) NSString              *created_time;

/*!
 @property
 @abstract Typed access to action's expiration time
 */
@property (retain, nonatomic) NSString              *expires_time;

/*!
 @property
 @abstract Typed access to action's ref
 */
@property (retain, nonatomic) NSString              *ref;

/*!
 @property
 @abstract Typed access to action's user message
 */
@property (retain, nonatomic) NSString              *message;

/*!
 @property
 @abstract Typed access to action's place
 */
@property (retain, nonatomic) id<PF_FBGraphPlace>      place;

/*!
 @property
 @abstract Typed access to action's tags
 */
@property (retain, nonatomic) NSArray               *tags;

/*!
 @property
 @abstract Typed access to action's images
 */
@property (retain, nonatomic) NSArray               *image;

/*!
 @property
 @abstract Typed access to action's from-user
 */
@property (retain, nonatomic) id<PF_FBGraphUser>       from;

/*!
 @property
 @abstract Typed access to action's likes
 */
@property (retain, nonatomic) NSArray               *likes;

/*!
 @property
 @abstract Typed access to action's application
 */
@property (retain, nonatomic) id<PF_FBGraphObject>     application;

/*!
 @property
 @abstract Typed access to action's comments
 */
@property (retain, nonatomic) NSArray               *comments;

@end
