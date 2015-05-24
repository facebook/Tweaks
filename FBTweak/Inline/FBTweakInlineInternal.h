/**
 Copyright (c) 2014-present, Facebook, Inc.
 All rights reserved.
 
 This source code is licensed under the BSD-style license found in the
 LICENSE file in the root directory of this source tree. An additional grant
 of patent rights can be found in the PATENTS file in the same directory.
 */

#import "FBTweakEnabled.h"
#import "FBTweak.h"
#import "FBTweakStore.h"
#import "FBTweakCategory.h"
#import "FBTweakCollection.h"
#import "_FBTweakBindObserver.h"

#if !FB_TWEAK_ENABLED

#define __FBTweakDefault(default, ...) default
#define _FBTweakInline(category_, collection_, name_, ...) nil
#define _FBTweakValue(category_, collection_, name_, ...) (__FBTweakDefault(__VA_ARGS__, _))
#define _FBTweakBind(object_, property_, category_, collection_, name_, ...) (object_.property_ = __FBTweakDefault(__VA_ARGS__, _))
#define _FBTweakAction(category_, collection_, name_, ...)

#else

#ifdef __cplusplus
extern "C" {
#endif

#define FBTweakSegmentName "__DATA"
#define FBTweakSectionName "FBTweak"

#define FBTweakEncodingAction "__ACTION__"

typedef __unsafe_unretained NSString *FBTweakLiteralString;
  
typedef struct {
  FBTweakLiteralString *category;
  FBTweakLiteralString *collection;
  FBTweakLiteralString *name;
  void *value;
  void *possible;
  char **encoding;
} fb_tweak_entry;

// cast to a pointer to a block, dereferenece said pointer, call said block
#define fb_tweak_entry_block_field(type, entry, field) (*(type (^__unsafe_unretained (*))(void))(entry->field))()

extern NSString *_FBTweakIdentifier(fb_tweak_entry *entry);
  
#if __has_feature(objc_arc)
#define _FBTweakRelease(x)
#else
#define _FBTweakRelease(x) [x release]
#endif
  
#define __FBTweakConcat_(X, Y) X ## Y
#define __FBTweakConcat(X, Y) __FBTweakConcat_(X, Y)

#define __FBTweakIndex(_1, _2, _3, value, ...) value
#define __FBTweakIndexCount(...) __FBTweakIndex(__VA_ARGS__, 3, 2, 1)
  
#define __FBTweakDispatch1(__withoutRange, __withRange, __withPossible, ...) __withoutRange
#define __FBTweakDispatch2(__withoutRange, __withRange, __withPossible, ...) __withPossible
#define __FBTweakDispatch3(__withoutRange, __withRange, __withPossible, ...) __withRange
#define _FBTweakDispatch(__withoutRange, __withRange, __withPossible, ...) __FBTweakConcat(__FBTweakDispatch, __FBTweakIndexCount(__VA_ARGS__))(__withoutRange, __withRange, __withPossible)
  
#define _FBTweakInlineWithoutRange(category_, collection_, name_, default_) \
((^{ \
  return _FBTweakInlineWithPossibleInternal(category_, collection_, name_, default_, NULL); \
})())
#define _FBTweakInlineWithRange(category_, collection_, name_, default_, min_, max_) \
((^{ \
  __attribute__((used)) static __typeof__(default_) min__ = (__typeof__(default_))min_; \
  __attribute__((used)) static __typeof__(default_) max__ = (__typeof__(default_))max_; \
  return _FBTweakInlineWithPossibleInternal(category_, collection_, name_, default_, [[FBTweakNumericRange alloc] initWithMinimumValue:@(min__) maximumValue:@(max__)]); \
})())
#define _FBTweakInlineWithPossible(category_, collection_, name_, default_, possible_) \
((^{ \
  return _FBTweakInlineWithPossibleInternal(category_, collection_, name_, default_, possible_); \
})())
#define _FBTweakInlineWithPossibleInternal(category_, collection_, name_, default_, possible_) \
((^{ \
  /* store the tweak data in the binary at compile time. */ \
  __attribute__((used)) static FBTweakLiteralString category__ = category_; \
  __attribute__((used)) static FBTweakLiteralString collection__ = collection_; \
  __attribute__((used)) static FBTweakLiteralString name__ = name_; \
  __attribute__((used)) static void *default__ = (__bridge void *) ^{ return default_; }; \
  __attribute__((used)) static void *possible__ = (__bridge void *)  ^{ return possible_; }; \
  __attribute__((used)) static char *encoding__ = (char *)@encode(__typeof__(default_)); \
  __attribute__((used)) __attribute__((section (FBTweakSegmentName "," FBTweakSectionName))) static fb_tweak_entry entry = \
    { &category__, &collection__, &name__, (void *)&default__, (void *)&possible__, &encoding__ }; \
\
  /* find the registered tweak with the given identifier. */ \
  FBTweakStore *store = [FBTweakStore sharedInstance]; \
  FBTweakCategory *category = [store tweakCategoryWithName:category__]; \
  FBTweakCollection *collection = [category tweakCollectionWithName:collection__]; \
\
  NSString *identifier = _FBTweakIdentifier(&entry); \
  FBTweak *__inline_tweak = [collection tweakWithIdentifier:identifier]; \
\
  return __inline_tweak; \
})())
#define _FBTweakInline(category_, collection_, name_, ...) _FBTweakDispatch(_FBTweakInlineWithoutRange, _FBTweakInlineWithRange, _FBTweakInlineWithPossible, __VA_ARGS__)(category_, collection_, name_, __VA_ARGS__)
  
#define _FBTweakValueInternal(tweak_, category_, collection_, name_, default_) \
((^{ \
  /* returns a correctly typed version of the current tweak value */ \
  FBTweakValue currentValue = tweak_.currentValue ?: tweak_.defaultValue; \
  return _Generic(default_, \
    float: [currentValue floatValue], \
    const float: [currentValue floatValue], \
    double: [currentValue doubleValue], \
    const double: [currentValue doubleValue], \
    short: [currentValue shortValue], \
    const short: [currentValue shortValue], \
    unsigned short: [currentValue unsignedShortValue], \
    const unsigned short: [currentValue unsignedShortValue], \
    int: [currentValue intValue], \
    const int: [currentValue intValue], \
    unsigned int: [currentValue unsignedIntValue], \
    const unsigned int: [currentValue unsignedIntValue], \
    long: [currentValue longValue], \
    const long: [currentValue longValue], \
    unsigned long: [currentValue unsignedLongValue], \
    const unsigned long: [currentValue unsignedLongValue], \
    long long: [currentValue longLongValue], \
    const long long: [currentValue longLongValue], \
    unsigned long long: [currentValue unsignedLongLongValue], \
    const unsigned long long: [currentValue unsignedLongLongValue], \
    BOOL: [currentValue boolValue], \
    const BOOL: [currentValue boolValue], \
    id: currentValue, \
    const id: currentValue, \
    /* assume char * as the default. */ \
    /* constant strings are typed as char[N] */ \
    /* and we can't enumerate all of those. */ \
    /* luckily, we only need one fallback */ \
    default: [currentValue UTF8String] \
  ); \
})())

#define _FBTweakValueWithoutRange(category_, collection_, name_, default_) \
((^{ \
    FBTweak *__value_tweak = _FBTweakInlineWithoutRange(category_, collection_, name_, default_); \
    return _FBTweakValueInternal(__value_tweak, category_, collection_, name_, default_); \
})())
#define _FBTweakValueWithRange(category_, collection_, name_, default_, min_, max_) \
((^{ \
  FBTweak *__value_tweak = _FBTweakInlineWithRange(category_, collection_, name_, default_, min_, max_); \
  return _FBTweakValueInternal(__value_tweak, category_, collection_, name_, default_); \
})())
#define _FBTweakValueWithPossible(category_, collection_, name_, default_, possible_) \
((^{ \
  FBTweak *__value_tweak = _FBTweakInlineWithPossible(category_, collection_, name_, default_, possible_); \
  return _FBTweakValueInternal(__value_tweak, category_, collection_, name_, default_); \
})())
#define _FBTweakValue(category_, collection_, name_, ...) _FBTweakDispatch(_FBTweakValueWithoutRange, _FBTweakValueWithRange, _FBTweakValueWithPossible, __VA_ARGS__)(category_, collection_, name_, __VA_ARGS__)

#define _FBTweakBindWithoutRange(object_, property_, category_, collection_, name_, default_) \
((^{ \
  FBTweak *__bind_tweak = _FBTweakInlineWithoutRange(category_, collection_, name_, default_); \
  _FBTweakBindInternal(object_, property_, category_, collection_, name_, default_, __bind_tweak); \
})())
#define _FBTweakBindWithRange(object_, property_, category_, collection_, name_, default_, min_, max_) \
((^{ \
  FBTweak *__bind_tweak = _FBTweakInlineWithRange(category_, collection_, name_, default_, min_, max_); \
  _FBTweakBindInternal(object_, property_, category_, collection_, name_, default_, __bind_tweak); \
})())
#define _FBTweakBindWithPossible(object_, property_, category_, collection_, name_, default_, possible_) \
((^{ \
  FBTweak *__bind_tweak = _FBTweakInlineWithPossible(category_, collection_, name_, default_, possible_); \
  _FBTweakBindInternal(object_, property_, category_, collection_, name_, default_, __bind_tweak); \
})())
#define _FBTweakBindInternal(object_, property_, category_, collection_, name_, default_, tweak_) \
((^{ \
  object_.property_ = _FBTweakValueInternal(tweak_, category_, collection_, name_, default_); \
  _FBTweakBindObserver *observer__ = [[_FBTweakBindObserver alloc] initWithTweak:tweak_ block:^(id object__) { \
    __typeof__(object_) object___ = object__; \
    object___.property_ = _FBTweakValueInternal(tweak_, category_, collection_, name_, default_); \
  }]; \
  [observer__ attachToObject:object_]; \
})())
#define _FBTweakBind(object_, property_, category_, collection_, name_, ...) _FBTweakDispatch(_FBTweakBindWithoutRange, _FBTweakBindWithRange, _FBTweakBindWithPossible, __VA_ARGS__)(object_, property_, category_, collection_, name_, __VA_ARGS__)

#define _FBTweakAction(category_, collection_, name_, ...) \
  _FBTweakActionInternal(category_, collection_, name_, __COUNTER__, __VA_ARGS__)
#define _FBTweakActionInternal(category_, collection_, name_, suffix_, ...) \
  /* store the tweak data in the binary at compile time. */ \
  __attribute__((used)) static FBTweakLiteralString __FBTweakConcat(__fb_tweak_action_category_, suffix_) = category_; \
  __attribute__((used)) static FBTweakLiteralString __FBTweakConcat(__fb_tweak_action_collection_, suffix_) = collection_; \
  __attribute__((used)) static FBTweakLiteralString __FBTweakConcat(__fb_tweak_action_name_, suffix_) = name_; \
  __attribute__((used)) static dispatch_block_t __FBTweakConcat(__fb_tweak_action_block_, suffix_) = __VA_ARGS__; \
  __attribute__((used)) static char *__FBTweakConcat(__fb_tweak_action_encoding_, suffix_) = (char *)FBTweakEncodingAction; \
  __attribute__((used)) __attribute__((section (FBTweakSegmentName "," FBTweakSectionName))) static fb_tweak_entry __FBTweakConcat(__fb_tweak_action_entry_, suffix_) = { \
    &__FBTweakConcat(__fb_tweak_action_category_, suffix_), \
    &__FBTweakConcat(__fb_tweak_action_collection_, suffix_), \
    &__FBTweakConcat(__fb_tweak_action_name_, suffix_), \
    &__FBTweakConcat(__fb_tweak_action_block_, suffix_), \
    NULL, \
    &__FBTweakConcat(__fb_tweak_action_encoding_, suffix_), \
  }; \

#ifdef __cplusplus
}
#endif

#endif

