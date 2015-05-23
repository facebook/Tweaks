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
  @abstract A table cell to edit a tweak.
 */
@interface _FBTweakTableViewCell : UITableViewCell

/**
  @abstract Create a tweak table cell.
  @param reuseIdentifier The cell's reuse identifier.
  @discussion This is the designated initializer.
 */
- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier;

//! @abstract The tweak to show in the cell.
@property (nonatomic, strong, readwrite) FBTweak *tweak;

@end
