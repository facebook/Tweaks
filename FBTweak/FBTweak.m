/**
 Copyright (c) 2014-present, Facebook, Inc.
 All rights reserved.
 
 This source code is licensed under the BSD-style license found in the
 LICENSE file in the root directory of this source tree. An additional grant
 of patent rights can be found in the PATENTS file in the same directory.
 */

#import "FBTweak.h"

@implementation FBTweak {
  NSHashTable *_observers;
}

- (instancetype)initWithIdentifier:(NSString *)identifier
{
  if ((self = [super init])) {
    _identifier = identifier;
    _currentValue = [[NSUserDefaults standardUserDefaults] objectForKey:_identifier];
  }
  
  return self;
}

- (void)setCurrentValue:(FBTweakValue)currentValue
{
  if (_minimumValue != nil && currentValue != nil && [_minimumValue compare:currentValue] == NSOrderedDescending) {
    currentValue = _minimumValue;
  }
  
  if (_maximumValue != nil && currentValue != nil && [_maximumValue compare:currentValue] == NSOrderedAscending) {
    currentValue = _maximumValue;
  }
  
  if (_currentValue != currentValue) {
    _currentValue = currentValue;
    [[NSUserDefaults standardUserDefaults] setObject:_currentValue forKey:_identifier];
    [[NSUserDefaults standardUserDefaults] synchronize];
    for (id<FBTweakObserver> observer in [_observers setRepresentation]) {
      [observer tweakDidChange:self];
    }
  }
}

- (void)addObserver:(id<FBTweakObserver>)observer
{
  if (_observers == nil) {
    _observers = [NSHashTable weakObjectsHashTable];
  }
  
  NSAssert(observer != nil, @"observer is required");
  [_observers addObject:observer];
}

- (void)removeObserver:(id<FBTweakObserver>)observer
{
  NSAssert(observer != nil, @"observer is required");
  [_observers removeObject:observer];
}

@end
