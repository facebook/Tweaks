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
    UIEdgeInsets contentInset = self->_tableView.contentInset;
    contentInset.bottom = (self.view.bounds.size.height - CGRectGetMinY(endFrame));
    self->_tableView.contentInset = contentInset;
    
    UIEdgeInsets scrollIndicatorInsets = self->_tableView.scrollIndicatorInsets;
    scrollIndicatorInsets.bottom = (self.view.bounds.size.height - CGRectGetMinY(endFrame));
    self->_tableView.scrollIndicatorInsets = scrollIndicatorInsets;
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
