/**
 Copyright (c) 2014-present, Facebook, Inc.
 All rights reserved.

 This source code is licensed under the BSD-style license found in the
 LICENSE file in the root directory of this source tree. An additional grant
 of patent rights can be found in the PATENTS file in the same directory.
 */

#import "_FBColorUtils.h"

CGFloat const _FBRGBColorComponentMaxValue = 255.0f;
CGFloat const _FBAlphaComponentMaxValue = 100.0f;
CGFloat const _FBHSBColorComponentMaxValue = 1.0f;
CGFloat const _FBHSLColorComponentMaxValue = 1.0f;
NSUInteger const _FBRGBAColorComponentsSize = 4;
NSUInteger const _FBHSBAColorComponentsSize = 4;
NSUInteger const _FBHSLAColorComponentsSize = 4;

extern HSB _FBRGB2HSB(RGB rgb)
{
  double rd = (double) rgb.red;
  double gd = (double) rgb.green;
  double bd = (double) rgb.blue;
  double max = fmax(rd, fmax(gd, bd));
  double min = fmin(rd, fmin(gd, bd));
  double h = 0, s, b = max;

  double d = max - min;
  s = max == 0 ? 0 : d / max;

  if (max == min) {
    h = 0; // achromatic
  } else {
    if (max == rd) {
      h = (gd - bd) / d + (gd < bd ? 6 : 0);
    } else if (max == gd) {
      h = (bd - rd) / d + 2;
    } else if (max == bd) {
      h = (rd - gd) / d + 4;
    }
    h /= 6;
  }

  return (HSB){.hue = h, .saturation = s, .brightness = b, .alpha = rgb.alpha};
}

extern RGB _FBHSB2RGB(HSB hsb)
{
  double r, g, b;

  int i = hsb.hue * 6;
  double f = hsb.hue * 6 - i;
  double p = hsb.brightness * (1 - hsb.saturation);
  double q = hsb.brightness * (1 - f * hsb.saturation);
  double t = hsb.brightness * (1 - (1 - f) * hsb.saturation);

  switch(i % 6){
    case 0: r = hsb.brightness, g = t, b = p; break;
    case 1: r = q, g = hsb.brightness, b = p; break;
    case 2: r = p, g = hsb.brightness, b = t; break;
    case 3: r = p, g = q, b = hsb.brightness; break;
    case 4: r = t, g = p, b = hsb.brightness; break;
    case 5: r = hsb.brightness, g = p, b = q; break;
  }

  return (RGB){.red = r, .green = g, .blue = b, .alpha = hsb.alpha};
}

extern HSL _FBRGB2HSL(RGB rgb)
{
  double r_percent = rgb.red;
  double g_percent = rgb.green;
  double b_percent = rgb.blue;
  
  double max_color = 0;
  if((r_percent >= g_percent) && (r_percent >= b_percent))
    max_color = r_percent;
  if((g_percent >= r_percent) && (g_percent >= b_percent))
    max_color = g_percent;
  if((b_percent >= r_percent) && (b_percent >= g_percent))
    max_color = b_percent;
  
  double min_color = 0;
  if((r_percent <= g_percent) && (r_percent <= b_percent))
    min_color = r_percent;
  if((g_percent <= r_percent) && (g_percent <= b_percent))
    min_color = g_percent;
  if((b_percent <= r_percent) && (b_percent <= g_percent))
    min_color = b_percent;
  
  double L = 0;
  double S = 0;
  double H = 0;
  
  L = (max_color + min_color)/2;
  
  if(max_color == min_color)
  {
    S = 0;
    H = 0;
  }
  else
  {
    if(L < .50)
      S = (max_color - min_color)/(max_color + min_color);
    else
      S = (max_color - min_color)/(2 - max_color - min_color);
    if(max_color == r_percent)
      H = (g_percent - b_percent)/(max_color - min_color);
    if(max_color == g_percent)
      H = 2 + (b_percent - r_percent)/(max_color - min_color);
    if(max_color == b_percent)
      H = 4 + (r_percent - g_percent)/(max_color - min_color);
  }
  S = (uint)(S*100);
  L = (uint)(L*100);
  H = H*60;
  if(H < 0)
    H += 360;
  H = (uint)H;
  
  return (HSL){.hue = H, .saturation = S, .lightness = L, .alpha = rgb.alpha};
}

