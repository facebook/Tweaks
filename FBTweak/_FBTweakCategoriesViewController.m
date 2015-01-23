//
//  _FBTweakCategoriesViewController.m
//  FBTweak
//
//  Created by Paulo Andrade on 13/12/14.
//  Copyright (c) 2014 Facebook. All rights reserved.
//

#import "_FBTweakCategoriesViewController.h"
#import "FBTweakStore.h"
#import "FBTweakCategory.h"

@interface _FBTweakCategoriesViewController () <NSOutlineViewDataSource, NSOutlineViewDelegate>


@property (nonatomic, weak) NSOutlineView *outlineView;

@end

@implementation _FBTweakCategoriesViewController {
    NSArray *_sortedCategories;
}

- (instancetype)initWithStore:(FBTweakStore *)store
{
    self = [super initWithNibName:@"" bundle:nil];
    if (self) {
        _sortedCategories = [store.tweakCategories sortedArrayUsingComparator:^(FBTweakCategory *a, FBTweakCategory *b) {
            return [a.name localizedStandardCompare:b.name];
        }];
    }
    return self;
}

- (void)loadView
{
    NSView *view = [[NSView alloc] initWithFrame:CGRectMake(0, 0, 300, 500)];
    
    NSScrollView *scrollView = [[NSScrollView alloc] initWithFrame:view.bounds];
    scrollView.autoresizingMask = NSViewWidthSizable|NSViewHeightSizable;
    
    NSOutlineView *outlineView = [[NSOutlineView alloc] initWithFrame:scrollView.bounds];
    outlineView.autoresizingMask = NSViewWidthSizable|NSViewHeightSizable;
    outlineView.translatesAutoresizingMaskIntoConstraints = NO;
    outlineView.dataSource = self;
    outlineView.delegate = self;
    outlineView.allowsEmptySelection = NO;
    outlineView.allowsMultipleSelection = NO;
    outlineView.selectionHighlightStyle = NSTableViewSelectionHighlightStyleSourceList;
    
    NSTableColumn *column = [[NSTableColumn alloc] initWithIdentifier:@"Categories"];
    column.title = @"Categories";
    column.width = CGRectGetWidth(view.frame);
    column.editable = NO;
    [outlineView addTableColumn:column];
    
    scrollView.documentView = outlineView;
    scrollView.autoresizesSubviews = YES;
    
    [view addSubview:scrollView];

    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[outlineView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(outlineView)]];
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[outlineView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(outlineView)]];
    
    self.outlineView = outlineView;
    
    self.view = view;
}


- (FBTweakCategory *)selectedCategory
{
    if ([self.outlineView selectedRow] >= 0) {
        return _sortedCategories[[self.outlineView selectedRow]];
    }
    return nil;
}

- (void)viewDidAppear
{
    [super viewDidAppear];
    [self.outlineView reloadData];
}

#pragma mark - NSOutlineView

#pragma mark datasource

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
    return (item == nil) ? [_sortedCategories count] : 0;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
    return _sortedCategories[index];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
    return NO;
}


#pragma mark delegate

- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(FBTweakCategory *)category
{
    NSTableCellView *cellView = [[NSTableCellView alloc] initWithFrame:CGRectMake(0, 0, 100, 50)];
    NSTextField *textField = [[NSTextField alloc] initWithFrame:cellView.bounds];
    textField.autoresizingMask = NSViewWidthSizable|NSViewHeightSizable;
    textField.stringValue = category.name;
    textField.bordered = NO;
    textField.drawsBackground = NO;
    textField.focusRingType = NSFocusRingTypeNone;
    [cellView addSubview:textField];
    cellView.textField = textField;
    return cellView;
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification
{
    [self.delegate categoriesViewController:self didChangeSelection:[self selectedCategory]];
}

@end
