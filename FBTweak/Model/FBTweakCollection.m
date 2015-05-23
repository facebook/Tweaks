/**
 Copyright (c) 2014-present, Facebook, Inc.
 All rights reserved.
 
 This source code is licensed under the BSD-style license found in the
 LICENSE file in the root directory of this source tree. An additional grant
 of patent rights can be found in the PATENTS file in the same directory.
 */

#import "FBTweakCollection.h"
#import "FBTweak.h"

@implementation FBTweakCollection {
  NSMutableArray *_orderedTweaks;
  NSMutableDictionary *_identifierTweaks;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
  NSString *name = [coder decodeObjectForKey:@"name"];
  
  if ((self = [self initWithName:name])) {
    _orderedTweaks = [[coder decodeObjectForKey:@"tweaks"] mutableCopy];
    
    for (FBTweak *tweak in _orderedTweaks) {
      [_identifierTweaks setObject:tweak forKey:tweak.identifier];
    }
  }
  
  return self;
}

- (instancetype)initWithName:(NSString *)name
{
  if ((self = [super init])) {
    _name = [name copy];
    
    _orderedTweaks = [[NSMutableArray alloc] initWithCapacity:4];
    _identifierTweaks = [[NSMutableDictionary alloc] initWithCapacity:4];
  }
  
  return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
  [coder encodeObject:_name forKey:@"name"];
  [coder encodeObject:_orderedTweaks forKey:@"tweaks"];
}

- (FBTweak *)tweakWithIdentifier:(NSString *)identifier
{
  return _identifierTweaks[identifier];
}

- (NSArray *)tweaks
{
  return [_orderedTweaks copy];
}

- (void)addTweak:(FBTweak *)tweak
{
  [_orderedTweaks addObject:tweak];
  [_identifierTweaks setObject:tweak forKey:tweak.identifier];
}

- (void)removeTweak:(FBTweak *)tweak
{
  [_orderedTweaks removeObject:tweak];
  [_identifierTweaks removeObjectForKey:tweak.identifier];
}

@end
