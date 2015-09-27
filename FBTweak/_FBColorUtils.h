/**
 Copyright (c) 2014-present, Facebook, Inc.
 All rights reserved.

 This source code is licensed under the BSD-style license found in the
 LICENSE file in the root directory of this source tree. An additional grant
 of patent rights can be found in the PATENTS file in the same directory.
 */

#import <UIKit/UIKit.h>

typedef struct { CGFloat red, green, blue, alpha; } RGB;
typedef struct { CGFloat hue, saturation, brightness, alpha; } HSB;
typedef struct { CGFloat hue, saturation, lightness, alpha; } HSL;

extern CGFloat const _FBRGBColorComponentMaxValue;
extern CGFloat const _FBAlphaComponentMaxValue;
extern CGFloat const _FBHSBColorComponentMaxValue;
extern CGFloat const _FBHSLColorComponentMaxValue;
extern NSUInteger const _FBRGBAColorComponentsSize;
extern NSUInteger const _FBHSBAColorComponentsSize;
extern NSUInteger const _FBHSLAColorComponentsSize;

typedef NS_ENUM(NSUInteger, _FBRGBColorComponent) {
  _FBRGBColorComponentRed,
  _FBRGBColorComponentGreed,
  _FBRGBColorComponentBlue,
  _FBRGBColorComponentAlpha,
};

typedef NS_ENUM(NSUInteger, _FBHSBColorComponent) {
  _FBHSBColorComponentHue,
  _FBHSBColorComponentSaturation,
  _FBHSBColorComponentBrightness,
  _FBHSBColorComponentAlpha,
};

typedef NS_ENUM(NSUInteger, _FBHSLColorComponent) {
  _FBHSLColorComponentHue,
  _FBHSLColorComponentSaturation,
  _FBHSLColorComponentLightness,
  _FBHSLColorComponentAlpha,
};

/**
  @abstract Converts an RGB color value to HSV.
  @discussion Assumes r, g, and b are contained in the set
      [0, 1] and returns h, s, and b in the set [0, 1].
  @param rgb   The rgb color values
  @return The hsb color values
 */
extern HSB _FBRGB2HSB(RGB rgb);

/**
  @abstract Converts an HSB color value to RGB.
  @discussion Assumes h, s, and b are contained in the set
      [0, 1] and returns r, g, and b in the set [0, 255].
  @param hsb The hsb color values
  @return The rgb color values
 */
extern RGB _FBHSB2RGB(HSB hsb);

/**
 @abstract Converts an RGB color value to HSL.
 @discussion Assumes r, g, and b are contained in the set
 [0, 1] and returns h, s, and l in its own range.
 @param rgb   The rgb color values
 @return The hsl color values
 */
extern HSL _FBRGB2HSL(RGB rgb);

/**
 @abstract Converts an HSL color value to RGB.
 @discussion Assumes h, s, and l are contained in its own range
 and returns r, g, and b in the set [0, 255].
 @param hsl The hsl color values
 @return The rgb color values
 */
extern RGB _FBHSL2RGB(HSL hsl);
  @abstract Returns the rgb values of the color components.
  @param color The color value.
  @return The values of the color components (including alpha).
 */
extern RGB _FBRGBColorComponents(UIColor *color);

/**
  @abstract Returns the color wheel's hue value according to the position, color wheel's center and radius.
  @param position The position in the color wheel.
  @param center The color wheel's center.
  @param radius The color wheel's radius.
  @return The hue value.
 */
extern CGFloat _FBGetColorWheelHue(CGPoint position, CGPoint center, CGFloat radius);

/**
  @abstract Returns the color wheel's saturation value according to the position, color wheel's center and radius.
  @param position The position in the color wheel.
  @param center The color wheel's center.
  @param radius The color wheel's radius.
  @return The saturation value.
 */
extern CGFloat _FBGetColorWheelSaturation(CGPoint position, CGPoint center, CGFloat radius);

/**
  @abstract Creates the color wheel with specified diameter.
  @param diameter The color wheel's diameter.
  @return The color wheel image.
 */
extern CGImageRef _FBCreateColorWheelImage(CGFloat diameter);
