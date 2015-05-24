/**
 Copyright (c) 2014-present, Facebook, Inc.
 All rights reserved.

 This source code is licensed under the BSD-style license found in the
 LICENSE file in the root directory of this source tree. An additional grant
 of patent rights can be found in the PATENTS file in the same directory.
 */

#import "FBTweak.h"
#import "_FBTweakTableViewCell.h"

typedef NS_ENUM(NSUInteger, _FBTweakTableViewCellMode) {
  _FBTweakTableViewCellModeNone = 0,
  _FBTweakTableViewCellModeBoolean,
  _FBTweakTableViewCellModeInteger,
  _FBTweakTableViewCellModeReal,
  _FBTweakTableViewCellModeString,
  _FBTweakTableViewCellModeAction,
  _FBTweakTableViewCellModeDictionary,
  _FBTweakTableViewCellModeArray,
};

_FBTweakTableViewCellMode modeForTweak(FBTweak *tweak)
{
  FBTweakValue value = (tweak.currentValue ?: tweak.defaultValue);

  _FBTweakTableViewCellMode mode = _FBTweakTableViewCellModeNone;
  if ([tweak.possibleValues isKindOfClass:[NSDictionary class]]) {
    mode = _FBTweakTableViewCellModeDictionary;
  } else if ([tweak.possibleValues isKindOfClass:[NSArray class]]) {
    mode = _FBTweakTableViewCellModeArray;
  } else if ([value isKindOfClass:[NSString class]]) {
    mode = _FBTweakTableViewCellModeString;
  } else if ([value isKindOfClass:[NSNumber class]]) {
    // In the 64-bit runtime, BOOL is a real boolean.
    // NSNumber doesn't always agree; compare both.
    if (strcmp([value objCType], @encode(char)) == 0 ||
        strcmp([value objCType], @encode(_Bool)) == 0) {
      mode = _FBTweakTableViewCellModeBoolean;
    } else if (strcmp([value objCType], @encode(NSInteger)) == 0 ||
               strcmp([value objCType], @encode(NSUInteger)) == 0 ||
               strcmp([value objCType], @encode(int)) == 0 ||
               strcmp([value objCType], @encode(long)) == 0) {
      mode = _FBTweakTableViewCellModeInteger;
    } else {
      mode = _FBTweakTableViewCellModeReal;
    }
  } else if ([tweak isAction]) {
    mode = _FBTweakTableViewCellModeAction;
  }
  return mode;
}


@implementation _FBTweakTableViewCell {
  FBTweak *_tweak;
  NSControl *_accessory;
}

static const CGRect initialFrame = (CGRect){0, 0, 300, 20};
static const CGRect initialAccessoryFrame = (CGRect){300, 0, 300, 20};

static NSTextField *label(NSString *string)
{
  NSTextField *tf = [[NSTextField alloc] initWithFrame:initialFrame];
  tf.editable = NO;
  tf.stringValue = string;
  tf.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
  tf.bezeled = NO;
  tf.backgroundColor = [NSColor clearColor];
  tf.bordered = NO;
  return tf;
}

static NSTextField *viewToEditText(NSString *string)
{
  NSTextField *tf = [[NSTextField alloc] initWithFrame:initialAccessoryFrame];
  tf.autoresizingMask = NSViewHeightSizable;
  tf.stringValue = string ?: @"";
  tf.placeholderString = @"No Value";
  return tf;
}

static NSMenu *buildMenu(id obj)
{
  NSMenu *menu = [[NSMenu alloc] initWithTitle:@""];
  if ([obj isKindOfClass:[NSArray class]]) {
    for (id item in obj) {
      NSMenuItem *menuItem = [[NSMenuItem alloc] init];
      menuItem.title = [item description];
      menuItem.representedObject = item;
      [menu addItem:menuItem];
    }
  } else if ([obj isKindOfClass:[NSDictionary class]]) {
    [obj enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
      NSMenuItem *menuItem = [[NSMenuItem alloc] init];
      menuItem.title = [obj description];
      menuItem.representedObject = key;
      [menu addItem:menuItem];
    }];
  }
  return menu;
}