extern RGB _FBHSL2RGB(HSL hsl)
{
  double v;
  double r,g,b;
  
  double h = hsl.hue / 360.0;
  double sl = hsl.saturation / 100.0;
  double l = hsl.lightness / 100.0;
  
  r = hsl.lightness;
  g = hsl.lightness;
  b = hsl.lightness;
  v = (l <= 0.5) ? (l * (1.0 + sl)) : (l + sl - l * sl);
  if (v > 0)
  {
    double m;
    double sv;
    int sextant;
    double fract, vsf, mid1, mid2;
    
    m = l + l - v;
    sv = (v - m ) / v;
    h *= 6.0;
    sextant = (int)h;
    fract = h - sextant;
    vsf = v * sv * fract;
    mid1 = m + vsf;
    mid2 = v - vsf;
    switch (sextant)
    {
      case 0: r = v; g = mid1; b = m; break;
      case 1: r = mid2; g = v; b = m; break;
      case 2: r = m; g = v; b = mid1; break;
      case 3: r = m; g = mid2; b = v; break;
      case 4: r = mid1; g = m; b = v; break;
      case 5: r = v; g = m; b = mid2; break;
    }
  }
  
  return (RGB){.red = (r * 255.0f), .green = (g * 255.0f), .blue = (b * 255.0f), .alpha = hsl.alpha};
}
extern RGB _FBRGBColorComponents(UIColor *color)
{
  RGB result;
  CGColorSpaceModel colorSpaceModel = CGColorSpaceGetModel(CGColorGetColorSpace(color.CGColor));
  if (colorSpaceModel != kCGColorSpaceModelRGB && colorSpaceModel != kCGColorSpaceModelMonochrome) {
    return result;
  }
  const CGFloat *components = CGColorGetComponents(color.CGColor);
  if (colorSpaceModel == kCGColorSpaceModelMonochrome) {
    result.red = result.green = result.blue = components[0];
    result.alpha = components[1];
  } else {
    result.red = components[0];
    result.green = components[1];
    result.blue = components[2];
    result.alpha = components[3];
  }
  return result;
}

extern CGFloat _FBGetColorWheelHue(CGPoint position, CGPoint center, CGFloat radius)
{
  CGFloat dx = (CGFloat)(position.x - center.x) / radius;
  CGFloat dy = (CGFloat)(position.y - center.y) / radius;
  CGFloat d = sqrtf(dx*dx + dy*dy);
  CGFloat hue = 0;
  if (d != 0) {
    hue = acosf(dx / d) / M_PI / 2.0f;
    if (dy < 0) {
      hue = 1.0 - hue;
    }
  }
  return hue;
}

extern CGFloat _FBGetColorWheelSaturation(CGPoint position, CGPoint center, CGFloat radius)
{
  CGFloat dx = (CGFloat)(position.x - center.x) / radius;
  CGFloat dy = (CGFloat)(position.y - center.y) / radius;
  return sqrtf(dx*dx + dy*dy);
}

extern CGImageRef _FBCreateColorWheelImage(CGFloat diameter)
{
  CFMutableDataRef bitmapData = CFDataCreateMutable(NULL, 0);
  CFDataSetLength(bitmapData, diameter * diameter * 4);
  UInt8 * bitmap = CFDataGetMutableBytePtr(bitmapData);
  for (int y = 0; y < diameter; y++) {
    for (int x = 0; x < diameter; x++) {
      CGFloat hue = _FBGetColorWheelHue(CGPointMake(x, y), (CGPoint){diameter / 2, diameter / 2}, diameter / 2);
      CGFloat saturation = _FBGetColorWheelSaturation(CGPointMake(x, y), (CGPoint){diameter / 2, diameter / 2}, diameter / 2);
      CGFloat a = 0.0f;
      RGB rgb = {0.0f, 0.0f, 0.0f, 0.0f};
      if (saturation < 1.0) {
        // Antialias the edge of the circle.
        if (saturation > 0.99) a = (1.0 - saturation) * 100;
        else a = 1.0;
        HSB hsb = {hue, saturation, 1.0f, a};
        rgb = _FBHSB2RGB(hsb);
      }

      int i = 4 * (x + y * diameter);
      bitmap[i] = rgb.red * 0xff;
      bitmap[i+1] = rgb.green * 0xff;
      bitmap[i+2] = rgb.blue * 0xff;
      bitmap[i+3] = rgb.alpha * 0xff;
    }
  }

  CGDataProviderRef dataProvider = CGDataProviderCreateWithCFData(bitmapData);
  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
  CGImageRef imageRef = CGImageCreate(diameter, diameter, 8, 32, diameter * 4, colorSpace, kCGBitmapByteOrderDefault | kCGImageAlphaLast, dataProvider, NULL, 0, kCGRenderingIntentDefault);
  CGDataProviderRelease(dataProvider);
  CGColorSpaceRelease(colorSpace);
  CFRelease(bitmapData);
  return imageRef;
}
