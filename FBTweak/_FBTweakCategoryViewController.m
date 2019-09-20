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
#import "_FBTweakSearchUtil.h"
#import "_FBTweakCategoryViewController.h"
#import "_FBTweakTableViewCell.h"
#import <MessageUI/MessageUI.h>

@interface _FBTweakCategoryViewController () <UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate, UISearchDisplayDelegate, UISearchBarDelegate>
@end

#if (__IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE8_0) && (!defined(__has_feature) || !__has_feature(attribute_availability_app_extension))
@interface _FBTweakCategoryViewController () <UIAlertViewDelegate>
@end
#endif

@implementation _FBTweakCategoryViewController {
  UITableView *_tableView;
  UIToolbar *_toolbar;
  UISearchBar *_searchBar;
  UISearchDisplayController *_searchController;

  NSArray *_sortedCategories;
  NSArray *_filteredCollections;
}

- (instancetype)initWithStore:(FBTweakStore *)store
{
  if ((self = [super init])) {
    self.title = @"Tweaks";
    
    _store = store;
    _sortedCategories = [_store.tweakCategories sortedArrayUsingComparator:^(FBTweakCategory *a, FBTweakCategory *b) {
      return [a.name localizedStandardCompare:b.name];
    }];
  }

  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  _toolbar = [[UIToolbar alloc] init];
  [_toolbar sizeToFit];
  CGRect toolbarFrame = _toolbar.frame;
  toolbarFrame.origin.y = CGRectGetMaxY(self.view.bounds) - CGRectGetHeight(toolbarFrame);
  _toolbar.frame = toolbarFrame;
  _toolbar.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin);
  [self.view addSubview:_toolbar];
  
  _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
  _tableView.delegate = self;
  _tableView.dataSource = self;
  _tableView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
  [self.view insertSubview:_tableView belowSubview:_toolbar];
    
  _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 44)];
  _searchBar.delegate = self;
  _tableView.tableHeaderView = _searchBar;
    
  _searchController = [[UISearchDisplayController alloc] initWithSearchBar:_searchBar contentsController:self];
  _searchController.delegate = self;
  _searchController.searchResultsDelegate = self;
  _searchController.searchResultsDataSource = self;
  
  UIEdgeInsets contentInset = _tableView.contentInset;
  UIEdgeInsets scrollIndictatorInsets = _tableView.scrollIndicatorInsets;
  contentInset.bottom = CGRectGetHeight(_toolbar.bounds);
  scrollIndictatorInsets.bottom = CGRectGetHeight(_toolbar.bounds);
  _tableView.contentInset = contentInset;
  _tableView.scrollIndicatorInsets = scrollIndictatorInsets;
  
  self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Reset" style:UIBarButtonItemStylePlain target:self action:@selector(_reset)];
  self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(_done)];
  
  if ([MFMailComposeViewController canSendMail]) {
    UIBarButtonItem *exportItem = [[UIBarButtonItem alloc] initWithTitle:@"Export" style:UIBarButtonItemStyleDone target:self action:@selector(_export)];
    UIBarButtonItem *flexibleSpaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    _toolbar.items = @[flexibleSpaceItem, exportItem];
  }
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
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 8000
  if ([UIAlertController class] != nil) {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Are you sure?"
                                                                             message:@"Are you sure you want to reset your tweaks? This cannot be undone."
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
      // do nothing
    }];
    [alertController addAction:cancelAction];

    UIAlertAction *resetAction = [UIAlertAction actionWithTitle:@"Reset" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
      [_store reset];
    }];
    [alertController addAction:resetAction];

    [self presentViewController:alertController animated:YES completion:NULL];
  } else {
#endif
#if (__IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE8_0) && (!defined(__has_feature) || !__has_feature(attribute_availability_app_extension))
    // This is iOS 7 or lower. We need to use UIAlertView, because UIAlertController is not available.
    // UIAlertView, however, is not available in app-extensions, so to allow compilation, we conditionally compile this branch only when we're not an app-extension. UIAlertController is always available in app-extensions, so this is safe.
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Are you sure?"
                                                    message:@"Are you sure you want to reset your tweaks? This cannot be undone."
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Reset", nil];
    [alert show];
#endif
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 8000
  }
