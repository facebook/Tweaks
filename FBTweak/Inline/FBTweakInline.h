/**
 Copyright (c) 2014-present, Facebook, Inc.
 All rights reserved.
 
 This source code is licensed under the BSD-style license found in the
 LICENSE file in the root directory of this source tree. An additional grant
 of patent rights can be found in the PATENTS file in the same directory.
 */

#import "FBTweakInlineInternal.h"

/**
  @abstract Common parameters in these macros.
  @param category_ The category the tweak's collection is in. Must be a constant NSString.
  @param collection_ The collection the tweak goes in. Must be a constant NSString.
  @param name_ The name of the tweak. Must be a constant NSString.
  @param default_ The default value of the tweak. If the user doesn't configure
    a custom value or the build is a release build, then the default value is used.
    The default value supports a variety of types, but all must be constant literals.
    Supported types include: BOOL, NSInteger, NSUInteger, CGFloat, NSString *, char *.
  @param min_ Optional, for numbers. The minimum value. Same restrictions as default.
  @param max_ Optional, for numbers. The maximum value. Same restrictions as default.
 */

/**
  @abstract Loads a tweak defined inline at startup.
  @warning If tweaks are disabled, this macro will return nil.
  @return A {@ref FBTweak} for the tweak that was registered at startup.
*/
#define FBTweakInline(category_, collection_, name_, ...) _FBTweakInline(category_, collection_, name_, __VA_ARGS__)

/**
  @abstract Loads the value of a tweak inline.
  @discussion To use a tweak, use this instead of the constant value you otherwise would.
    To use the same tweak in two places, define a C function that returns FBTweakValue.
  @return The current value of the tweak, or the default value if none is set.
 */
#define FBTweakValue(category_, collection_, name_, ...) _FBTweakValue(category_, collection_, name_, __VA_ARGS__)

/**
  @abstract Binds an object property to a tweak.
  @param object_ The object to bind to.
  @param property_ The property to bind.
  @discussion As long as the object is alive, the property will be updated to match the tweak.
 */
#define FBTweakBind(object_, property_, category_, collection_, name_, ...) _FBTweakBind(object_, property_, category_, collection_, name_, __VA_ARGS__)

/**
  @abstract Performs an action on tweak selection.
  @param ... The last parameter is a block containing the action to run.
  @discussion The action does not have access to local state. It might be necessary to
    access global state in the block to perform actions scoped to a specific class.
 */
#define FBTweakAction(category_, collection_, name_, ...) _FBTweakAction(category_, collection_, name_, __VA_ARGS__)