static NSControl *accessoryForTweak(FBTweak *tweak)
{
  switch (modeForTweak(tweak)) {
    case _FBTweakTableViewCellModeBoolean:
    {
      NSButton *b = [[NSButton alloc] initWithFrame:initialAccessoryFrame];
      [b setButtonType:NSToggleButton];
      return b;
    }
    case _FBTweakTableViewCellModeAction:
    {
      NSButton *b = [[NSButton alloc] initWithFrame:initialAccessoryFrame];
      b.title = @"Action";
      return b;
    }

    case _FBTweakTableViewCellModeArray:
    case _FBTweakTableViewCellModeDictionary:
    {
      NSPopUpButton *p = [[NSPopUpButton alloc] initWithFrame:initialAccessoryFrame];
      p.controlSize = NSSmallControlSize;
      p.title = tweak.name;
      p.menu = buildMenu(tweak.possibleValues);
      id arr = [tweak.possibleValues isKindOfClass:[NSDictionary class]] ? [tweak.possibleValues allKeys] : tweak.possibleValues;
      [p selectItemAtIndex:[arr indexOfObject:tweak.currentValue]];
      return p;
    }

    case _FBTweakTableViewCellModeReal:
    case _FBTweakTableViewCellModeInteger:
    case _FBTweakTableViewCellModeString:
    {
      return viewToEditText([tweak.currentValue description]);
    }

    case _FBTweakTableViewCellModeNone:
    {
      return [[NSControl alloc] initWithFrame:initialAccessoryFrame];
    }
  }
}

+ (instancetype)cellWithTweak:(FBTweak *)tweak
{

  _FBTweakTableViewCell *s = [[self alloc] initWithFrame:initialFrame];
  NSTextField *tf = label(tweak.name);
  s.textField = tf;

  s->_tweak = tweak;

  s->_accessory = accessoryForTweak(tweak);
  s->_accessory.action = @selector(changeTweak:);
  s->_accessory.target = s;
  [s addSubview:tf];
  [s addSubview:s->_accessory];

  return s;
}

- (id)valueFromSender:(id)sender
{
  switch (modeForTweak(_tweak)) {
    case _FBTweakTableViewCellModeBoolean:
    {
      return @((BOOL)[sender intValue]);
    }
    case _FBTweakTableViewCellModeAction:
    {
      ((void(^)())_tweak.defaultValue)();
    }
    case _FBTweakTableViewCellModeArray:
    {
      return [[sender selectedItem] representedObject];
    }
    case _FBTweakTableViewCellModeDictionary:
    {
      return [[sender selectedItem] representedObject];
    }
    case _FBTweakTableViewCellModeReal:
    {
      return @([sender doubleValue]);
    }
    case _FBTweakTableViewCellModeInteger:
    {
      return @([sender integerValue]);
    }
    case _FBTweakTableViewCellModeString:
    {
      return [sender stringValue];
    }
    case _FBTweakTableViewCellModeNone:
    {
      return nil;
    }
  }
}

- (void)changeTweak:(id)sender
{
  id value = [self valueFromSender:sender];
  if (value) {
    _tweak.currentValue = value;
  }
}

- (void)layout
{
  [super layout];

  CGRect bounds = self.bounds;
  CGFloat nameWidth = [self.textField sizeThatFits:(CGSize){bounds.size.width - 30.0, bounds.size.height}].width + 8;
  CGFloat accessoryWidth = [_accessory sizeThatFits:(CGSize){bounds.size.width - nameWidth, bounds.size.height}].width;
  accessoryWidth = fmax(accessoryWidth, 60);

  self.textField.frame = CGRectMake(0, 0, nameWidth, bounds.size.height);
  _accessory.frame = CGRectMake(nameWidth, 0, accessoryWidth, bounds.size.height);
}


@end
