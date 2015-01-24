/**
 Copyright (c) 2014-present, Facebook, Inc.
 All rights reserved.
 
 This source code is licensed under the BSD-style license found in the
 LICENSE file in the root directory of this source tree. An additional grant
 of patent rights can be found in the PATENTS file in the same directory.
 */

#import "FBTweakCollection.h"
#import "FBTweakCategory.h"
#import "_FBTweakCollectionViewController.h"
#import "_FBTweakTableViewCell.h"
#import "FBTweak.h"

@interface _FBTweakCollectionViewController () <UITableViewDelegate, UITableViewDataSource>
@end

@implementation _FBTweakCollectionViewController {
  UITableView *_tableView;
  NSArray *_sortedCollections;
}

- (instancetype)initWithTweakCategory:(FBTweakCategory *)category
{
  if ((self = [super init])) {
    _tweakCategory = category;
    self.title = _tweakCategory.name;
    
    _sortedCollections = [_tweakCategory.tweakCollections sortedArrayUsingComparator:^(FBTweakCollection *a, FBTweakCollection *b) {
      return [a.name localizedStandardCompare:b.name];
    }];
  }
  
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_keyboardFrameChanged:) name:UIKeyboardWillChangeFrameNotification object:nil];
  
  _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
  _tableView.delegate = self;
  _tableView.dataSource = self;
  _tableView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
  [self.view addSubview:_tableView];
  
  self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(_done)];
}

- (void)dealloc
{
  _tableView.delegate = nil;
  _tableView.dataSource = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  
  [_tableView deselectRowAtIndexPath:_tableView.indexPathForSelectedRow animated:animated];
}

- (void)_done
{
  NSIndexPath *path = [_tableView indexPathForSelectedRow];
  
  _FBTweakTableViewCell *cell = (_FBTweakTableViewCell *)[_tableView cellForRowAtIndexPath:path];
  
  if (cell.tweak.isDictionaryTweak && cell.isSelected) {
    [_tableView deselectRowAtIndexPath:path animated:YES];
    [self tableView:_tableView didDeselectRowAtIndexPath:path];
    
    return;
  }
  
  NSArray *visibleCells = [_tableView visibleCells];
  
  for (_FBTweakTableViewCell *cell in visibleCells) {
    if (cell.isSelected && !cell.tweak.isDictionaryTweak) {
      [cell setSelected:NO];
      return;
    }
  }
  
  
  [_delegate tweakCollectionViewControllerSelectedDone:self];
  
}

- (void)_keyboardFrameChanged:(NSNotification *)notification
{
  CGRect endFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
  endFrame = [self.view.window convertRect:endFrame fromWindow:nil];
  endFrame = [self.view convertRect:endFrame fromView:self.view.window];
  
  NSTimeInterval duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
  UIViewAnimationCurve curve = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
  
  void (^animations)() = ^{
    UIEdgeInsets contentInset = _tableView.contentInset;
    contentInset.bottom = (self.view.bounds.size.height - CGRectGetMinY(endFrame));
    _tableView.contentInset = contentInset;
    
    UIEdgeInsets scrollIndicatorInsets = _tableView.scrollIndicatorInsets;
    scrollIndicatorInsets.bottom = (self.view.bounds.size.height - CGRectGetMinY(endFrame));
    _tableView.scrollIndicatorInsets = scrollIndicatorInsets;
  };
  
  UIViewAnimationOptions options = (curve << 16) | UIViewAnimationOptionBeginFromCurrentState;
  
  [UIView animateWithDuration:duration delay:0 options:options animations:animations completion:NULL];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return _sortedCollections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  FBTweakCollection *collection = _sortedCollections[section];
  return collection.tweaks.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
  FBTweakCollection *collection = _sortedCollections[section];
  return collection.name;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  FBTweakCollection *collection = _sortedCollections[indexPath.section];
  FBTweak *tweak = collection.tweaks[indexPath.row];
  
  if ([tweak isDictionaryTweak] && [[tableView indexPathForSelectedRow] isEqual:indexPath]) {
    return 216;
  } else {
    return [tableView rowHeight];
  }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  // Reload table view to change height.
  [tableView beginUpdates];
  [tableView endUpdates];
  
  UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
  [cell setSelected:YES];
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
  // Reload table view to change height.
  [tableView beginUpdates];
  [tableView endUpdates];
  
  UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
  [cell setSelected:NO];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *_FBTweakCollectionViewControllerCellIdentifier = @"_FBTweakCollectionViewControllerCellIdentifier";
  _FBTweakTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:_FBTweakCollectionViewControllerCellIdentifier];
  if (cell == nil) {
    cell = [[_FBTweakTableViewCell alloc] initWithReuseIdentifier:_FBTweakCollectionViewControllerCellIdentifier];
  }
  
  FBTweakCollection *collection = _sortedCollections[indexPath.section];
  FBTweak *tweak = collection.tweaks[indexPath.row];
  cell.tweak = tweak;
  
  return cell;
}

@end
