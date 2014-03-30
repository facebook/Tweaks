/**
 Copyright (c) 2014-present, Facebook, Inc.
 All rights reserved.
 
 This source code is licensed under the BSD-style license found in the
 LICENSE file in the root directory of this source tree. An additional grant
 of patent rights can be found in the PATENTS file in the same directory.
 */

#import "FBTweakStore.h"
#import "FBTweakCategory.h"
#import "FBTweakCollection.h"
#import "FBTweak.h"
#import "_FBTweakCategoryViewController.h"

@interface _FBTweakCategoryViewController () <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate>
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
  
  self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Options" style:UIBarButtonItemStylePlain target:self action:@selector(_options)];
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

-(void)_options
{
    UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:
                            @"Reset",
                            @"Copy Config URL",
                            nil];
    [popup showInView:self.view];
}

- (void)_reset
{
  [_store reset];
}

-(void)_exportURLSchemeConfigToPasteboard
{
    NSMutableArray* query=[NSMutableArray array];
    for (FBTweakCategory* category in _store.tweakCategories) {
        for (FBTweakCollection* collection in category.tweakCollections) {
            for (FBTweak* tweak in collection.tweaks) {
                if (tweak.currentValue) {
                    [query addObject:[NSString stringWithFormat:@"%@-%@-%@=%@",category.name,collection.name,tweak.name,tweak.currentValue]];
                    
                }
            }
        }
    }
    if ([query count]==0) {
        NSLog(@"No values tweaked");
        return;
    }

    NSString* url= [[NSString stringWithFormat:@"FBTweaks.%@://importFBTweaks?%@",
                     [[NSBundle mainBundle] bundleIdentifier],
                     [query componentsJoinedByString:@"&"]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    UIPasteboard *pb = [UIPasteboard generalPasteboard];
    [pb setString:url];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==0) {
        [self _reset];
    }
    else{
        [self _exportURLSchemeConfigToPasteboard];

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