#endif
}

- (void)_export
{
  NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:(__bridge NSString *)kCFBundleVersionKey];
  NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
  NSString *fileName = [NSString stringWithFormat:@"tweaks_%@_%@.plist", appName, version];
  
  NSMutableData *data = [NSMutableData data];
  NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
  archiver.outputFormat = NSPropertyListXMLFormat_v1_0;
  [archiver encodeRootObject:_store];
  [archiver finishEncoding];
  
  MFMailComposeViewController *mailComposeViewController = [[MFMailComposeViewController alloc] init];
  mailComposeViewController.mailComposeDelegate = self;
  mailComposeViewController.subject = [NSString stringWithFormat:@"%@ Tweaks (v%@)", appName, version];
  [mailComposeViewController addAttachmentData:data mimeType:@"plist" fileName:fileName];
  [self presentViewController:mailComposeViewController animated:YES completion:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  
  [_tableView deselectRowAtIndexPath:_tableView.indexPathForSelectedRow animated:animated];
}

- (void)_filterTweaksForQuery:(NSString*)query
{
  _filteredCollections = [_FBTweakSearchUtil filteredCollectionsInCategories:_sortedCategories forQuery:query];
}

#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  if (tableView == self.searchDisplayController.searchResultsTableView) {
    return _filteredCollections.count;
  } else {
    return 1;
  }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  if (tableView == self.searchDisplayController.searchResultsTableView) {
    FBTweakCollection *collection = _filteredCollections[section];
    return collection.tweaks.count;
  } else {
    return _sortedCategories.count;
  }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (tableView == self.searchDisplayController.searchResultsTableView) {
    static NSString *_FBTweakCollectionViewControllerCellIdentifier = @"_FBTweakCollectionViewControllerCellIdentifier";
    _FBTweakTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:_FBTweakCollectionViewControllerCellIdentifier];
    if (cell == nil) {
        cell = [[_FBTweakTableViewCell alloc] initWithReuseIdentifier:_FBTweakCollectionViewControllerCellIdentifier];
    }
    
    FBTweakCollection *collection = _filteredCollections[indexPath.section];
    FBTweak *tweak = collection.tweaks[indexPath.row];
    cell.tweak = tweak;
    cell.searchQuery = _searchBar.text;
    
    return cell;
  } else {
    static NSString *_FBTweakCategoryViewControllerCellIdentifier = @"_FBTweakCategoryViewControllerCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:_FBTweakCategoryViewControllerCellIdentifier];
    if (cell == nil) {
      cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_FBTweakCategoryViewControllerCellIdentifier];
    }

    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    FBTweakCategory *category =_sortedCategories[indexPath.row];
    cell.textLabel.text = category.name;

    return cell;
  }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
  if (tableView == self.searchDisplayController.searchResultsTableView) {
    FBTweakCollection *collection = _filteredCollections[section];
    return collection.name;
  } else {
    return nil;
  }
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (tableView == self.searchDisplayController.searchResultsTableView) {
    FBTweakCollection *collection = _filteredCollections[indexPath.section];
    FBTweak *tweak = collection.tweaks[indexPath.row];
    [_FBTweakSearchUtil handleTweakSelection:tweak inTableView:tableView atIndexPath:indexPath navigationController:self.navigationController];
  } else {
    FBTweakCategory *category =_sortedCategories[indexPath.row];
    [_delegate tweakCategoryViewController:self selectedCategory:category];
  }
}

#if (__IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE8_0) && (!defined(__has_feature) || !__has_feature(attribute_availability_app_extension))

#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
  if (buttonIndex != alertView.cancelButtonIndex) {
    [_store reset];
  }
}
#endif

#pragma mark MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
  [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark UISearchDisplayDelegate

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
