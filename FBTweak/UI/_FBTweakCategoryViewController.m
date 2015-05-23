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

@interface _FBTweakCategoryViewController () <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, MFMailComposeViewControllerDelegate>
@end

@implementation _FBTweakCategoryViewController {
  UITableView *_tableView;
  UIToolbar *_toolbar;

  NSArray *_sortedCategories;
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
    // To allow using Tweaks from within app extensions, which do not allow linking against UIAlertView, load the class dynamically.
    // Note this codepath will never be executed in an app extension, since UIAlertController will always be available when they are.
    UIAlertView *alert = [[NSClassFromString(@"UIAlertView") alloc] initWithTitle:@"Are you sure?"
                                                    message:@"Are you sure you want to reset your tweaks? This cannot be undone."
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Reset", nil];
    [alert show];
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return _sortedCategories.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *_FBTweakCategoryViewControllerCellIdentifier = @"_FBTweakCategoryViewControllerCellIdentifier";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:_FBTweakCategoryViewControllerCellIdentifier];
  if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_FBTweakCategoryViewControllerCellIdentifier];
  }
  
  cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

  FBTweakCategory *category = _sortedCategories[indexPath.row];
  cell.textLabel.text = category.name;
  
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  FBTweakCategory *category = _sortedCategories[indexPath.row];
  [_delegate tweakCategoryViewController:self selectedCategory:category];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
  if (buttonIndex != alertView.cancelButtonIndex) {
    [_store reset];
  }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
  [self dismissViewControllerAnimated:YES completion:nil];
}

@end
