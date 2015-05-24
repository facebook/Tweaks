/**
 Copyright (c) 2014-present, Facebook, Inc.
 All rights reserved.
 
 This source code is licensed under the BSD-style license found in the
 LICENSE file in the root directory of this source tree. An additional grant
 of patent rights can be found in the PATENTS file in the same directory.
 */

#import <objc/runtime.h>

#import "FBTweak.h"
#import "_FBTweakBindObserver.h"

@interface _FBTweakBindObserver () <FBTweakObserver>
@end

@implementation _FBTweakBindObserver {
  FBTweak *_tweak;
  _FBTweakBindObserverBlock _block;
  __weak id _object;
}

- (instancetype)initWithTweak:(FBTweak *)tweak block:(_FBTweakBindObserverBlock)block
{
  if ((self = [super init])) {
    NSAssert(tweak != nil, @"tweak is required");
    NSAssert(block != NULL, @"block is required");
    
    _tweak = tweak;
    _block = block;
    
    [tweak addObserver:self];
  }
  
  return self;
}

- (void)tweakDidChange:(FBTweak *)tweak
{
  __attribute__((objc_precise_lifetime)) id strongObject = _object;
  
  if (strongObject != nil) {
    _block(strongObject);
  }
}

- (void)attachToObject:(id)object
{
  NSAssert(_object == nil, @"can only attach to an object once");
  NSAssert(object != nil, @"object is required");
  
  _object = object;
  objc_setAssociatedObject(object, (__bridge void *)self, self, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
