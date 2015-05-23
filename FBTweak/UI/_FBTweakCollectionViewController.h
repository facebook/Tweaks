/**
 Copyright (c) 2014-present, Facebook, Inc.
 All rights reserved.
 
 This source code is licensed under the BSD-style license found in the
 LICENSE file in the root directory of this source tree. An additional grant
 of patent rights can be found in the PATENTS file in the same directory.
 */

#import <UIKit/UIKit.h>

@class FBTweakCategory;
@protocol _FBTweakCollectionViewControllerDelegate;

/**
  @abstract Displays configuration options for tweak collections.
 */
@interface _FBTweakCollectionViewController : UIViewController

/**
  @abstract Create a tweak collection view controller.
  @param category The tweak category to show the collections in.
  @discussion This is the designated initializer.
 */
- (instancetype)initWithTweakCategory:(FBTweakCategory *)category;

//! @abstract The tweak category to show the collections in.
@property (nonatomic, strong, readonly) FBTweakCategory *tweakCategory;

/**
  @abstract Responds to actions from the items list.
 */
@property (nonatomic, weak, readwrite) id<_FBTweakCollectionViewControllerDelegate> delegate;

@end

@protocol _FBTweakCollectionViewControllerDelegate <NSObject>

/**
  @abstract Called when done is selected.
  @param viewController The view controller that selected done.
 */
- (void)tweakCollectionViewControllerSelectedDone:(_FBTweakCollectionViewController *)viewController;

@end