/**
 Copyright (c) 2014-present, Facebook, Inc.
 All rights reserved.
 
 This source code is licensed under the BSD-style license found in the
 LICENSE file in the root directory of this source tree. An additional grant
 of patent rights can be found in the PATENTS file in the same directory.
 */

#import <Foundation/Foundation.h>

@class FBTweak;

/**
  @abstract A named collection of tweaks.
 */
@interface FBTweakCollection : NSObject <NSCoding>

/**
  @abstract Creates a tweak collection.
  @discussion This is the designated initializer.
 */
- (instancetype)initWithName:(NSString *)name;

/**
  @abstract The name of the collection.
 */
@property (nonatomic, copy, readonly) NSString *name;

/**
  @abstract The tweaks contained in this collection.
 */
@property (nonatomic, copy, readonly) NSArray *tweaks;

/**
  @abstract Fetches a tweak by identifier.
  @param identifier The tweak identifier to find.
  @discussion Only search tweaks in this collection.
 */
- (FBTweak *)tweakWithIdentifier:(NSString *)identifier;

/**
  @abstract Adds a tweak to the collection.
  @param tweak The tweak to add.
 */
- (void)addTweak:(FBTweak *)tweak;

/**
  @abstract Removes a tweak from the collection.
  @param tweak The tweak to remove.
 */
- (void)removeTweak:(FBTweak *)tweak;

@end
