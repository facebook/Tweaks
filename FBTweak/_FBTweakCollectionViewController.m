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
#import "_FBTweakSearchUtil.h"
#import "_FBTweakCollectionViewController.h"
#import "_FBTweakTableViewCell.h"
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
  _filteredCollections = [_FBTweakSearchUtil filteredCollectionsInCategories:@[self.tweakCategory] forQuery:query];
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
  cell.searchQuery = _searchBar.text;
  
  return cell;
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  FBTweakCollection *collection = [self _collectionsToDisplayInTableView:tableView][indexPath.section];
  FBTweak *tweak = collection.tweaks[indexPath.row];
  [_FBTweakSearchUtil handleTweakSelection:tweak inTableView:tableView atIndexPath:indexPath navigationController:self.navigationController];
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
