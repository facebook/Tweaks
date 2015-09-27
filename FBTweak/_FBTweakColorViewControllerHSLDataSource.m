//
//  _FBTweakColorViewControllerHSLDataSource.m
//  FBTweak
//
//  Created by Alireza Arabi on 9/26/15.
//  Copyright © 2015 Facebook. All rights reserved.
//

#import "_FBTweakColorViewControllerHSLDataSource.h"
#import "_FBColorComponentCell.h"
#import "_FBColorUtils.h"

@interface _FBTweakColorViewControllerHSLDataSource () <_FBColorComponentCellDelegate>

@end

@implementation _FBTweakColorViewControllerHSLDataSource {
  NSArray *_titles;
  NSArray *_maxValues;
  HSL _hslColorComponents;
  RGB _rgbColorComponents;
  NSArray *_colorComponentCells;
  UITableViewCell *_colorSampleCell;
}

- (instancetype)init
{
  if (self = [super init]) {
    _titles = @[@"H", @"S", @"L", @"A"];
    _maxValues = @[
                   @(_FBHSLColorComponentMaxValue),
                   @(_FBHSLColorComponentMaxValue),
                   @(_FBHSLColorComponentMaxValue),
                   @(_FBAlphaComponentMaxValue),
                   ];
    [self _createCells];
  }
  return self;
}

- (void)setValue:(UIColor *)value
{
  _hslColorComponents = _FBRGB2HSL(_FBRGBColorComponents(value));
  _rgbColorComponents = _FBHSL2RGB(_hslColorComponents);
  [self _reloadData];
}

- (UIColor *)value
{
  return [UIColor colorWithRed:_rgbColorComponents.red / 255.0 green:_rgbColorComponents.green / 255.0 blue:_rgbColorComponents.blue / 255.0 alpha:_rgbColorComponents.alpha];
}

#pragma mark - _FBColorComponentCellDelegate

