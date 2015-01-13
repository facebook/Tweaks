/**
 Copyright (c) 2014-present, Facebook, Inc.
 All rights reserved.
 
 This source code is licensed under the BSD-style license found in the
 LICENSE file in the root directory of this source tree. An additional grant
 of patent rights can be found in the PATENTS file in the same directory.
 */

#import <Foundation/Foundation.h>

@protocol FBTweakObserver;

/**
  @abstract Represents a possible value of a tweak.
  @discussion Should be able to be persisted in user defaults,
    except actions (represented as blocks without a currentValue).
    For minimum and maximum values, should implement -compare:.
 */
typedef id FBTweakValue;

/**
  @abstract Represents a unique, named tweak.
  @discussion A tweak contains a persistent, editable value.
 */
@interface FBTweak : NSObject <NSCoding>

/**
  @abstract Creates a new tweak model.
  @discussion This is the designated initializer.
 */
- (instancetype)initWithIdentifier:(NSString *)identifier;

/**
  @abstract This tweak's unique identifier.
  @discussion Used when reading and writing the tweak's value.
 */
@property (nonatomic, copy, readonly) NSString *identifier;

/**
  @abstract The human-readable name of the tweak.
  @discussion Show the name when displaying the tweak.
 */
@property (nonatomic, copy, readwrite) NSString *name;

/**
  @abstract If this tweak is an action, with a block value.
  @param If YES, {@ref currentValue} should not be set and
    {@ref defaultValue} is a block rather than a value object.
 */
@property (nonatomic, readonly, assign, getter = isAction) BOOL action;

/**
  @abstract The default value of the tweak.
  @discussion Use this when the current value is unset.
    For actions, set this property to a block instead.
 */
@property (nonatomic, strong, readwrite) FBTweakValue defaultValue;

/**
  @abstract The current value of the tweak. Can be nil.
  @discussion Changes will be propagated to disk. Enforces minimum
    and maximum values when changed. Must not be set on actions.
 */
@property (nonatomic, strong, readwrite) FBTweakValue currentValue;

/**
  @abstract The minimum value of the tweak.
  @discussion Optional. If nil, there is no minimum.
    Should not be set on tweaks representing actions.
 */
@property (nonatomic, strong, readwrite) FBTweakValue minimumValue;

/**
  @abstract The maximum value of the tweak.
  @discussion Optional. If nil, there is no maximum.
    Should not be set on tweaks representing actions.
 */
@property (nonatomic, strong, readwrite) FBTweakValue maximumValue;

/**
 @abstract The step value of the tweak.
 @discussion Optional. If nil, the step value is calculated of miniumum and maxium.
 */
@property (nonatomic, strong, readwrite) FBTweakValue stepValue;

/**
 @abstract The decimal precision value of the tweak.
 @discussion Optional. If nil, the precision value is calculated of the step value.
 */
@property (nonatomic, strong, readwrite) FBTweakValue precisionValue;

/**
  @abstract Adds an observer to the tweak.
  @param object The observer. Must not be nil.
  @discussion A weak reference is taken on the observer.
 */
- (void)addObserver:(id<FBTweakObserver>)observer;

/**
  @abstract Removes an observer from the tweak.
  @param observer The observer to remove. Must not be nil.
  @discussion Optional, removing an observer isn't required.
 */
- (void)removeObserver:(id<FBTweakObserver>)observer;

@end

/**
  @abstract Responds to updates when a tweak changes.
 */
@protocol FBTweakObserver <NSObject>

/**
  @abstract Called when a tweak's value changes.
  @param tweak The tweak which changed in value.
 */
- (void)tweakDidChange:(FBTweak *)tweak;

@end


/**
 @abstract Provides key-value capabilities tweak.
 @discussion A key-value tweak offers key-value mapping of all possible cominations, using the keyValues property.
 Each possible value is mapped to its display name.
 
 The dictionary is stored internally in the minimum value property.
 */
@interface FBTweak (Dictionary)

@property (nonatomic, readonly) BOOL isDictionaryTweak;

/**
 @abstract Returns all possible keys (human-readable names).
 @note Values in this array are in no specific order, and they are NOT guaranteed to be in the same order of allValues.
 */
@property (strong, nonatomic, readonly) NSArray *allKeys;

/**
 @abstract Returns all possible value.
 @note Values in this array are in no specific order, and they are NOT guaranteed to be in the same order of allKeys.
 */
@property (strong, nonatomic, readonly) NSArray *allValues;

/**
 @abstact All possible keys and values for the tweak.
 */
@property (strong, nonatomic) NSDictionary *keyValues;

/**
 @abstract The key (human-readable name) of the tweak's current value.
 */
@property (strong, nonatomic) FBTweakValue currentKey;

/**
 @abstract The key (human-readable name) of the tweak's default value.
 @note Changing this property changes defualtValue accordingly.
 */
@property (strong, nonatomic) FBTweakValue defaultKey;

@end

FBTweakValue FBDictionaryTweak(NSString *category, NSString *collection, NSString *name, NSDictionary *keyValues, id defaultKey);

