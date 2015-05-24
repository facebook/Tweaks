/**
 Copyright (c) 2014-present, Facebook, Inc.
 All rights reserved.
 
 This source code is licensed under the BSD-style license found in the
 LICENSE file in the root directory of this source tree. An additional grant
 of patent rights can be found in the PATENTS file in the same directory.
 */

#import <Foundation/Foundation.h>

@class FBTweakCategory;

/**
  @abstract The global store for tweaks.
 */
@interface FBTweakStore : NSObject <NSCoding>

/**
  @abstract Creates or returns the shared global store.
 */
+ (instancetype)sharedInstance;

/**
  @abstract The tweak categories in the store.
 */
@property (nonatomic, copy, readonly) NSArray *tweakCategories;

/** 
  @abstract Finds a tweak category by name.
  @param name The name of the category to find.
  @return The category if found, nil otherwise.
 */
- (FBTweakCategory *)tweakCategoryWithName:(NSString *)name;

/**
  @abstract Registers a tweak category with the store.
  @param category The tweak category to register.
 */
- (void)addTweakCategory:(FBTweakCategory *)category;

/**
  @abstract Removes a tweak category from the store.
  @param category The tweak category to remove.
 */
- (void)removeTweakCategory:(FBTweakCategory *)category;

/**
  @abstract Resets all tweaks in the store.
 */
- (void)reset;

@end
