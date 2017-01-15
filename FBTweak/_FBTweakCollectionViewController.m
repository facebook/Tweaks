/**
 Copyright (c) 2014-present, Facebook, Inc.
 All rights reserved.
 
 This source code is licensed under the BSD-style license found in the
 LICENSE file in the root directory of this source tree. An additional grant
 of patent rights can be found in the PATENTS file in the same directory.
 */

#import "FBTweakCollection.h"
#import "FBTweakCategory.h"
#import "FBTweak.h"
#import "_FBTweakCollectionViewController.h"
#import "_FBTweakTableViewCell.h"
#import "_FBTweakColorViewController.h"
#import "_FBTweakDictionaryViewController.h"
#import "_FBTweakArrayViewController.h"
#import "_FBKeyboardManager.h"

@interface _FBTweakCollectionViewController () <UITableViewDelegate, UITableViewDataSource, UISearchDisplayDelegate, UISearchBarDelegate>
@end

@implementation _FBTweakCollectionViewController {
  UITableView *_tableView;
  UISearchBar *_searchBar;
  UISearchDisplayController *_searchController;

  NSArray *_sortedCollections;
  NSArray *_filteredCollections;
  _FBKeyboardManager *_keyboardManager;
}

- (instancetype)initWithTweakCategory:(FBTweakCategory *)category
{
  if ((self = [super init])) {
    _tweakCategory = category;
    self.title = _tweakCategory.name;
    [self _reloadData];
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
    
  _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 44)];
  _searchBar.delegate = self;
  _tableView.tableHeaderView = _searchBar;
  
  _searchController = [[UISearchDisplayController alloc] initWithSearchBar:_searchBar contentsController:self];
  _searchController.delegate = self;
  _searchController.searchResultsDelegate = self;
  _searchController.searchResultsDataSource = self;
  
  self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(_done)];

  _keyboardManager = [[_FBKeyboardManager alloc] initWithViewScrollView:_tableView];
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
  [self _reloadData];

  [_keyboardManager enable];
}

- (void)viewWillDisappear:(BOOL)animated
{
  [super viewWillDisappear:animated];
  [_keyboardManager disable];
}

- (void)_reloadData
{
  _sortedCollections = [_tweakCategory.tweakCollections sortedArrayUsingComparator:^(FBTweakCollection *a, FBTweakCollection *b) {
    return [a.name localizedStandardCompare:b.name];
  }];
  [_tableView reloadData];
}

- (void)_done
{
  [_delegate tweakCollectionViewControllerSelectedDone:self];
}

- (void)_filterTweaksForQuery:(NSString*)query
{
  NSMutableArray *collections = [NSMutableArray arrayWithCapacity:_sortedCollections.count];
  
  NSPredicate *filter = [NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@", query];
  for (FBTweakCollection *collection in _sortedCollections) {
    NSArray *filteredTweaks = [collection.tweaks filteredArrayUsingPredicate:filter];
    if (filteredTweaks.count > 0) {
      FBTweakCollection *filteredCollection = [[FBTweakCollection alloc] initWithName:collection.name];
      for (FBTweak *tweak in filteredTweaks) {
        [filteredCollection addTweak:tweak];
      }
      [collections addObject:filteredCollection];
    }
  }
    
  _filteredCollections = collections;
}

- (NSArray*)_collectionsToDisplayInTableView:(UITableView*)tableView
{
  if (tableView == self.searchDisplayController.searchResultsTableView) {
    return _filteredCollections;
  } else {
    return _sortedCollections;
  }
}

#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return [self _collectionsToDisplayInTableView:tableView].count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  FBTweakCollection *collection = [self _collectionsToDisplayInTableView:tableView][section];
  return collection.tweaks.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
  FBTweakCollection *collection = [self _collectionsToDisplayInTableView:tableView][section];
  return collection.name;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *_FBTweakCollectionViewControllerCellIdentifier = @"_FBTweakCollectionViewControllerCellIdentifier";
  _FBTweakTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:_FBTweakCollectionViewControllerCellIdentifier];
  if (cell == nil) {
    cell = [[_FBTweakTableViewCell alloc] initWithReuseIdentifier:_FBTweakCollectionViewControllerCellIdentifier];
  }
  
  FBTweakCollection *collection = [self _collectionsToDisplayInTableView:tableView][indexPath.section];
  FBTweak *tweak = collection.tweaks[indexPath.row];
  cell.tweak = tweak;
  
  return cell;
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  FBTweakCollection *collection = [self _collectionsToDisplayInTableView:tableView][indexPath.section];
  FBTweak *tweak = collection.tweaks[indexPath.row];
  if ([tweak.possibleValues isKindOfClass:[NSDictionary class]]) {
    _FBTweakDictionaryViewController *vc = [[_FBTweakDictionaryViewController alloc] initWithTweak:tweak];
    [self.navigationController pushViewController:vc animated:YES];
  } else if ([tweak.possibleValues isKindOfClass:[NSArray class]]) {
    _FBTweakArrayViewController *vc = [[_FBTweakArrayViewController alloc] initWithTweak:tweak];
    [self.navigationController pushViewController:vc animated:YES];
  } else if ([tweak.defaultValue isKindOfClass:[UIColor class]]) {
    _FBTweakColorViewController *vc = [[_FBTweakColorViewController alloc] initWithTweak:tweak];
    [self.navigationController pushViewController:vc animated:YES];
  } else if (tweak.isAction) {
    dispatch_block_t block = tweak.defaultValue;
    if (block != NULL) {
        block();
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
  }
}

#pragma mark UISearchDisplayDelegate

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller
{
  [self _reloadData];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(nullable NSString *)searchString
{
  [self _filterTweaksForQuery:searchString];
  return YES;
}

#pragma mark UISearchBarDelegate

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
  return YES;
}

@end
