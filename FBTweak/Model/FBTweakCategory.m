/**
 Copyright (c) 2014-present, Facebook, Inc.
 All rights reserved.
 
 This source code is licensed under the BSD-style license found in the
 LICENSE file in the root directory of this source tree. An additional grant
 of patent rights can be found in the PATENTS file in the same directory.
 */

#import "FBTweakCategory.h"
#import "FBTweakCollection.h"

@implementation FBTweakCategory {
  NSMutableArray *_orderedCollections;
  NSMutableDictionary *_namedCollections;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
  NSString *name = [coder decodeObjectForKey:@"name"];
  
  if ((self = [self initWithName:name])) {
    _orderedCollections = [[coder decodeObjectForKey:@"collections"] mutableCopy];
    
    for (FBTweakCollection *tweakCollection in _orderedCollections) {
      [_namedCollections setObject:tweakCollection forKey:tweakCollection.name];
    }
  }
  
  return self;
}

- (instancetype)initWithName:(NSString *)name
{
  if ((self = [super init])) {
    _name = [name copy];
    
    _orderedCollections = [[NSMutableArray alloc] initWithCapacity:4];
    _namedCollections = [[NSMutableDictionary alloc] initWithCapacity:4];
  }
  
  return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
  [coder encodeObject:_name forKey:@"name"];
  [coder encodeObject:_orderedCollections forKey:@"collections"];
}

- (FBTweakCollection *)tweakCollectionWithName:(NSString *)name
{
  return _namedCollections[name];
}

- (NSArray *)tweakCollections
{
  return [_orderedCollections copy];
}

- (void)addTweakCollection:(FBTweakCollection *)tweakCollection
{
  [_orderedCollections addObject:tweakCollection];
  [_namedCollections setObject:tweakCollection forKey:tweakCollection.name];
}

- (void)removeTweakCollection:(FBTweakCollection *)tweakCollection
{
  [_orderedCollections removeObject:tweakCollection];
  [_namedCollections removeObjectForKey:tweakCollection.name];
}

@end
