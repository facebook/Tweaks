/**
 Copyright (c) 2014-present, Facebook, Inc.
 All rights reserved.
 
 This source code is licensed under the BSD-style license found in the
 LICENSE file in the root directory of this source tree. An additional grant
 of patent rights can be found in the PATENTS file in the same directory.
 */

#import "FBTweak.h"
#import "_FBTweakTableViewCell.h"

static UIImage *_FBCreateColorCellsThumbnail(UIColor *color, CGSize size) {
  UIGraphicsBeginImageContext(size);
  UIBezierPath *rPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, size.width, size.height)];
  [color setFill];
  [rPath fill];
  UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return image;
}

typedef NS_ENUM(NSUInteger, _FBTweakTableViewCellMode) {
  _FBTweakTableViewCellModeNone = 0,
  _FBTweakTableViewCellModeBoolean,
  _FBTweakTableViewCellModeInteger,
  _FBTweakTableViewCellModeReal,
  _FBTweakTableViewCellModeString,
  _FBTweakTableViewCellModeAction,
  _FBTweakTableViewCellModeDictionary,
  _FBTweakTableViewCellModeArray,
  _FBTweakTableViewCellModeColor,
};

@interface _FBTweakTableViewCell () <UITextFieldDelegate>
@end

@implementation _FBTweakTableViewCell {
  UIView *_accessoryView;
  
  _FBTweakTableViewCellMode _mode;
  UISwitch *_switch;
  UITextField *_textField;
  UIStepper *_stepper;
}

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
  if ((self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier])) {
    _accessoryView = [[UIView alloc] init];

    _switch = [[UISwitch alloc] init];
    [_switch addTarget:self action:@selector(_switchChanged:) forControlEvents:UIControlEventValueChanged];
    [_accessoryView addSubview:_switch];
    
    _textField = [[UITextField alloc] init];
    _textField.textAlignment = NSTextAlignmentRight;
    _textField.delegate = self;
    [_accessoryView addSubview:_textField];
    
    _stepper = [[UIStepper alloc] init];
    [_stepper addTarget:self action:@selector(_stepperChanged:) forControlEvents:UIControlEventValueChanged];
    [_accessoryView addSubview:_stepper];
    
    self.detailTextLabel.textColor = [UIColor blackColor];
  }

  return self;
}

- (void)dealloc
{
  [_switch removeTarget:self action:@selector(_switchChanged:) forControlEvents:UIControlEventValueChanged];
  _textField.delegate = nil;
  [_stepper removeTarget:self action:@selector(_stepperChanged:) forControlEvents:UIControlEventValueChanged];
}

- (void)layoutSubviews
{
  if (_mode == _FBTweakTableViewCellModeBoolean) {
    [_switch sizeToFit];
    _accessoryView.bounds = _switch.bounds;
  } else if (_mode == _FBTweakTableViewCellModeInteger ||
             _mode == _FBTweakTableViewCellModeReal) {
    [_stepper sizeToFit];
    
    CGRect textFrame = CGRectMake(0, 0, self.bounds.size.width / 4, self.bounds.size.height);
    CGRect stepperFrame = CGRectMake(textFrame.size.width + 6.0,
                                     (textFrame.size.height - _stepper.bounds.size.height) / 2,
                                     _stepper.bounds.size.width,
                                     _stepper.bounds.size.height);
    _textField.frame = CGRectIntegral(textFrame);
    _stepper.frame = CGRectIntegral(stepperFrame);
    
    CGRect accessoryFrame = CGRectUnion(stepperFrame, textFrame);
    _accessoryView.bounds = CGRectIntegral(accessoryFrame);
  } else if (_mode == _FBTweakTableViewCellModeString) {
    CGFloat margin = CGRectGetMinX(self.textLabel.frame);
    CGFloat textFieldWidth = self.bounds.size.width - (margin * 3.0) - [self.textLabel sizeThatFits:CGSizeZero].width;
    CGRect textBounds = CGRectMake(0, 0, textFieldWidth, self.bounds.size.height);
    _textField.frame = CGRectIntegral(textBounds);
    _accessoryView.bounds = CGRectIntegral(textBounds);
  } else if (_mode == _FBTweakTableViewCellModeColor) {
    CGRect textBounds = CGRectMake(0, 0, self.bounds.size.width / 3, self.bounds.size.height);
    _textField.frame = CGRectIntegral(textBounds);
    _accessoryView.bounds = CGRectIntegral(textBounds);
  } else if (_mode == _FBTweakTableViewCellModeAction) {
    _accessoryView.bounds = CGRectZero;
  }

  // This positions the accessory view, so call it after updating its bounds.
  [super layoutSubviews];
}

