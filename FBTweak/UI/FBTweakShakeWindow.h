/**
 Copyright (c) 2014-present, Facebook, Inc.
 All rights reserved.
 
 This source code is licensed under the BSD-style license found in the
 LICENSE file in the root directory of this source tree. An additional grant
 of patent rights can be found in the PATENTS file in the same directory.
 */

#import <UIKit/UIKit.h>

#import "FBTweakViewController.h"

/**
  @abstract A UIWindow that automatically presents tweaks when the user shakes the device.
  @discussion Use this window as your app's root window to enable shaking to open tweaks.
 */
@interface FBTweakShakeWindow : UIWindow <FBTweakViewControllerDelegate>

@end
