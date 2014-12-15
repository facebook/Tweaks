//
//  FBTweaksEditorViewController.m
//  FBTweak
//
//  Created by Paulo Andrade on 13/12/14.
//  Copyright (c) 2014 Facebook. All rights reserved.
//

#import "FBTweakEditorViewController.h"
#import "_FBTweakCategoriesViewController.h"
#import "_FBTweakListViewController.h"

@interface FBTweakEditorViewController () <_FBTweakCategoriesViewControllerDelegate>

@property (nonatomic, strong) NSSplitViewController *splitViewController;

@property (nonatomic, strong) NSSplitViewItem *categoriesSplitViewItem;
@property (nonatomic, strong) _FBTweakCategoriesViewController *categoriesViewController;

@property (nonatomic, strong) NSSplitViewItem *listSplitViewItem;
@property (nonatomic, strong) _FBTweakListViewController *listViewController;



@end

@implementation FBTweakEditorViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Tweaks";
    }
    return self;
}

- (void)loadView
{
    NSView *view = [[NSView alloc] initWithFrame:CGRectMake(0, 0, 640, 480)];
    
    _FBTweakCategoriesViewController *categories = [[_FBTweakCategoriesViewController alloc] initWithStore:[FBTweakStore sharedInstance]];
    categories.delegate = self;
    _FBTweakListViewController *list = [[_FBTweakListViewController alloc] init];
    
    NSSplitViewController *splitViewController = [[NSSplitViewController alloc] init];
    
    // Categories
    NSSplitViewItem *splitItem = [NSSplitViewItem splitViewItemWithViewController:categories];
    NSView *splitItemView = [categories view];
    splitItemView.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:splitItemView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:150];
    width.priority = NSLayoutPriorityDefaultLow;
    width.active = YES;
    splitItem.holdingPriority = NSLayoutPriorityDefaultLow+1;
    splitItem.collapsed = NO;
    splitItem.canCollapse = NO;
    [splitViewController addSplitViewItem:splitItem];
    self.categoriesSplitViewItem = splitItem;

    // Collections
    splitItem = [NSSplitViewItem splitViewItemWithViewController:list];
    splitItemView = [list view];
    splitItemView.translatesAutoresizingMaskIntoConstraints = NO;
    width = [NSLayoutConstraint constraintWithItem:splitItemView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:330];
    width.priority = NSLayoutPriorityDefaultLow;
    width.active = YES;
    splitItem.holdingPriority = NSLayoutPriorityDefaultLow;
    splitItem.collapsed = NO;
    splitItem.canCollapse = NO;
    
    [splitViewController addSplitViewItem:splitItem];
    self.listSplitViewItem = splitItem;
    
    NSView *splitView = [splitViewController view];
    splitView.frame = view.bounds;
    splitView.autoresizingMask = NSViewWidthSizable|NSViewHeightSizable;
    [view addSubview:splitView];
    
    self.categoriesViewController = categories;
    self.listViewController = list;
    self.splitViewController = splitViewController;
    
    [self addChildViewController:self.splitViewController];
    
    self.view = view;
}

- (void)viewWillAppear
{
    [super viewWillAppear];
    self.listViewController.tweakCategory = [self.categoriesViewController selectedCategory];
}

#pragma mark - Delegates

#pragma mark _FBTweakCategoriesViewControllerDelegate

- (void)categoriesViewController:(_FBTweakCategoriesViewController *)controller didChangeSelection:(FBTweakCategory *)category
{
    self.listViewController.tweakCategory = category;
}

@end
