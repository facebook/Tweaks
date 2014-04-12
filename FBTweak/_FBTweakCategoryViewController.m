/**
 Copyright (c) 2014-present, Facebook, Inc.
 All rights reserved.
 
 This source code is licensed under the BSD-style license found in the
 LICENSE file in the root directory of this source tree. An additional grant
 of patent rights can be found in the PATENTS file in the same directory.
 */

#import "FBTweakStore.h"
#import "FBTweakCategory.h"
#import "_FBTweakCategoryViewController.h"
#import <MessageUI/MessageUI.h>

@interface _FBTweakCategoryViewController () <UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate>
@end

@implementation _FBTweakCategoryViewController {
  UITableView *_tableView;
  UIToolbar *_toolbar;
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
  
  _toolbar = [[UIToolbar alloc] init];
  [_toolbar sizeToFit];
  CGRect toolbarFrame = _toolbar.frame;
  toolbarFrame.origin.y = CGRectGetMaxY(self.view.bounds) - CGRectGetHeight(toolbarFrame);
  _toolbar.frame = toolbarFrame;
  [_toolbar setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin];
  [self.view addSubview:_toolbar];
  
  CGRect tableViewFrame = self.view.bounds;
  tableViewFrame.size.height -= CGRectGetHeight(_toolbar.bounds);
  _tableView = [[UITableView alloc] initWithFrame:tableViewFrame style:UITableViewStylePlain];
  _tableView.delegate = self;
  _tableView.dataSource = self;
  UIEdgeInsets contentInset = _tableView.contentInset;
  contentInset.top = CGRectGetMaxY(self.navigationController.navigationBar.frame);
  _tableView.contentInset = contentInset;
  _tableView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
  [self.view addSubview:_tableView];
  
  self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Reset" style:UIBarButtonItemStylePlain target:self action:@selector(_reset)];
  self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(_done)];
  
  NSArray *toolBarButtons = @[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil], [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(_export)]];
  [_toolbar setItems:toolBarButtons animated:NO];
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

- (void)_export
{
  [self _exportTweaks];
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

- (void)_exportTweaks
{
  MFMailComposeViewController *mailComposeViewController = [[MFMailComposeViewController alloc] init];
  mailComposeViewController.mailComposeDelegate = self;
  
  NSDictionary *storeDictionary = [self.store dictionaryRepresentation];
  
  NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString*)kCFBundleVersionKey];
  NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
  
  NSString *subject = [NSString stringWithFormat:@"%@ Tweaks",appName];
  NSString *body = [NSString stringWithFormat:@"%@ \n%@", appName, version];
  NSData *data = [NSKeyedArchiver archivedDataWithRootObject:storeDictionary];
  
  NSString *fileName = [NSString stringWithFormat:@"%@_tweaks.plist", appName];
  [mailComposeViewController addAttachmentData:data mimeType:@"plist" fileName:fileName];
  [mailComposeViewController setSubject:subject];
  [mailComposeViewController setMessageBody:body isHTML:NO];
  
  [self presentViewController:mailComposeViewController animated:YES completion:nil];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
  [self dismissViewControllerAnimated:YES completion:nil];
}

@end
