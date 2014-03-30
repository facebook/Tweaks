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

-(void)loadTweakValuesFromURL:(NSURL *)url
{
    if (![[url host] isEqualToString:@"importTweaks"]) {
        return;
    }
    [self reset];
    NSNumberFormatter* nf=[[NSNumberFormatter alloc] init];
    NSArray* parameters=[[[url query] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] componentsSeparatedByString:@"&"];
    for (NSString* param in parameters) {
        NSArray* paramComponents=[param componentsSeparatedByString:@"="];
        NSArray* tweakPath=[paramComponents[0] componentsSeparatedByString:@"-"];
        
        FBTweakCategory* category=(FBTweakCategory*)[self tweakCategoryWithName:tweakPath[0]];
        FBTweakCollection* collection=(FBTweakCollection*)[category tweakCollectionWithName:tweakPath[1]];
        FBTweak* tweak= (FBTweak*)[collection tweakWithIdentifier:[NSString
                                                                   stringWithFormat:@"FBTweak:%@",paramComponents[0]]] ;
        NSNumber* tweakValue=[nf numberFromString:paramComponents[1]];
        if (!tweakValue) {
            tweak.currentValue=paramComponents[1];
        }
        else{
            tweak.currentValue=tweakValue;
        }
    }
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

@end
