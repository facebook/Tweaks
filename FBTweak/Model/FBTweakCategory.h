/**
 Copyright (c) 2014-present, Facebook, Inc.
 All rights reserved.
 
 This source code is licensed under the BSD-style license found in the
 LICENSE file in the root directory of this source tree. An additional grant
 of patent rights can be found in the PATENTS file in the same directory.
 */

#import <Foundation/Foundation.h>

@class FBTweakCollection;

/**
  @abstract A named grouping of collections.
 */
@interface FBTweakCategory : NSObject <NSCoding>

/**
  @abstract Creates a tweak category.
  @discussion This is the designated initializer.
 */
- (instancetype)initWithName:(NSString *)name;

/**
  @abstract The name of the category.
 */
@property (nonatomic, copy, readonly) NSString *name;

/**
  @abstract The collections contained in this category.
 */
@property (nonatomic, copy, readonly) NSArray *tweakCollections;

/**
  @abstract Fetches a collection by name.
  @param name The collection name to find.
 */
- (FBTweakCollection *)tweakCollectionWithName:(NSString *)name;

/**
 @abstract Adds a tweak collection to the category.
 @param tweakCollection The tweak collection to add.
 */
- (void)addTweakCollection:(FBTweakCollection *)tweakCollection;

/**
 @abstract Removes a tweak collection from the category.
 @param tweakCollection The tweak collection to remove.
 */
- (void)removeTweakCollection:(FBTweakCollection *)tweakCollection;

@end
