/**
 Copyright (c) 2014-present, Facebook, Inc.
 All rights reserved.
 
 This source code is licensed under the BSD-style license found in the
 LICENSE file in the root directory of this source tree. An additional grant
 of patent rights can be found in the PATENTS file in the same directory.
 */

#import "FBTweakStore.h"
#import "FBTweak.h"
#import "FBTweakCategory.h"
#import "FBTweakCollection.h"

@implementation FBTweakStore {
  NSMutableArray *_orderedCategories;
  NSMutableDictionary *_namedCategories;
}

+ (instancetype)sharedInstance
{
  static FBTweakStore *sharedInstance = nil;
  
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedInstance = [[self alloc] init];
  });
  
  return sharedInstance;
}

- (instancetype)init
{
  if ((self = [super init])) {
    _orderedCategories = [[NSMutableArray alloc] initWithCapacity:16];
    _namedCategories = [[NSMutableDictionary alloc] initWithCapacity:16];
  }
  
  return self;
}

- (NSArray *)tweakCategories
{
  return [_orderedCategories copy];
}

- (FBTweakCategory *)tweakCategoryWithName:(NSString *)name
{
  return _namedCategories[name];
}

- (void)addTweakCategory:(FBTweakCategory *)category
{
  [_namedCategories setObject:category forKey:category.name];
  [_orderedCategories addObject:category];
}

- (void)removeTweakCategory:(FBTweakCategory *)category
{
  [_namedCategories removeObjectForKey:category.name];
  [_orderedCategories removeObject:category];
}

- (void)reset
{
  for (FBTweakCategory *category in self.tweakCategories) {
    for (FBTweakCollection *collection in category.tweakCollections) {
      for (FBTweak *tweak in collection.tweaks) {
        tweak.currentValue = nil;
      }
    }
  }
}


- (NSDictionary *)dictionaryRepresentation
{
  NSMutableDictionary *categoryDictionary = [NSMutableDictionary new];
  [self.tweakCategories
   enumerateObjectsUsingBlock:^(FBTweakCategory *category, NSUInteger idx, BOOL *stop) {
     NSMutableDictionary *collectionDictionary = [NSMutableDictionary new];
     for (FBTweakCollection *collection in category.tweakCollections) {
       NSMutableDictionary *tweakDictionary = [NSMutableDictionary new];
       for (FBTweak *tweak in collection.tweaks) {
         [tweakDictionary setValue:tweak.currentValue forKey:tweak.name];
       }
       [collectionDictionary setValue:tweakDictionary forKey:collection.name];
     }
     [categoryDictionary setValue:collectionDictionary forKey:category.name];
   }];
  return [NSDictionary dictionaryWithDictionary:categoryDictionary];
}

@end
