/**
 Copyright (c) 2014-present, Facebook, Inc.
 All rights reserved.
 
 This source code is licensed under the BSD-style license found in the
 LICENSE file in the root directory of this source tree. An additional grant
 of patent rights can be found in the PATENTS file in the same directory.
 */

#import "_FBTweakDictionaryViewController.h"
#import "FBTweak.h"

@interface _FBTweakDictionaryViewController () <UITableViewDataSource, UITableViewDelegate>

@end

@implementation _FBTweakDictionaryViewController {
  UITableView *_tableView;
}

- (instancetype)initWithTweak:(FBTweak *)tweak
{
  NSParameterAssert(tweak != nil);
  NSParameterAssert([tweak.possibleValues isKindOfClass:[NSDictionary class]]);

  if ((self = [super init])) {
    _tweak = tweak;
    self.title = _tweak.name;
  }

  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
  _tableView.delegate = self;
  _tableView.dataSource = self;
  _tableView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
  [self.view addSubview:_tableView];
}

- (void)dealloc
{
  _tableView.delegate = nil;
  _tableView.dataSource = nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return [_tweak.possibleValues count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *_FBTweakDictionaryViewControllerCellIdentifier = @"_FBTweakDictionaryViewControllerCellIdentifier";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:_FBTweakDictionaryViewControllerCellIdentifier];
  if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:_FBTweakDictionaryViewControllerCellIdentifier];
  }
  
  NSArray *allKeys = [self allTweakKeys];
  FBTweakValue key = allKeys[indexPath.row];
  NSString *value = _tweak.possibleValues[key];
  cell.textLabel.text = value;
  
  cell.accessoryType = UITableViewCellAccessoryNone;
  NSString *selectedKey = (_tweak.currentValue ?: _tweak.defaultValue);
  if ([selectedKey isEqual:key]) {
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
  }
  
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  NSArray *allKeys = [self allTweakKeys];
  NSString *key = allKeys[indexPath.row];
  
  self.tweak.currentValue = key;
  [self.navigationController popViewControllerAnimated:YES];
}

- (NSArray *)allTweakKeys
{
  // Sort by visible name.
  return [[_tweak.possibleValues allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
    id value1 = _tweak.possibleValues[obj1];
    id value2 = _tweak.possibleValues[obj2];
    return [value1 compare:value2];
  }];
}

@end