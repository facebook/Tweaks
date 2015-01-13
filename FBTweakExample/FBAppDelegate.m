/**
 Copyright (c) 2014-present, Facebook, Inc.
 All rights reserved.
 
 This source code is licensed under the BSD-style license found in the
 LICENSE file in the root directory of this source tree. An additional grant
 of patent rights can be found in the PATENTS file in the same directory.
 */

#import <FBTweak/FBTweak.h>
#import <FBTweak/FBTweakShakeWindow.h>
#import <FBTweak/FBTweakInline.h>
#import <FBTweak/FBTweakViewController.h>

#import "FBAppDelegate.h"

@interface FBAppDelegate () <FBTweakObserver, FBTweakViewControllerDelegate>
@end

@implementation FBAppDelegate {
  UIWindow *_window;
  UIViewController *_rootViewController;
  
  UILabel *_label;
  FBTweak *_flipTweak;
}

FBTweakAction(@"Actions", @"Global", @"Hello", ^{
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hello" message:@"Global alert test." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Done", nil];
  [alert show];
});

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
  FBTweakAction(@"Actions", @"Scoped", @"One", ^{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hello" message:@"Scoped alert test #1." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Done", nil];
    [alert show];
  });

  _window = [[FBTweakShakeWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  _window.backgroundColor = [UIColor whiteColor];
  [_window makeKeyAndVisible];

  _rootViewController = [[UIViewController alloc] init];
  _rootViewController.view.backgroundColor = [UIColor colorWithRed:FBTweakValue(@"Window", @"Color", @"Red", 0.9, 0.0, 1.0)
                                                        green:FBTweakValue(@"Window", @"Color", @"Green", 0.9, 0.0, 1.0)
                                                         blue:FBTweakValue(@"Window", @"Color", @"Blue", 0.9, 0.0, 1.0)
                                                        alpha:1.0];
  _window.rootViewController = _rootViewController;
  
  _label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _window.bounds.size.width, _window.bounds.size.height * 0.75)];
  _label.textAlignment = NSTextAlignmentCenter;
  _label.numberOfLines = 0;
  _label.userInteractionEnabled = YES;
  _label.backgroundColor = [UIColor clearColor];
  _label.textColor = [UIColor blackColor];
  _label.font = [UIFont systemFontOfSize:FBTweakValue(@"Content", @"Text", @"Size", 60.0)];
  FBTweakBind(_label, text, @"Content", @"Text", @"String", @"Tweaks");
  FBTweakBind(_label, alpha, @"Content", @"Text", @"Alpha", 0.5, 0.0, 1.0);
  [_rootViewController.view addSubview:_label];
  
  UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelTapped)];
  [_label addGestureRecognizer:tapRecognizer];
  
  _flipTweak = FBTweakInline(@"Window", @"Effects", @"Upside Down", NO);
  [_flipTweak addObserver:self];

  CGRect tweaksButtonFrame = _window.bounds;
  tweaksButtonFrame.origin.y = _label.bounds.size.height;
  tweaksButtonFrame.size.height = tweaksButtonFrame.size.height - _label.bounds.size.height;
  UIButton *tweaksButton = [[UIButton alloc] initWithFrame:tweaksButtonFrame];
  [tweaksButton setTitle:@"Show Tweaks" forState:UIControlStateNormal];
  [tweaksButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
  [tweaksButton addTarget:self action:@selector(buttonTapped) forControlEvents:UIControlEventTouchUpInside];
  [_rootViewController.view addSubview:tweaksButton];
    
  FBTweak *animationDurationTweak = FBTweakInline(@"Content", @"Animation", @"Duration", 0.5);
  animationDurationTweak.stepValue = [NSNumber numberWithFloat:0.005f];
  animationDurationTweak.precisionValue = [NSNumber numberWithFloat:3.0f];
  

  FBTweakAction(@"Actions", @"Scoped", @"Two", ^{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hello" message:@"Scoped alert test #2." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Done", nil];
    [alert show];
  });

  NSDictionary *dict = @{@"Key 1": @"Value 1", @"Key 2": @"Value 2", @"Key 3": @"Value 3"};
  id val = FBDictionaryTweak(@"Content", @"Animation", @"Dictionary test", dict, @"Key 1");
    
  return YES;
}

- (void)tweakDidChange:(FBTweak *)tweak
{
  if (tweak == _flipTweak) {
    _window.layer.sublayerTransform = CATransform3DMakeScale(1.0, [_flipTweak.currentValue boolValue] ? -1.0 : 1.0, 1.0);
  }
}

- (void)buttonTapped
{
  FBTweakViewController *viewController = [[FBTweakViewController alloc] initWithStore:[FBTweakStore sharedInstance]];
  viewController.tweaksDelegate = self;
  [_window.rootViewController presentViewController:viewController animated:YES completion:NULL];
}

- (void)tweakViewControllerPressedDone:(FBTweakViewController *)tweakViewController
{
  [tweakViewController dismissViewControllerAnimated:YES completion:NULL];
}

- (void)labelTapped
{
  NSTimeInterval duration = FBTweakValue(@"Content", @"Animation", @"Duration", 0.5);
  [UIView animateWithDuration:duration animations:^{
    CGFloat scale = FBTweakValue(@"Content", @"Animation", @"Scale", 2.0);
    _label.transform = CGAffineTransformMakeScale(scale, scale);
  } completion:^(BOOL finished) {
    [UIView animateWithDuration:duration animations:^{
      _label.transform = CGAffineTransformIdentity;
    }];
  }];
}

@end
