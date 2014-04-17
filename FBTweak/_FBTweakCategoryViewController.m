/**
 Copyright (c) 2014-present, Facebook, Inc.
 All rights reserved.
 
 This source code is licensed under the BSD-style license found in the
 LICENSE file in the root directory of this source tree. An additional grant
 of patent rights can be found in the PATENTS file in the same directory.
 */

#import "FBTweak.h"
#import "FBTweakCollection.h"
#import "FBTweakStore.h"
#import "FBTweakCategory.h"
#import "_FBTweakCategoryViewController.h"

@interface _FBTweakCategoryViewController () <UITableViewDataSource, UITableViewDelegate>
@end

@implementation _FBTweakCategoryViewController {
  UITableView *_tableView;
}

- (instancetype)initWithStore:(FBTweakStore *)store
{
  if ((self = [super init])) {
    self.title = @"Tweaks";
    
    _store = store;
  }

  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
  _tableView.delegate = self;
  _tableView.dataSource = self;
  _tableView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
  [self.view addSubview:_tableView];
  
    
  UIBarButtonItem *resetItem = [[UIBarButtonItem alloc] initWithTitle:@"Reset" style:UIBarButtonItemStylePlain target:self action:@selector(_reset)];
    
  UIBarButtonItem *diffItem = [[UIBarButtonItem alloc] initWithTitle:@"Diff" style:UIBarButtonItemStylePlain target:self action:@selector(_copyDiffrences)];
    
  self.navigationItem.leftBarButtonItems = @[resetItem, diffItem];

  self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(_done)];
}

- (void)dealloc
{
  _tableView.delegate = nil;
  _tableView.dataSource = nil;
}

- (void)_done
{
  [_delegate tweakCategoryViewControllerSelectedDone:self];
}

- (void)_reset
{
  [_store reset];
}

- (void)_copyDiffrences {
    

    NSMutableArray *resultArray = [NSMutableArray arrayWithCapacity:0];
    
    for (FBTweakCategory *category in _store.tweakCategories) {
        for (FBTweakCollection *collection in category.tweakCollections) {
            for (FBTweak *tweak in collection.tweaks) {
                
                if (!tweak.currentValue) {
                    break;
                }

                if ([tweak.currentValue compare:tweak.defaultValue] != NSOrderedSame) {
                    NSDictionary *tweakInfo = @{@"currentValue":tweak.currentValue,
                                                @"defaultValue":tweak.defaultValue,
                                                @"tweakName": tweak.name,
                                                @"tweakCollectionName": collection.name,
                                                @"tweakCatigoryname": category.name};
                    [resultArray addObject:tweakInfo];
                }
            }
        }
    }
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:resultArray options:NSJSONWritingPrettyPrinted error:nil];
    if ([resultArray count] > 0) {
        [[UIPasteboard generalPasteboard] setPersistent:YES];
        [[UIPasteboard generalPasteboard] setString:[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]];

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"diffrence of between defualt value and current value is copied!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"There is no difference." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  
  [_tableView deselectRowAtIndexPath:_tableView.indexPathForSelectedRow animated:animated];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return _store.tweakCategories.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *_FBTweakCategoryViewControllerCellIdentifier = @"_FBTweakCategoryViewControllerCellIdentifier";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:_FBTweakCategoryViewControllerCellIdentifier];
  if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_FBTweakCategoryViewControllerCellIdentifier];
  }
  
  cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

  FBTweakCategory *category = _store.tweakCategories[indexPath.row];
  cell.textLabel.text = category.name;
  
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  FBTweakCategory *category = _store.tweakCategories[indexPath.row];
  [_delegate tweakCategoryViewController:self selectedCategory:category];
}

@end
