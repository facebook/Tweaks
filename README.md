# Tweaks
Tweaks is an easy way to fine-tune an iOS app.
[![Build Status](https://travis-ci.org/facebook/Tweaks.svg?branch=master)](https://travis-ci.org/facebook/Tweaks)

![Tweaks](https://github.com/facebook/Tweaks/blob/master/Images/Tweaks.gif?raw=true)

## Why
The best way to improve an app is to use it every day. Even when ideas can be tested out in advance — for example, with [Origami](http://origami.facebook.com) — it can still take some time with the app to see how it works in practice.

Occasionally, it's perfect the first try. Sometimes, the idea doesn't work at all. But often, it just needs a few minor adjustments. That last case is where Tweaks fits in. Tweaks makes those small adjustments easy: with no code changes and no computer, you can try out different options and decide which works best.

Some of the most useful parameters to adjust are animation timings, velocity thresholds, colors, and physics constants. At Facebook, we also use tweaks to temporarily disable new features during development. That way, the designers and engineers involved can enable it on just their devices, without getting in the way of others testing the app.

Tweaks was invaluable for building [Paper](http://www.facebook.com/paper). We hope it can be useful for your app too.

## Usage
Each configurable value is called a tweak. There's a few ways to set them up, found in `FBTweakInline.h`.

### Value
The simplest way to create a tweak is to replace a constant with `FBTweakValue`:

```objective-c
CGFloat animationDuration = FBTweakValue(@"Category", @"Group", @"Duration", 0.5);
```

The first three parameters are where the tweak is listed and what it's called, and the last one is the default value. You can pass in many types of values for the default: booleans, numbers, or strings.

```objective-c
if (FBTweakValue(@"Category", @"Feature", @"Enabled", YES)) {
  label.text = FBTweakValue(@"Category", @"Group", @"Text", @"Tweaks example.");
}
```

In release builds, the `FBTweakValue` macro expands to just the default value, so there's no performance impact. In debug builds, though, it fetches the latest value of the tweak.

You can also pass a fifth parameter, which will constrain the possible values for a tweak. The fifth parameter can be an array, dictionary, or an `FBTweakNumericRange`. If it's a dictionary, the values should be strings to show in the list of choices. Arrays will show the values' `description` as choices. (Note that you have to surround array and dictionary literals with an extra set of parentheses.)

```objective-c
self.initialMode = FBTweakValue(@"Header", @"Initial", @"Mode", @(FBSimpleMode), (@{ @(FBSimpleMode) : @"Simple", @(FBAdvancedMode) : @"Advanced" }));
```

For numeric tweaks (`NSInteger`, `CGFloat`, and others), you can instead pass two parameters, which constrain the value to a `FBTweakNumericRange`:

```objective-c
self.red = FBTweakValue(@"Header", @"Colors", @"Red", 0.5, 0.0, 1.0);
```

### Bind
To make tweaks update live, you can use `FBTweakBind`:

```objective-c
FBTweakBind(self.headerView, alpha, @"Main Screen", @"Header", @"Alpha", 0.85);
```

The first parameter is the object to bind to, and the second is the property. Whenever the tweak is changed, `self.headerView`'s `alpha` property is updated to match. A few more examples:

```objective-c
FBTweakBind(audioPlayer, volume, @"Player", @"Audio", @"Volume", 0.9);
FBTweakBind(webView.scrollView, scrollEnabled, @"Browser", @"Scrolling", @"Enabled", YES);
```

As with `FBTweakValue`, in release builds `FBTweakBind` expands to just setting the property to the default value.

## Action
Actions let you run a (global) block when a tweak is selected. To make one, use `FBTweakAction`:

```objective-c
FBTweakAction(@"Player", @"Audio", @"Volume", ^{
  NSLog(@"Action selected.");
});
```

The first three parameters are the standard tweak listing information, and the last is a block to call. You can use `FBTweakAction` in any scope, but the block must be global: it can't depend on any local or instance variables (it wouldn't know which object to adjust).

Actions are useful for things like launching debug UIs, checking for updates, or (if you make one that intentionally crashes) testing crash reporting.

### Tweaks UI
To configure your tweaks, you need a way to show the configuration UI. There's two options for that:

 - Traditionally, tweaks is activated by shaking your phone. To use that, just replace your root `UIWindow` with a `FBTweakShakeWindow`. If you're using Storyboards, you can override `-window` on your app delegate:

```objective-c
- (UIWindow *)window
{
  if (!_window) {
    _window = [[FBTweakShakeWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  }

  return _window;
}
```

 - You can present a `FBTweakViewController` from anywhere in your app. Be sure to restrict the activation UI to debug builds!
 
#### Tweaks UI Dismiss Notification

Alternatively, when the Tweaks UI is dismissed, you can register your notification center to listen to `FBTweakShakeViewControllerDidDismissNotification`, which can be used after importing `FBTweakViewController.h` 

### Advanced
You can also access the objects that make up the macros mentioned above. That can be useful for more complex scenarios, like adjusting members of a C structure.

For example, to manually create a tweak:

```objective-c
FBTweak *tweak = [[FBTweak alloc] initWithIdentifier:@"com.tweaks.example.advanced"];
tweak.name = @"Advanced Settings";
tweak.defaultValue = @NO;

FBTweakStore *store = [FBTweakStore sharedInstance];
FBTweakCategory *category = [[FBTweakCategory alloc] initWithName:@"Settings"];
[store addTweakCategory:category];
FBTweakCollection *collection = [[FBTweakCollection alloc] initWithName:@"Enable"];
[category addTweakCollection:collection];
[collection addTweak:tweak];

[tweak addObserver:self];
```

Then, you can watch for when the tweak changes:

```objective-c
- (void)tweakDidChange:(FBTweak *)tweak
{
  self.advancedSettingsEnabled = ![tweak.currentValue boolValue];
}
```

Also you have de ability to implement the optional method `tweakWillChange:` in order to handle the previous value of your tweak:

```objective-c
- (void)tweakWillChange:(FBTweak *)tweak
{
  NSLog(@"%@", tweak.currentValue); // Here current value is the previous value of the tweak
}
```

To override when tweaks are enabled, you can define the `FB_TWEAK_ENABLED` macro. It's suggested to avoid including them when submitting to the App Store.

### Using from a Swift Project

*Khan Academy's project [SwiftTweaks](http://engineering.khanacademy.org/posts/introducing-swifttweaks.htm) is designed for Swift, and might be a better choice for Swift projects.*

Tweaks can be used from Swift projects. In this case the handy shortcut macros defined in `FBTweakInline.h` are not available, meaning tweaks need to be created programmatically, similar to this example:

```swift
let tweak = FBTweak(identifier: "com.tweaks.example.advanced")
tweak.name = "Advanced settings"
tweak.defaultValue = false

let collection = FBTweakCollection(name: "Enable");
collection.addTweak(tweak)
        
let category = FBTweakCategory(name: "Settings")
category.addTweakCollection(collection);
        
let store = FBTweakStore.sharedInstance()
store.addTweakCategory(category)

tweak.addObserver(self)
```

After setting up a tweak you can watch for when it changes:

```swift
func tweakDidChange(tweak: FBTweak!)
{
    self.advancedSettingsEnabled = tweak.currentValue as Bool;
}
```

### How it works
In debug builds, the tweak macros use `__attribute__((section))` to statically store data about each tweak in the `__FBTweak` section of the mach-o. Tweaks loads that data at startup and loads the latest values from `NSUserDefaults`.

In release builds, the macros just expand to the default value. Nothing extra is included in the binary.

## Installation
There are two options:

 1. Tweaks is available as `Tweaks` in [CocoaPods](http://cocoapods.org). (If you have issues with custom Xcode configurations, [this comment](https://github.com/facebook/Tweaks/issues/4#issuecomment-40629741) might help.)
 2. Manually add the files from `FBTweak/` into your Xcode project. Slightly simpler, but updates are also manual.

Tweaks requires iOS 6 or later.

There's also a demo project available. To use it, make sure to open `FBTweakExample.xcworkspace` (rather than the `.xcodeproj`) so the dependencies build correctly.

## Contributing
See the CONTRIBUTING file for how to help out.

## License
Tweaks is BSD-licensed. We also provide an additional patent grant.
