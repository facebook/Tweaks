/**
 Copyright (c) 2014-present, Facebook, Inc.
 All rights reserved.
 
 This source code is licensed under the BSD-style license found in the
 LICENSE file in the root directory of this source tree. An additional grant
 of patent rights can be found in the PATENTS file in the same directory.
 */

#import <UIKit/UIKit.h>

@class FBTweakStore;
@class FBTweakCategory;
@protocol _FBTweakCategoryViewControllerDelegate;

/**
  @abstract Displays a list of items and allows selection.
 */
@interface _FBTweakCategoryViewController : UIViewController

/**
  @abstract Creates a tweak category view controller.
  @param store The store with the categories to show.
  @discussion This is the designated initializer.
 */
- (instancetype)initWithStore:(FBTweakStore *)store;

/**
  @abstract The tweak store shown.
 */
@property (nonatomic, strong, readonly) FBTweakStore *store;

/**
  @abstract Responds to actions from the items list.
 */
@property (nonatomic, weak, readwrite) id<_FBTweakCategoryViewControllerDelegate> delegate;

@end

@protocol _FBTweakCategoryViewControllerDelegate <NSObject>

/**
  @abstract Called when a category is selected.
  @param viewController The view controller with the selected category.
  @param category The category that was selected.
 */
- (void)tweakCategoryViewController:(_FBTweakCategoryViewController *)viewController selectedCategory:(FBTweakCategory *)category;

/**
  @abstract Called when done is selected.
  @param viewController The view controller that selected done.
 */
- (void)tweakCategoryViewControllerSelectedDone:(_FBTweakCategoryViewController *)viewController;


@end
