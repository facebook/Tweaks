/**
 Copyright (c) 2014-present, Facebook, Inc.
 All rights reserved.
 
 This source code is licensed under the BSD-style license found in the
 LICENSE file in the root directory of this source tree. An additional grant
 of patent rights can be found in the PATENTS file in the same directory.
 */

#import <UIKit/UIKit.h>
#import "FBTweak.h"

/**
 @abstract A util class to provide helpers in search functionality
 */
@interface _FBTweakSearchUtil : NSObject

+ (void)handleTweakSelection:(FBTweak *)tweak
                 inTableView:(UITableView *)tableView
                 atIndexPath:(NSIndexPath *)indexPath
        navigationController:(UINavigationController *)navigationController;

+ (NSArray *)filteredCollectionsInCategories:(NSArray *)categories forQuery:(NSString *)searchQuery;

@end
