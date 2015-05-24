//
//  FBTweakViewController.h
//  FBTweak
//
//  Created by Andrew Pouliot on 5/22/15.
//  Copyright (c) 2015 Facebook. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <FBTweak/FBTweakStore.h>

@interface FBTweakViewController : NSViewController

+ (void)showTweaks;

- (instancetype)initWithStore:(FBTweakStore *)store;

@end
