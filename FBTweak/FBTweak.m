/**
 Copyright (c) 2014-present, Facebook, Inc.
 All rights reserved.
 
 This source code is licensed under the BSD-style license found in the
 LICENSE file in the root directory of this source tree. An additional grant
 of patent rights can be found in the PATENTS file in the same directory.
 */

#import "FBTweak.h"
#import "FBTweakStore.h"
#import "FBTweakCollection.h"
#import "FBTweakCategory.h"

@implementation FBTweak {
  NSHashTable *_observers;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
  NSString *identifier = [coder decodeObjectForKey:@"identifier"];
  
  if ((self = [self initWithIdentifier:identifier])) {
    _name = [coder decodeObjectForKey:@"name"];
    _defaultValue = [coder decodeObjectForKey:@"defaultValue"];
    _minimumValue = [coder decodeObjectForKey:@"minimumValue"];
    _maximumValue = [coder decodeObjectForKey:@"maximumValue"];
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
    [coder encodeObject:_minimumValue forKey:@"minimumValue"];
    [coder encodeObject:_maximumValue forKey:@"maximumValue"];
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

- (void)setCurrentValue:(FBTweakValue)currentValue
{
  NSAssert(!self.isAction, @"actions cannot have non-default values");
  if (self.isDictionaryTweak) {
    _currentValue = currentValue;
  } else {
    
    if (_minimumValue != nil && currentValue != nil && [_minimumValue compare:currentValue] == NSOrderedDescending) {
      currentValue = _minimumValue;
    }
    
    if (_maximumValue != nil && currentValue != nil && [_maximumValue compare:currentValue] == NSOrderedAscending) {
      currentValue = _maximumValue;
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


@implementation FBTweak (Dictionary)

-(BOOL)isDictionaryTweak
{
  return self.keyValues;
}

-(void)setKeyValues:(NSDictionary *)keyValues
{
  self.minimumValue = keyValues;
}

-(NSDictionary *)keyValues
{
  return [self.minimumValue isKindOfClass:[NSDictionary class]] ? self.minimumValue: nil;
}

-(NSArray *)allKeys
{
  return [(NSDictionary *)self.keyValues allKeys];
}

-(NSArray *)allValues
{
  return [(NSDictionary *)self.keyValues allValues];
}

-(void)setCurrentKey:(FBTweakValue)currentKey
{
  FBTweakValue value = self.keyValues[currentKey];
  
  [self setCurrentValue:value];
}

-(FBTweakValue)currentKey
{
  return [self.keyValues allKeysForObject:self.currentValue].firstObject;
}

-(FBTweakValue)defaultKey
{
  return [self.keyValues allKeysForObject:self.defaultValue].firstObject;
}

-(void)setDefaultKey:(FBTweakValue)defaultKey
{
  FBTweakValue value = self.keyValues[defaultKey];
  
  [self setDefaultValue:value];
}
@end

FBTweakValue FBDictionaryTweak(NSString *category, NSString *collection, NSString *name, NSDictionary *keyValues, id defaultKey)
{
  FBTweakStore *store = [FBTweakStore sharedInstance];
  FBTweakCategory *cat = [store tweakCategoryWithName:category];
  
  if (!cat) {
    cat = [[FBTweakCategory alloc] initWithName:category];
    [store addTweakCategory:cat];
  }
  
  FBTweakCollection *col = [cat tweakCollectionWithName:collection];
  
  if (!col) {
    col = [[FBTweakCollection alloc] initWithName:collection];
    [cat addTweakCollection:col];
  }
  
  
  FBTweak *tweak = [col tweakWithIdentifier:name];
  
  if (!tweak) {
    tweak = [[FBTweak alloc] initWithIdentifier:name];
    tweak.name = name;
    tweak.keyValues = keyValues;
    tweak.defaultKey = defaultKey;
    
    [col addTweak:tweak];
  }
  
  return tweak.currentValue ?: tweak.defaultValue;
}

