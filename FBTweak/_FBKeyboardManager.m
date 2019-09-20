/**
 Copyright (c) 2014-present, Facebook, Inc.
 All rights reserved.

 This source code is licensed under the BSD-style license found in the
 LICENSE file in the root directory of this source tree. An additional grant
 of patent rights can be found in the PATENTS file in the same directory.
 */

#import "_FBKeyboardManager.h"

@implementation _FBKeyboardManager {
  __weak UIScrollView *_scrollView;
}

- (instancetype)init
{
  return [self initWithViewScrollView:nil];
}

- (instancetype)initWithViewScrollView:(UIScrollView *)scrollView
{
  if (self = [super init]) {
    _scrollView = scrollView;
    [self enable];
  }
  return self;
}

- (void)enable
{
  [self disable];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_keyboardFrameChanged:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)disable
{
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)dealloc
{
  [self disable];
}

#pragma mark - Private methods

- (void)_keyboardFrameChanged:(NSNotification *)notification
{
  UIView *contentView = _scrollView.superview;

  NSDictionary *userInfo = [notification userInfo];
  CGRect endFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
  endFrame = [contentView.window convertRect:endFrame fromWindow:nil];
  endFrame = [contentView convertRect:endFrame fromView:contentView.window];

  NSTimeInterval duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
  UIViewAnimationCurve curve = [userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];

  void (^animations)(void) = ^{
    UIEdgeInsets contentInset = _scrollView.contentInset;
    contentInset.bottom = (contentView.bounds.size.height - CGRectGetMinY(endFrame));
    _scrollView.contentInset = contentInset;

    UIEdgeInsets scrollIndicatorInsets = _scrollView.scrollIndicatorInsets;
    scrollIndicatorInsets.bottom = (contentView.bounds.size.height - CGRectGetMinY(endFrame));
    _scrollView.scrollIndicatorInsets = scrollIndicatorInsets;
  };

  UIViewAnimationOptions options = (curve << 16) | UIViewAnimationOptionBeginFromCurrentState;

  [UIView animateWithDuration:duration delay:0 options:options animations:animations completion:NULL];
}

@end
