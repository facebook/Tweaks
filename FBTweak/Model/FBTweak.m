/**
 Copyright (c) 2014-present, Facebook, Inc.
 All rights reserved.
 
 This source code is licensed under the BSD-style license found in the
 LICENSE file in the root directory of this source tree. An additional grant
 of patent rights can be found in the PATENTS file in the same directory.
 */

#import "FBTweak.h"

@implementation FBTweakNumericRange

- (instancetype)initWithMinimumValue:(FBTweakValue)minimumValue maximumValue:(FBTweakValue)maximumValue
{
  if ((self = [super init])) {
    NSParameterAssert(minimumValue != nil);
    NSParameterAssert(maximumValue != nil);

    _minimumValue = minimumValue;
    _maximumValue = maximumValue;
  }

  return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
  FBTweakValue minimumValue = [coder decodeObjectForKey:@"minimumValue"];
  FBTweakValue maximumValue = [coder decodeObjectForKey:@"maximumValue"];
  self = [self initWithMinimumValue:minimumValue maximumValue:maximumValue];

  return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
  [coder encodeObject:_minimumValue forKey:@"minimumValue"];
  [coder encodeObject:_maximumValue forKey:@"maximumValue"];
}

@end

@implementation FBTweak {
  NSHashTable *_observers;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
  NSString *identifier = [coder decodeObjectForKey:@"identifier"];
  
  if ((self = [self initWithIdentifier:identifier])) {
    _name = [coder decodeObjectForKey:@"name"];
    _defaultValue = [coder decodeObjectForKey:@"defaultValue"];

    if ([coder containsValueForKey:@"possibleValues"]) {
      _possibleValues = [coder decodeObjectForKey:@"possibleValues"];
    } else {
      // Backwards compatbility for before possibleValues was introduced.
      FBTweakValue minimumValue = [coder decodeObjectForKey:@"minimumValue"];
      FBTweakValue maximumValue = [coder decodeObjectForKey:@"maximumValue"];
      _possibleValues = [[FBTweakNumericRange alloc] initWithMinimumValue:minimumValue maximumValue:maximumValue];
    }

    _precisionValue = [coder decodeObjectForKey:@"precisionValue"];
    _stepValue = [coder decodeObjectForKey:@"stepValue"];
    
    // Fall back to the user-defaults loaded value if current value isn't set.
    _currentValue = [coder decodeObjectForKey:@"currentValue"] ?: _currentValue;
  }
  
  return self;
}

- (instancetype)initWithIdentifier:(NSString *)identifier
{
  if ((self = [super init])) {
    _identifier = identifier;
    _currentValue = [[NSUserDefaults standardUserDefaults] objectForKey:_identifier];
  }
  
  return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
  [coder encodeObject:_identifier forKey:@"identifier"];
  [coder encodeObject:_name forKey:@"name"];
  
  if (!self.isAction) {
    [coder encodeObject:_defaultValue forKey:@"defaultValue"];
    [coder encodeObject:_possibleValues forKey:@"possibleValues"];
    [coder encodeObject:_currentValue forKey:@"currentValue"];
    [coder encodeObject:_precisionValue forKey:@"precisionValue"];
    [coder encodeObject:_stepValue forKey:@"stepValue"];
  }
}

- (BOOL)isAction
{
  // NSBlock isn't a public class, walk the hierarchy for it.
  Class blockClass = [^{} class];

  while ([blockClass superclass] != [NSObject class]) {
    blockClass = [blockClass superclass];
  }

  return [_defaultValue isKindOfClass:blockClass];
}

- (FBTweakValue)minimumValue
{
  if ([_possibleValues isKindOfClass:[FBTweakNumericRange class]]) {
    return [(FBTweakNumericRange *)_possibleValues minimumValue];
  } else {
    return nil;
  }
}

- (void)setMinimumValue:(FBTweakValue)minimumValue
{
  if (minimumValue == nil) {
    _possibleValues = nil;
  } else if ([_possibleValues isKindOfClass:[FBTweakNumericRange class]]) {
    _possibleValues = [[FBTweakNumericRange alloc] initWithMinimumValue:minimumValue maximumValue:[(FBTweakNumericRange *)_possibleValues maximumValue]];
  } else {
    _possibleValues = [[FBTweakNumericRange alloc] initWithMinimumValue:minimumValue maximumValue:minimumValue];
  }
}

- (FBTweakValue)maximumValue
{
  if ([_possibleValues isKindOfClass:[FBTweakNumericRange class]]) {
    return [(FBTweakNumericRange *)_possibleValues maximumValue];
  } else {
    return nil;
  }
}

- (void)setMaximumValue:(FBTweakValue)maximumValue
{
  if (maximumValue == nil) {
    _possibleValues = nil;
  } else if ([_possibleValues isKindOfClass:[FBTweakNumericRange class]]) {
    _possibleValues = [[FBTweakNumericRange alloc] initWithMinimumValue:[(FBTweakNumericRange *)_possibleValues minimumValue] maximumValue:maximumValue];
  } else {
    _possibleValues = [[FBTweakNumericRange alloc] initWithMinimumValue:maximumValue maximumValue:maximumValue];
  }
}

- (void)setCurrentValue:(FBTweakValue)currentValue
{
  NSAssert(!self.isAction, @"actions cannot have non-default values");

  if (_possibleValues != nil && currentValue != nil) {
    if ([_possibleValues isKindOfClass:[NSArray class]]) {
      if ([_possibleValues indexOfObject:currentValue] == NSNotFound) {
        currentValue = _defaultValue;
      }
    } else if ([_possibleValues isKindOfClass:[NSDictionary class]]) {
      if ([[_possibleValues allKeys] indexOfObject:currentValue] == NSNotFound) {
        currentValue = _defaultValue;
      }
    } else {
      FBTweakValue minimumValue = self.minimumValue;
      if (self.minimumValue != nil && currentValue != nil && [minimumValue compare:currentValue] == NSOrderedDescending) {
        currentValue = minimumValue;
      }

      FBTweakValue maximumValue = self.maximumValue;
      if (maximumValue != nil && currentValue != nil && [maximumValue compare:currentValue] == NSOrderedAscending) {
        currentValue = maximumValue;
      }
    }
  }

  if (_currentValue != currentValue) {
    _currentValue = currentValue;
    [[NSUserDefaults standardUserDefaults] setObject:_currentValue forKey:_identifier];
    
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
