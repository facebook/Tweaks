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
#import <MessageUI/MessageUI.h>

@interface _FBTweakCategoryViewController () <UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate>
@end

#if (__IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE8_0) && (!defined(__has_feature) || !__has_feature(attribute_availability_app_extension))
@interface _FBTweakCategoryViewController () <UIAlertViewDelegate>
@end
#endif

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
  
    
  UIBarButtonItem *resetItem = [[UIBarButtonItem alloc] initWithTitle:@"Reset" style:UIBarButtonItemStylePlain target:self action:@selector(_reset)];
    
  UIBarButtonItem *diffItem = [[UIBarButtonItem alloc] initWithTitle:@"Diff" style:UIBarButtonItemStylePlain target:self action:@selector(_copyDiffrences)];
    
  self.navigationItem.leftBarButtonItems = @[resetItem, diffItem];

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

#if (__IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE8_0) && (!defined(__has_feature) || !__has_feature(attribute_availability_app_extension))
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
  if (buttonIndex != alertView.cancelButtonIndex) {
    [_store reset];
  }
}
#endif

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
  [self dismissViewControllerAnimated:YES completion:nil];
}

@end
