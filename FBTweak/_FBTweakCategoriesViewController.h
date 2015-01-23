//
//  _FBTweakCategoriesViewController.h
//  FBTweak
//
//  Created by Paulo Andrade on 13/12/14.
//  Copyright (c) 2014 Facebook. All rights reserved.
//

#import <AppKit/AppKit.h>
#import "FBTweakStore.h"
#import "FBTweakCategory.h"

@protocol _FBTweakCategoriesViewControllerDelegate;



@interface _FBTweakCategoriesViewController : NSViewController

- (instancetype)initWithStore:(FBTweakStore *)store;

@property (nonatomic, weak) id<_FBTweakCategoriesViewControllerDelegate> delegate;

- (FBTweakCategory *)selectedCategory;

@end




@protocol _FBTweakCategoriesViewControllerDelegate <NSObject>

- (void)categoriesViewController:(_FBTweakCategoriesViewController *)controller didChangeSelection:(FBTweakCategory *)category;

@end
