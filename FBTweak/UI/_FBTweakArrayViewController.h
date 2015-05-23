/**
 Copyright (c) 2014-present, Facebook, Inc.
 All rights reserved.
 
 This source code is licensed under the BSD-style license found in the
 LICENSE file in the root directory of this source tree. An additional grant
 of patent rights can be found in the PATENTS file in the same directory.
 */

#import <UIKit/UIKit.h>

@class FBTweak;

/**
  @abstract Displays list of values in an array tweak.
 */
@interface _FBTweakArrayViewController : UIViewController

/**
  @abstract Creates a tweak array view controller.
  @discussion This is the designated initializer.
  @param tweak The tweak the view controller is for.
    Must not be nil, and must have an array of possibleValues.
 */
- (instancetype)initWithTweak:(FBTweak *)tweak;

/**
  @abstract The array tweak to display in the view controller.
 */
@property (nonatomic, strong, readonly) FBTweak *tweak;

@end