#pragma mark - Configuration

- (void)setTweak:(FBTweak *)tweak
{
  _tweak = tweak;
  
  self.textLabel.text = tweak.name;
  
  FBTweakValue value = (_tweak.currentValue ?: _tweak.defaultValue);
  
  _FBTweakTableViewCellMode mode = _FBTweakTableViewCellModeNone;
  if ([tweak.possibleValues isKindOfClass:[NSDictionary class]]) {
    mode = _FBTweakTableViewCellModeDictionary;
  } else if ([tweak.possibleValues isKindOfClass:[NSArray class]]) {
    mode = _FBTweakTableViewCellModeArray;
  } else if ([value isKindOfClass:[UIColor class]]) {
    mode = _FBTweakTableViewCellModeColor;
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
  } else if ([_tweak isAction]) {
    mode = _FBTweakTableViewCellModeAction;
  }
  
  [self _updateMode:mode];
  [self _updateValue:value primary:YES write:NO];
}

- (void)_updateMode:(_FBTweakTableViewCellMode)mode
{
  _mode = mode;

  self.accessoryView = _accessoryView;
  self.accessoryType = UITableViewCellAccessoryNone;
  self.detailTextLabel.text = nil;
  self.selectionStyle = UITableViewCellSelectionStyleNone;

  if (_mode == _FBTweakTableViewCellModeBoolean) {
    _switch.hidden = NO;
    _textField.hidden = YES;
    _stepper.hidden = YES;
  } else if (_mode == _FBTweakTableViewCellModeInteger) {
    _switch.hidden = YES;
    _textField.hidden = NO;
    _textField.keyboardType = UIKeyboardTypeNumberPad;
    _stepper.hidden = NO;
    if (_tweak.stepValue) {
      _stepper.stepValue = [_tweak.stepValue floatValue];
    } else {
      _stepper.stepValue = 1.0;
    }

    if (_tweak.minimumValue != nil) {
      _stepper.minimumValue = [_tweak.minimumValue longLongValue];
    } else {
      _stepper.minimumValue = [_tweak.defaultValue longLongValue] / 10.0;
    }

    if (_tweak.maximumValue != nil) {
      _stepper.maximumValue = [_tweak.maximumValue longLongValue];
    } else {
      _stepper.maximumValue = [_tweak.defaultValue longLongValue] * 10.0;
    }
  } else if (_mode == _FBTweakTableViewCellModeReal) {
    _switch.hidden = YES;
    _textField.hidden = NO;
    _textField.keyboardType = UIKeyboardTypeDecimalPad;
    _stepper.hidden = NO;
    
    if (_tweak.stepValue) {
      _stepper.stepValue = [_tweak.stepValue floatValue];
    } else {
      _stepper.stepValue = 1.0;
    }
    
    if (_tweak.minimumValue != nil) {
      _stepper.minimumValue = [_tweak.minimumValue doubleValue];
    } else if ([_tweak.defaultValue doubleValue] == 0) {
      _stepper.minimumValue = -1;
    } else {
      _stepper.minimumValue = [_tweak.defaultValue doubleValue] / 10.0;
    }
    
    if (_tweak.maximumValue != nil) {
      _stepper.maximumValue = [_tweak.maximumValue doubleValue];
    } else if ([_tweak.defaultValue doubleValue] == 0) {
      _stepper.maximumValue = 1;
    } else {
      _stepper.maximumValue = [_tweak.defaultValue doubleValue] * 10.0;
    }
    
    if (!_tweak.stepValue) {
      _stepper.stepValue = fminf(1.0, (_stepper.maximumValue - _stepper.minimumValue) / 100.0);
    }
  } else if (_mode == _FBTweakTableViewCellModeString) {
    _switch.hidden = YES;
    _textField.hidden = NO;
    _textField.keyboardType = UIKeyboardTypeDefault;
    _stepper.hidden = YES;
  } else if (_mode == _FBTweakTableViewCellModeAction) {
    _switch.hidden = YES;
    _textField.hidden = YES;
    _stepper.hidden = YES;
    
    self.accessoryView = nil;
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    self.selectionStyle = UITableViewCellSelectionStyleBlue;
  } else if (_mode == _FBTweakTableViewCellModeDictionary) {
    _switch.hidden = YES;
    _textField.hidden = YES;
    _stepper.hidden = YES;
    self.accessoryView = nil;
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    self.selectionStyle = UITableViewCellSelectionStyleBlue;
  } else if (_mode == _FBTweakTableViewCellModeArray) {
    _switch.hidden = YES;
    _textField.hidden = YES;
    _stepper.hidden = YES;
    self.accessoryView = nil;
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    self.selectionStyle = UITableViewCellSelectionStyleBlue;
  } else if (_mode == _FBTweakTableViewCellModeColor) {
    _switch.hidden = YES;
    _textField.hidden = YES;
    _stepper.hidden = YES;
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    self.accessoryView = nil;
    self.imageView.hidden = NO;
  } else {
    _switch.hidden = YES;
    _textField.hidden = YES;
    _stepper.hidden = YES;
  }
  
  [self setNeedsLayout];
  [self layoutIfNeeded];
}

