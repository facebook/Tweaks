/**
 Copyright (c) 2014-present, Facebook, Inc.
 All rights reserved.
 
 This source code is licensed under the BSD-style license found in the
 LICENSE file in the root directory of this source tree. An additional grant
 of patent rights can be found in the PATENTS file in the same directory.
 */

#import "FBTweakStore.h"
#import "FBTweakShakeWindow.h"
#import "FBTweakViewController.h"

// Minimum shake time required to present tweaks on device.
static CFTimeInterval _FBTweakShakeWindowMinTimeInterval = 0.4;

@implementation FBTweakShakeWindow {
  BOOL _shaking;
}

- (void)_presentTweaks
{
  UIViewController *visibleViewController = self.rootViewController;
  
  while (visibleViewController.presentedViewController) {
    visibleViewController = visibleViewController.presentedViewController;
  }
  
  // Prevent double-presenting the tweaks view controller.
  if (![visibleViewController isKindOfClass:[FBTweakViewController class]]) {
    FBTweakStore *store = [FBTweakStore sharedInstance];
    FBTweakViewController *viewController = [[FBTweakViewController alloc] initWithStore:store];
    [visibleViewController presentViewController:viewController animated:YES completion:NULL];
  }
}

- (BOOL)_shouldPresentTweaks
{
#if TARGET_IPHONE_SIMULATOR
  return YES;
#else
  return _shaking && [[UIApplication sharedApplication] applicationState] == UIApplicationStateActive;
#endif
}

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
  if (motion == UIEventSubtypeMotionShake) {
    _shaking = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, _FBTweakShakeWindowMinTimeInterval * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
      if ([self _shouldPresentTweaks]) {
        [self _presentTweaks];
      }
    });
  }
  [super motionBegan:motion withEvent:event];
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
  if (motion == UIEventSubtypeMotionShake) {
    _shaking = NO;
  }
  [super motionEnded:motion withEvent:event];
}

@end
