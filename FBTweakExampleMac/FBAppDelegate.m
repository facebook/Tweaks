//
//  AppDelegate.m
//  FBTweakExampleMac
//
//  Created by Andrew Pouliot on 5/22/15.
//  Copyright (c) 2015 Facebook. All rights reserved.
//

#import "FBAppDelegate.h"

#import <FBTweak/FBTweakInline.h>
#import <FBTweak/FBTweakViewController.h>

#if !FB_TWEAK_ENABLED
#warning Probably not interesting.
#endif

@interface FBAppDelegate () <FBTweakObserver>

@property (weak) IBOutlet NSWindow *window;

@property (weak) IBOutlet NSView *redView;

@end

@implementation FBAppDelegate {
  NSWindow *_tweaksWindow;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
  [self _refresh];

  for (FBTweakCategory *c in [FBTweakStore sharedInstance].tweakCategories) {
    for (FBTweakCollection *cc in c.tweakCollections) {
      for (FBTweak *t in cc.tweaks) {
        [t addObserver:self];
      }
    }
  }
}


- (void)tweakDidChange:(FBTweak *)tweak
{
  [self _refresh];
}

- (void)_refresh
{
  NSView *contentView = self.window.contentView;
  contentView.wantsLayer = YES;

  CGFloat brightness = FBTweakValue(@"Category", @"Collection", @"Brightness", 0.0, 0.0, 1.0);
  CGFloat alpha = FBTweakValue(@"Category", @"Collection", @"Alpha", 0.0, (@[@0.2, @1.0]));
  CGFloat red = FBTweakValue(@"Category", @"Red", @"Color", 1.0, (@{@1.0 : @"Bright", @0.2 : @"Dim"}));

  self.redView.layer.backgroundColor = [NSColor colorWithRed:red green:0 blue:0 alpha:1].CGColor;

  contentView.layer.backgroundColor = [NSColor colorWithWhite:brightness alpha:alpha].CGColor;
}


- (IBAction)showTweaks:(id)sender
{
  [FBTweakViewController showTweaks];
}


@end