#pragma mark - Actions

- (void)_switchChanged:(UISwitch *)switch_
{
  [self _updateValue:@(_switch.on) primary:NO write:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
  [_textField resignFirstResponder];
  return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
  if (_mode == _FBTweakTableViewCellModeString || _mode == _FBTweakTableViewCellModeColor) {
    [self _updateValue:_textField.text primary:NO write:YES];
  } else if (_mode == _FBTweakTableViewCellModeInteger) {
    NSNumber *number = @([_textField.text longLongValue]);
    [self _updateValue:number primary:NO write:YES];
  } else if (_mode == _FBTweakTableViewCellModeReal) {
    NSNumber *number = @([_textField.text doubleValue]);
    [self _updateValue:number primary:NO write:YES];
  } else {
    NSAssert(NO, @"unexpected type");
  }
}

- (void)_stepperChanged:(UIStepper *)stepper
{
  if (_mode == _FBTweakTableViewCellModeInteger) {
    NSNumber *number = @([@(stepper.value) longLongValue]);
    [self _updateValue:number primary:NO write:YES];
  } else {
    [self _updateValue:@(stepper.value) primary:NO write:YES];
  }
}

- (void)_updateValue:(FBTweakValue)value primary:(BOOL)primary write:(BOOL)write
{
  if (write) {
    _tweak.currentValue = value;
  }
  
  if (_mode == _FBTweakTableViewCellModeBoolean) {
    if (primary) {
      _switch.on = [value boolValue];
    }
  } else if (_mode == _FBTweakTableViewCellModeString) {
    if (primary) {
      _textField.text = value;
    }
  } else if (_mode == _FBTweakTableViewCellModeInteger) {
    if (primary) {
      _stepper.value = [value longLongValue];
    }
    _textField.text = [value stringValue];
  } else if (_mode == _FBTweakTableViewCellModeReal) {
    if (primary) {
      _stepper.value = [value doubleValue];
    }
    
    double exp = log10(_stepper.stepValue);
    long precision = exp < 0 ? ceilf(fabs(exp)) : 0;
    
    if (_tweak.precisionValue) {
      precision = [[_tweak precisionValue] longValue];
    }
    
    NSString *format = [NSString stringWithFormat:@"%%.%ldf", precision];
    _textField.text = [NSString stringWithFormat:format, [value doubleValue]];
  } else if (_mode == _FBTweakTableViewCellModeDictionary) {
    if (primary) {
      self.detailTextLabel.text = _tweak.possibleValues[value];
    }
  } else if (_mode == _FBTweakTableViewCellModeArray) {
    if (primary) {
      self.detailTextLabel.text = [value description];
    }
  } else if (_mode == _FBTweakTableViewCellModeColor) {
    [self.imageView setImage:_FBCreateColorCellsThumbnail(value, CGSizeMake(30, 30))];
  }
}

@end
