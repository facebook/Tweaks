//
//  FBTweakViewController.m
//  FBTweak
//
//  Created by Andrew Pouliot on 5/22/15.
//  Copyright (c) 2015 Facebook. All rights reserved.
//

#import "FBTweakViewController.h"

#import <FBTweak/FBTweakCategory.h>
#import <FBTweak/FBTweak.h>
#import <FBTweak/FBTweakCollection.h>

#import "_FBTweakTableViewCell.h"

@interface FBTweakViewController () <NSOutlineViewDataSource, NSOutlineViewDelegate>

@end

@implementation FBTweakViewController {
  NSOutlineView *_outlineView;
  FBTweakStore *_store;

}

static NSWindow *_tweaksWindow;

+ (void)showTweaks
{
  FBTweakViewController *tc = [[FBTweakViewController alloc] initWithStore:[FBTweakStore sharedInstance]];

  if (!_tweaksWindow) {

    NSPanel *p = [[NSPanel alloc] initWithContentRect:tc.view.frame
                                            styleMask:NSTitledWindowMask | NSClosableWindowMask | NSResizableWindowMask | NSUtilityWindowMask | NSHUDWindowMask
                                              backing:NSBackingStoreBuffered
                                                defer:YES];

    p.appearance = [NSAppearance appearanceNamed:NSAppearanceNameVibrantDark];
    p.title = @"Tweaks";
    p.frameAutosaveName = @"FBTweak";
    p.contentViewController = tc;
    _tweaksWindow = p;
  }

  [_tweaksWindow makeKeyAndOrderFront:nil];
}

- (instancetype)initWithStore:(FBTweakStore *)store
{
  self = [self initWithNibName:nil bundle:nil];
  if (!self) return nil;

  _store = store;

  return self;
}

static NSOutlineView *makeOutlineView(NSScrollView *scroll) {
  NSOutlineView *olv = [[NSOutlineView alloc] initWithFrame:scroll.bounds];
  olv.rowHeight = 20;
  olv.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
  olv.headerView = nil;

  NSTableColumn *c = [[NSTableColumn alloc] initWithIdentifier:@"HAHA"];
  c.width = scroll.bounds.size.width;
  c.minWidth = 100;
  c.maxWidth = 1000000;
  c.resizingMask = NSTableColumnAutoresizingMask;
  [olv addTableColumn:c];

  olv.outlineTableColumn = olv.tableColumns[0];
  olv.columnAutoresizingStyle = NSTableViewUniformColumnAutoresizingStyle;
  olv.autoresizesOutlineColumn = YES;
  return olv;
}

- (void)loadView
{
  CGRect frame = CGRectMake(0, 0, 200, 500);

//  NSView *root = [[NSView alloc] initWithFrame:frame];
//  root.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
//  root.wantsLayer = YES;
//
//  root.appearance = [NSAppearance appearanceNamed:NSAppearanceNameVibrantDark];

  NSVisualEffectView *root = [[NSVisualEffectView alloc] initWithFrame:frame];
  root.blendingMode = NSVisualEffectBlendingModeBehindWindow;
  root.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
  root.wantsLayer = YES;

  NSScrollView *sv = [[NSScrollView alloc] initWithFrame:frame];
  sv.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;

  _outlineView = makeOutlineView(sv);
  _outlineView.dataSource = self;
  _outlineView.delegate = self;
  _outlineView.selectionHighlightStyle = NSTableViewSelectionHighlightStyleSourceList;

  sv.documentView = _outlineView;

  [_outlineView expandItem:nil expandChildren:YES];

  [root addSubview:sv];

  self.view = root;
}

#pragma mark - NSOutlineViewDelegate

static NSView *viewToDisplayText(NSString *string)
{
  CGRect initialFrame = CGRectMake(0, 0, 300, 20);
  NSTextField *tf = [[NSTextField alloc] initWithFrame:initialFrame];
  tf.textColor = [NSColor labelColor];
  tf.editable = NO;
  tf.backgroundColor = [NSColor clearColor];
  tf.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
  tf.bezeled = NO;
  tf.stringValue = string ?: @"?";
  tf.bordered = NO;
  return tf;
}

- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
  if ([item isKindOfClass:[FBTweakCategory class]]) {
    return viewToDisplayText([item name]);
  } else if ([item isKindOfClass:[FBTweakCollection class]]) {
    return viewToDisplayText([item name]);
  } else if ([item isKindOfClass:[FBTweak class]]) {
    return [_FBTweakTableViewCell cellWithTweak:item];
  } else {
    return nil;
  }
}

#pragma mark - NSOutlineViewDataSource

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
  if (!item) {
    return [_store tweakCategories].count;
  } else if ([item isKindOfClass:[FBTweakCategory class]]) {
    return ((FBTweakCategory *)item).tweakCollections.count;
  } else if ([item isKindOfClass:[FBTweakCollection class]]) {
    return ((FBTweakCollection *)item).tweaks.count;
  } else {
    return 0;
  }
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
  if (!item) {
    return [[_store tweakCategories] objectAtIndex:index];
  } else if ([item isKindOfClass:[FBTweakCategory class]]) {
    return [((FBTweakCategory *)item).tweakCollections objectAtIndex:index];
  } else if ([item isKindOfClass:[FBTweakCollection class]]) {
    return [((FBTweakCollection *)item).tweaks objectAtIndex:index];
  } else {
    return nil;
  }
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
  if (!item) {
    return YES;
  } else if ([item isKindOfClass:[FBTweakCategory class]]) {
    return YES;
  } else if ([item isKindOfClass:[FBTweakCollection class]]) {
    return YES;
  } else if ([item isKindOfClass:[FBTweak class]]) {
    return NO;
  } else {
    return NO;
  }
}

@end