- (void)colorComponentCell:(_FBColorComponentCell *)cell didChangeValue:(CGFloat)value
{
  [self _setValue:value forColorComponent:[_colorComponentCells indexOfObject:cell]];
  [self _reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  if (section == 0) {
    return 1;
  }
  return _colorComponentCells.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (indexPath.section == 0) {
    return _colorSampleCell;
  }
  return _colorComponentCells[indexPath.row];
}

#pragma mark - Private methods

- (void)_reloadData
{
  NSArray *components = [self _colorComponentsWithHSL:_hslColorComponents];

  _rgbColorComponents = _FBHSL2RGB(_hslColorComponents);
  _colorSampleCell.backgroundColor = [UIColor colorWithRed:_rgbColorComponents.red/255.0 green:_rgbColorComponents.green/255.0 blue:_rgbColorComponents.blue/255.0 alpha:_rgbColorComponents.alpha];

  for (int i = 0; i < _FBHSBAColorComponentsSize; ++i) {
    _FBColorComponentCell *cell = _colorComponentCells[i];
    
    NSArray *colorArray = [self colorsForMask:_hslColorComponents forColorComponent:i];
    UIColor *firstColor = [colorArray firstObject];
    UIColor *secondColor = [colorArray lastObject];
    cell.colors = @[(id)firstColor.CGColor, (id)secondColor.CGColor];

    cell.value = [components[i] floatValue] * (i == _FBHSBAColorComponentsSize - 1 ? [_maxValues[i] floatValue] : 1);
  }
}

- (void)_createCells
{
  NSArray *components = [self _colorComponentsWithHSL:_hslColorComponents];

  NSMutableArray *tmp = [NSMutableArray array];
  for (int i = 0; i < _FBHSBAColorComponentsSize; ++i) {
    _FBColorComponentCell *cell = [[_FBColorComponentCell alloc] init];
    
    NSArray *colorArray = [self colorsForMask:_hslColorComponents forColorComponent:i];
    UIColor *firstColor = [colorArray firstObject];
    UIColor *secondColor = [colorArray lastObject];
    cell.colors = @[(id)firstColor.CGColor, (id)secondColor.CGColor];
    
    cell.format = i == _FBHSBAColorComponentsSize - 1 ? @"%.f" : @"%.2f";
    cell.value = [components[i] floatValue] * (i == _FBHSBAColorComponentsSize - 1 ? [_maxValues[i] floatValue] : 1);
    cell.title = _titles[i];
    cell.maximumValue = [_maxValues[i] floatValue];
    cell.delegate = self;
    [tmp addObject:cell];
  }
  _colorComponentCells = [tmp copy];
  
  _colorSampleCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
  _colorSampleCell.backgroundColor = self.value;
}

- (void)_setValue:(CGFloat)value forColorComponent:(_FBHSLColorComponent)colorComponent
{
  [self willChangeValueForKey:NSStringFromSelector(@selector(value))];
  
  switch (colorComponent) {
    case _FBHSLColorComponentHue:
      _hslColorComponents.hue = value * 360;
      break;
    case _FBHSLColorComponentSaturation:
      _hslColorComponents.saturation = value * 100;
      break;
    case _FBHSLColorComponentLightness:
      _hslColorComponents.lightness = value * 100;
      break;
    case _FBHSLColorComponentAlpha:
      _hslColorComponents.alpha = value / _FBAlphaComponentMaxValue;
      break;
  }

  [self didChangeValueForKey:NSStringFromSelector(@selector(value))];
}

- (NSArray *)_colorComponentsWithHSL:(HSL)hsl
{
    return @[@(hsl.hue / 360.0), @(hsl.saturation / 100.0), @(hsl.lightness / 100.0), @(hsl.alpha)];
}

- (NSArray *)colorsForMask:(HSL)hslColor forColorComponent:(_FBHSLColorComponent)colorComponent
{
  RGB firstRGB, secondRGB;
  HSL firstHSL, secondHSL;
  
  switch (colorComponent) {
    case _FBHSLColorComponentHue:
      firstHSL = (HSL){.hue = 0, .saturation = hslColor.saturation, .lightness = hslColor.lightness, .alpha = hslColor.alpha};
      secondHSL = (HSL){.hue = 360, .saturation = hslColor.saturation, .lightness = hslColor.lightness, .alpha = hslColor.alpha};
      firstRGB = _FBHSL2RGB(firstHSL);
      secondRGB = _FBHSL2RGB(secondHSL);
      break;
    case _FBHSLColorComponentSaturation:
      firstHSL = (HSL){.hue = hslColor.hue, .saturation = 0, .lightness = hslColor.lightness, .alpha = hslColor.alpha};
      secondHSL = (HSL){.hue = hslColor.hue, .saturation = 100, .lightness = hslColor.lightness, .alpha = hslColor.alpha};
      firstRGB = _FBHSL2RGB(firstHSL);
      secondRGB = _FBHSL2RGB(secondHSL);
      break;
    case _FBHSLColorComponentLightness:
      firstHSL = (HSL){.hue = hslColor.hue, .saturation = hslColor.saturation, .lightness = 0, .alpha = hslColor.alpha};
      secondHSL = (HSL){.hue = hslColor.hue, .saturation = hslColor.saturation, .lightness = 100, .alpha = hslColor.alpha};
      firstRGB = _FBHSL2RGB(firstHSL);
      secondRGB = _FBHSL2RGB(secondHSL);
      break;
    case _FBHSLColorComponentAlpha:
      firstHSL = (HSL){.hue = hslColor.hue, .saturation = hslColor.saturation, .lightness = hslColor.lightness, .alpha = 0};
      secondHSL = (HSL){.hue = hslColor.hue, .saturation = hslColor.saturation, .lightness = hslColor.lightness, .alpha = 1};
      firstRGB = _FBHSL2RGB(firstHSL);
      secondRGB = _FBHSL2RGB(secondHSL);
      break;
  }
  
  UIColor *firstColor = [UIColor colorWithRed:firstRGB.red/255.0 green:firstRGB.green/255.0 blue:firstRGB.blue/255.0 alpha:firstRGB.alpha];
  UIColor *secondColor = [UIColor colorWithRed:secondRGB.red/255.0 green:secondRGB.green/255.0 blue:secondRGB.blue/255.0 alpha:secondRGB.alpha];
  
  return @[firstColor,secondColor];
}

@end
